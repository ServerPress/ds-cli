/* 
 * threadPoolCmd.c --
 *
 * This file implements the Tcl thread pools.
 *
 * Copyright (c) 2002 by Zoran Vasiljevic.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * RCS: @(#) $Id: threadPoolCmd.c,v 1.28 2004/11/27 06:11:02 vasiljevic Exp $
 * ----------------------------------------------------------------------------
 */

#include "tclThread.h"

/*
 * Structure to maintain idle poster threads
 */

typedef struct TpoolWaiter {
    Tcl_ThreadId threadId;         /* Thread id of the current thread */
    struct TpoolWaiter *nextPtr;   /* Next structure in the list */
    struct TpoolWaiter *prevPtr;   /* Previous structure in the list */
} TpoolWaiter;

/*
 * Structure describing an instance of a thread pool.
 */

typedef struct ThreadPool {
    unsigned int jobId;             /* Job counter */
    int idleTime;                   /* Time in secs a worker thread idles */
    int tearDown;                   /* Set to 1 to tear down the pool */
    char *initScript;               /* Script to initialize worker thread */
    char *exitScript;               /* Script to cleanup the worker */
    int minWorkers;                 /* Minimum number or worker threads */
    int maxWorkers;                 /* Maximum number of worker threads */
    int numWorkers;                 /* Current number of worker threads */
    int idleWorkers;                /* Number of idle workers */
    int refCount;                   /* Reference counter for reserve/release */
    Tcl_Mutex mutex;                /* Pool mutex */
    Tcl_Condition cond;             /* Pool condition variable */
    Tcl_HashTable jobsDone;         /* Stores processed job results */
    struct TpoolResult *workTail;   /* Tail of the list with jobs pending*/
    struct TpoolResult *workHead;   /* Head of the list with jobs pending*/
    struct TpoolWaiter *waitTail;   /* Tail of the thread waiters list */
    struct TpoolWaiter *waitHead;   /* Head of the thread waiters list */
    struct ThreadPool *nextPtr;     /* Next structure in the threadpool list */
    struct ThreadPool *prevPtr;     /* Previous structure in threadpool list */
} ThreadPool;

#define TPOOL_HNDLPREFIX  "tpool"   /* Prefix to generate Tcl pool handles */
#define TPOOL_MINWORKERS  0         /* Default minimum # of worker threads */
#define TPOOL_MAXWORKERS  4         /* Default maximum # of worker threads */
#define TPOOL_IDLETIMER   0         /* Default worker thread idle timer */

/*
 * Structure for passing evaluation results
 */

typedef struct TpoolResult {
    int detached;                   /* Result is to be ignored */
    unsigned int jobId;             /* The job id of the current job */
    char *script;                   /* Script to evaluate in worker thread */
    int scriptLen;                  /* Length of the script */    
    int retcode;                    /* Tcl return code of the current job */
    char *result;                   /* Tcl result of the current job */
    char *errorCode;                /* On error: content of the errorCode */
    char *errorInfo;                /* On error: content of the errorInfo */
    Tcl_ThreadId threadId;          /* Originating thread id */
    ThreadPool *tpoolPtr;           /* Current thread pool */
    struct TpoolResult *nextPtr;
    struct TpoolResult *prevPtr;
} TpoolResult;

/*
 * Private structure for each worker/poster thread.
 */

typedef struct ThreadSpecificData {
    int stop;                       /* Set stop event; exit from event loop */
    TpoolWaiter *waitPtr;           /* Threads private idle structure */
} ThreadSpecificData;

static Tcl_ThreadDataKey dataKey;

/*
 * This global list maintains thread pools.
 */

static ThreadPool *tpoolList;
static Tcl_Mutex listMutex;
static Tcl_Mutex startMutex;

/*
 * Used to represent the empty result.
 */

static char *threadEmptyResult = "";

/*
 * Functions implementing Tcl commands
 */

static Tcl_ObjCmdProc TpoolCreateObjCmd;
static Tcl_ObjCmdProc TpoolPostObjCmd;
static Tcl_ObjCmdProc TpoolWaitObjCmd;
static Tcl_ObjCmdProc TpoolCancelObjCmd;
static Tcl_ObjCmdProc TpoolGetObjCmd;
static Tcl_ObjCmdProc TpoolReserveObjCmd;
static Tcl_ObjCmdProc TpoolReleaseObjCmd;
static Tcl_ObjCmdProc TpoolNamesObjCmd;

/*
 * Miscelaneous functions used within this file
 */

static int
CreateWorker   _ANSI_ARGS_((Tcl_Interp *interp, ThreadPool *tpoolPtr));

static Tcl_ThreadCreateType
TpoolWorker    _ANSI_ARGS_((ClientData clientData));

static int
RunStopEvent   _ANSI_ARGS_((Tcl_Event *evPtr, int mask));

static void
PushWork       _ANSI_ARGS_((TpoolResult *rPtr, ThreadPool *tpoolPtr));

static TpoolResult*
PopWork        _ANSI_ARGS_((ThreadPool *tpoolPtr));

static void
PushWaiter     _ANSI_ARGS_((ThreadPool *tpoolPtr));

static TpoolWaiter*
PopWaiter      _ANSI_ARGS_((ThreadPool *tpoolPtr));

static void
SignalWaiter   _ANSI_ARGS_((ThreadPool *tpoolPtr));

static int
TpoolEval      _ANSI_ARGS_((Tcl_Interp *interp, char *script, int scriptLen,
                            TpoolResult *rPtr));
static void
SetResult      _ANSI_ARGS_((Tcl_Interp *interp, TpoolResult *rPtr));

static ThreadPool* 
GetTpool       _ANSI_ARGS_((char *tpoolName));

static ThreadPool* 
GetTpoolUnl    _ANSI_ARGS_((char *tpoolName));

static void
ThrExitHandler _ANSI_ARGS_((ClientData clientData));

static void
AppExitHandler _ANSI_ARGS_((ClientData clientData));

static int
TpoolReserve   _ANSI_ARGS_((ThreadPool *tpoolPtr));

static int
TpoolRelease   _ANSI_ARGS_((ThreadPool *tpoolPtr));

static void
InitWaiter     _ANSI_ARGS_((void));

static void
GetTime        _ANSI_ARGS_((Tcl_Time *timePtr));


/*
 *----------------------------------------------------------------------
 *
 * TpoolCreateObjCmd --
 *
 *  This procedure is invoked to process the "tpool::create" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static int
TpoolCreateObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ii, minw, maxw, idle, len;
    char buf[16], *exs = NULL, *cmd = NULL;
    ThreadPool *tpoolPtr;

    /* 
     * Syntax:  tpool::create ?-minworkers count?
     *                        ?-maxworkers count?
     *                        ?-initcmd script?
     *                        ?-exitcmd script?
     *                        ?-idletime seconds?
     */

    if (((objc-1) % 2)) {
        goto usage;
    }

    minw = TPOOL_MINWORKERS;
    maxw = TPOOL_MAXWORKERS;
    idle = TPOOL_IDLETIMER;

    /*
     * Parse the optional arguments
     */

    for (ii = 1; ii < objc; ii += 2) {
        char *opt = Tcl_GetString(objv[ii]);
        if (OPT_CMP(opt, "-minworkers")) {
            if (Tcl_GetIntFromObj(interp, objv[ii+1], &minw) != TCL_OK) {
                return TCL_ERROR;
            }
        } else if (OPT_CMP(opt, "-maxworkers")) {
            if (Tcl_GetIntFromObj(interp, objv[ii+1], &maxw) != TCL_OK) {
                return TCL_ERROR;
            }
        } else if (OPT_CMP(opt, "-idletime")) {
            if (Tcl_GetIntFromObj(interp, objv[ii+1], &idle) != TCL_OK) {
                return TCL_ERROR;
            }
        } else if (OPT_CMP(opt, "-initcmd")) {
            char *val = Tcl_GetStringFromObj(objv[ii+1], &len);
            cmd  = strcpy(Tcl_Alloc(len+1), val);
        } else if (OPT_CMP(opt, "-exitcmd")) {
            char *val = Tcl_GetStringFromObj(objv[ii+1], &len);
            exs  = strcpy(Tcl_Alloc(len+1), val);
        } else {
            goto usage;
        }
    }

    /*
     * Do some consistency checking
     */

    if (minw < 0) {
        minw = 0;
    }
    if (maxw < 0) {
        maxw = TPOOL_MAXWORKERS;
    }
    if (minw > maxw) {
        maxw = minw;
    }

    /*
     * Allocate and initialize thread pool structure
     */

    tpoolPtr = (ThreadPool*)Tcl_Alloc(sizeof(ThreadPool));
    memset(tpoolPtr, 0, sizeof(ThreadPool));

    tpoolPtr->minWorkers  = minw;
    tpoolPtr->maxWorkers  = maxw;
    tpoolPtr->idleTime    = idle;
    tpoolPtr->initScript  = cmd;
    tpoolPtr->exitScript  = exs;
    Tcl_InitHashTable(&tpoolPtr->jobsDone, TCL_ONE_WORD_KEYS);

    /*
     * Start the required number of worker threads.
     */

    for (ii = 0; ii < tpoolPtr->minWorkers; ii++) {
        if (CreateWorker(interp, tpoolPtr) != TCL_OK) {
            Tcl_Free((char*)tpoolPtr);
            return TCL_ERROR;
        }
    }

    Tcl_MutexLock(&listMutex);
    SpliceIn(tpoolPtr, tpoolList);
    Tcl_MutexUnlock(&listMutex);

    sprintf(buf, "%s%p", TPOOL_HNDLPREFIX, tpoolPtr);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(buf, -1));

    return TCL_OK;

 usage:
    Tcl_WrongNumArgs(interp, 1, objv,
                     "?-minworkers count? ?-maxworkers count? "
                     "?-initcmd script? ?-exitcmd script? "
                     "?-idletime seconds?");
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolPostObjCmd --
 *
 *  This procedure is invoked to process the "tpool::post" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static int
TpoolPostObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    unsigned int jobId = 0;
    int ii, detached = 0, nowait = 0, len;
    char *tpoolName, *script;
    TpoolResult *rPtr;
    ThreadPool *tpoolPtr;

    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);

    /* 
     * Syntax: tpool::post ?-detached? ?-nowait? tpoolId script
     */

    if (objc < 3 || objc > 5) {
        goto usage;
    }
    for (ii = 1; ii < objc; ii++) {
        char *opt = Tcl_GetString(objv[ii]);
        if (*opt != '-') {
            break;
        } else if (OPT_CMP(opt, "-detached")) {
            detached  = 1;
        } else if (OPT_CMP(opt, "-nowait")) {
            nowait = 1;
        } else {
            goto usage;
        }
    }

    tpoolName = Tcl_GetString(objv[ii]);
    script    = Tcl_GetStringFromObj(objv[ii+1], &len);
    tpoolPtr  = GetTpool(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName, 
                         "\"", NULL);
        return TCL_ERROR;
    }
    
    /*
     * Initialize per-thread private data for this caller
     */
    
    InitWaiter();

    /*
     * Wait for an idle worker thread or just assure that
     * there is at least one running worker thread if 
     * caller decides not to wait for the idle worker thread.
     */

    Tcl_MutexLock(&tpoolPtr->mutex);
    if (nowait) {
        if (tpoolPtr->numWorkers < tpoolPtr->maxWorkers) {
            PushWaiter(tpoolPtr);
            if (CreateWorker(interp, tpoolPtr) != TCL_OK) {
                Tcl_MutexUnlock(&tpoolPtr->mutex);
                return TCL_ERROR;
            }
            /* Wait for worker to start and service the event loop */
            Tcl_MutexUnlock(&tpoolPtr->mutex);
            tsdPtr->stop = -1;
            while(tsdPtr->stop == -1) {
                Tcl_DoOneEvent(TCL_ALL_EVENTS);
            }
            Tcl_MutexLock(&tpoolPtr->mutex);
        }
    } else {
        while (tpoolPtr->idleWorkers == 0) {
            PushWaiter(tpoolPtr);
            if (tpoolPtr->numWorkers < tpoolPtr->maxWorkers) {
                /* No more free workers; start new one */
                if (CreateWorker(interp, tpoolPtr) != TCL_OK) {
                    Tcl_MutexUnlock(&tpoolPtr->mutex);
                    return TCL_ERROR;
                }
            }
            /* Wait for any idle worker and service the event loop */
            Tcl_MutexUnlock(&tpoolPtr->mutex);
            tsdPtr->stop = -1;
            while(tsdPtr->stop == -1) {
                Tcl_DoOneEvent(TCL_ALL_EVENTS);
            }
            Tcl_MutexLock(&tpoolPtr->mutex);
        }
    }

    /*
     * Create new job ticket and put it on the list.
     */

    rPtr = (TpoolResult*)Tcl_Alloc(sizeof(TpoolResult));
    memset(rPtr, 0, sizeof(TpoolResult));

    if (detached == 0) {
        jobId = ++tpoolPtr->jobId;
        rPtr->jobId = jobId;
    }

    rPtr->script    = strcpy(Tcl_Alloc(len+1), script);
    rPtr->scriptLen = len;
    rPtr->detached  = detached;
    rPtr->threadId  = Tcl_GetCurrentThread();

    PushWork(rPtr, tpoolPtr);

    Tcl_ConditionNotify(&tpoolPtr->cond);
    Tcl_MutexUnlock(&tpoolPtr->mutex);

    if (detached == 0) {
        Tcl_SetObjResult(interp, Tcl_NewIntObj(jobId));
    }
    
    return TCL_OK;

  usage:
    Tcl_WrongNumArgs(interp, 1, objv, "?-detached? ?-nowait? tpoolId script");
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolWaitObjCmd --
 *
 *  This procedure is invoked to process the "tpool::wait" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolWaitObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ii, done, wObjc, jobId;
    char *tpoolName, *listVar = NULL;
    Tcl_Obj *waitList, *doneList, **wObjv;
    ThreadPool *tpoolPtr;
    TpoolResult *rPtr;
    Tcl_HashEntry *hPtr;

    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);

    /* 
     * Syntax: tpool::wait tpoolId jobIdList ?listVar?
     */

    if (objc < 3 || objc > 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "tpoolId jobIdList ?listVar");
        return TCL_ERROR;
    }
    if (objc == 4) {
        listVar = Tcl_GetString(objv[3]);
    }
    if (Tcl_ListObjGetElements(interp, objv[2], &wObjc, &wObjv) != TCL_OK) {
        return TCL_ERROR;
    }
    tpoolName = Tcl_GetString(objv[1]);
    tpoolPtr  = GetTpool(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName,
                         "\"", NULL);
        return TCL_ERROR;
    }

    InitWaiter();
    done = 0; /* Number of elements in the done list */
    doneList = Tcl_NewListObj(0, NULL);

    Tcl_MutexLock(&tpoolPtr->mutex);
    while (1) {
        waitList = Tcl_NewListObj(0, NULL);
        for (ii = 0; ii < wObjc; ii++) {
            if (Tcl_GetIntFromObj(interp, wObjv[ii], &jobId) != TCL_OK) {
                Tcl_MutexUnlock(&tpoolPtr->mutex);
                return TCL_ERROR;
            }
            hPtr = Tcl_FindHashEntry(&tpoolPtr->jobsDone, (char*)jobId);
            if (hPtr == NULL) {
                continue; /* Bogus job id; ignore */
            }
            rPtr = (TpoolResult*)Tcl_GetHashValue(hPtr);
            if (rPtr->detached) {
                continue; /* A detached job */
            }
            if (rPtr->result) {
                done++; /* Job has been processed */
                Tcl_ListObjAppendElement(interp, doneList, wObjv[ii]);
            } else if (listVar) {
                Tcl_ListObjAppendElement(interp, waitList, wObjv[ii]);
            }
        }
        if (done) {
            break;
        }

        /*
         * None of the jobs done, wait for completion
         * of the next job and try again.
         */

        Tcl_DecrRefCount(waitList); 
        PushWaiter(tpoolPtr);

        Tcl_MutexUnlock(&tpoolPtr->mutex);
        tsdPtr->stop = -1;
        while (tsdPtr->stop == -1) {
            Tcl_DoOneEvent(TCL_ALL_EVENTS);
        }
        Tcl_MutexLock(&tpoolPtr->mutex);
    }
    Tcl_MutexUnlock(&tpoolPtr->mutex);

    if (listVar) {
        Tcl_SetVar2Ex(interp, listVar, NULL, waitList, 0);
    }

    Tcl_SetObjResult(interp, doneList);

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolCancelObjCmd --
 *
 *  This procedure is invoked to process the "tpool::cancel" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolCancelObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ii, wObjc, jobId;
    char *tpoolName, *listVar = NULL;
    Tcl_Obj *doneList, *waitList, **wObjv;
    ThreadPool *tpoolPtr;
    TpoolResult *rPtr;

    /* 
     * Syntax: tpool::wait tpoolId jobIdList ?listVar?
     */

    if (objc < 3 || objc > 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "tpoolId jobIdList ?listVar");
        return TCL_ERROR;
    }
    if (objc == 4) {
        listVar = Tcl_GetString(objv[3]);
    }
    if (Tcl_ListObjGetElements(interp, objv[2], &wObjc, &wObjv) != TCL_OK) {
        return TCL_ERROR;
    }
    tpoolName = Tcl_GetString(objv[1]);
    tpoolPtr  = GetTpool(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName,
                         "\"", NULL);
        return TCL_ERROR;
    }
 
    InitWaiter();
    doneList = Tcl_NewListObj(0, NULL);
    waitList = Tcl_NewListObj(0, NULL);

    Tcl_MutexLock(&tpoolPtr->mutex);
    for (ii = 0; ii < wObjc; ii++) {
        if (Tcl_GetIntFromObj(interp, wObjv[ii], &jobId) != TCL_OK) {
            return TCL_ERROR;
        }
        for (rPtr = tpoolPtr->workHead; rPtr; rPtr = rPtr->nextPtr) {
            if (rPtr->jobId == (unsigned int)jobId) {
                if (rPtr->prevPtr != NULL) {
                    rPtr->prevPtr->nextPtr = rPtr->nextPtr;
                } else {
                    tpoolPtr->workHead = rPtr->nextPtr;
                }
                if (rPtr->nextPtr != NULL) {
                    rPtr->nextPtr->prevPtr = rPtr->prevPtr;
                } else {
                    tpoolPtr->workTail = rPtr->prevPtr;
                }
                SetResult(NULL, rPtr); /* Just to free the result */
                Tcl_Free(rPtr->script);
                Tcl_Free((char*)rPtr);
                Tcl_ListObjAppendElement(interp, doneList, wObjv[ii]);
                break;
            } else if (listVar) {
                Tcl_ListObjAppendElement(interp, waitList, wObjv[ii]);
            }
        }
    }
    Tcl_MutexUnlock(&tpoolPtr->mutex);

    if (listVar) {
        Tcl_SetVar2Ex(interp, listVar, NULL, waitList, 0);
    }

    Tcl_SetObjResult(interp, doneList);

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolGetObjCmd --
 *
 *  This procedure is invoked to process the "tpool::get" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolGetObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ret, jobId;
    char *tpoolName, *resVar = NULL;
    ThreadPool *tpoolPtr;
    TpoolResult *rPtr;
    Tcl_HashEntry *hPtr;

    /* 
     * Syntax: tpool::get tpoolId jobId ?result?
     */

    if (objc < 3 || objc > 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "tpoolId jobId ?result?");
        return TCL_ERROR;
    }
    if (Tcl_GetIntFromObj(interp, objv[2], &jobId) != TCL_OK) {
        return TCL_ERROR;
    }
    if (objc == 4) {
        resVar = Tcl_GetString(objv[3]);
    }

    /*
     * Locate the threadpool
     */

    tpoolName = Tcl_GetString(objv[1]);
    tpoolPtr  = GetTpool(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName, 
                         "\"", NULL);
        return TCL_ERROR;
    }

    /*
     * Locate the job in question. It is an error to
     * do a "get" on bogus job handle or on the job
     * which did not complete yet.
     */

    Tcl_MutexLock(&tpoolPtr->mutex);
    hPtr = Tcl_FindHashEntry(&tpoolPtr->jobsDone, (char*)jobId);
    if (hPtr == NULL) {
        Tcl_MutexUnlock(&tpoolPtr->mutex);
        Tcl_AppendResult(interp, "no such job", NULL);
        return TCL_ERROR;
    }
    rPtr = (TpoolResult*)Tcl_GetHashValue(hPtr);
    if (rPtr->result == NULL) {
        Tcl_MutexUnlock(&tpoolPtr->mutex);
        Tcl_AppendResult(interp, "job not completed", NULL);
        return TCL_ERROR;
    }

    Tcl_DeleteHashEntry(hPtr);
    Tcl_MutexUnlock(&tpoolPtr->mutex);

    ret = rPtr->retcode;
    SetResult(interp, rPtr);
    Tcl_Free((char*)rPtr);

    if (resVar) {
        Tcl_SetVar2Ex(interp, resVar, NULL, Tcl_GetObjResult(interp), 0);
        Tcl_SetObjResult(interp, Tcl_NewIntObj(ret));
        ret = TCL_OK; 
    }

    return ret;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolReserveObjCmd --
 *
 *  This procedure is invoked to process the "tpool::preserve" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static int
TpoolReserveObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ret;
    char *tpoolName;
    ThreadPool *tpoolPtr;

    /*
     * Syntax: tpool::preserve tpoolId
     */

    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "tpoolId");
        return TCL_ERROR;
    }

    tpoolName = Tcl_GetString(objv[1]);

    Tcl_MutexLock(&listMutex);
    tpoolPtr  = GetTpoolUnl(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_MutexUnlock(&listMutex);
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName, 
                         "\"", NULL);
        return TCL_ERROR;
    }

    ret = TpoolReserve(tpoolPtr); 
    Tcl_MutexUnlock(&listMutex);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(ret));

    return TCL_OK; 
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolReleaseObjCmd --
 *
 *  This procedure is invoked to process the "tpool::release" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static int
TpoolReleaseObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    int ret;
    char *tpoolName;
    ThreadPool *tpoolPtr;

    /*
     * Syntax: tpool::release tpoolId
     */

    if (objc != 2) {
        Tcl_WrongNumArgs(interp, 1, objv, "tpoolId");
        return TCL_ERROR;
    }

    tpoolName = Tcl_GetString(objv[1]);

    Tcl_MutexLock(&listMutex);
    tpoolPtr  = GetTpoolUnl(tpoolName);
    if (tpoolPtr == NULL) {
        Tcl_MutexUnlock(&listMutex);
        Tcl_AppendResult(interp, "can not find threadpool \"", tpoolName,
                         "\"", NULL);
        return TCL_ERROR;
    }

    ret = TpoolRelease(tpoolPtr); 
    Tcl_MutexUnlock(&listMutex);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(ret));

    return TCL_OK; 
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolNamesObjCmd --
 *
 *  This procedure is invoked to process the "tpool::names" Tcl 
 *  command. See the user documentation for details on what it does.
 *
 * Results:
 *  A standard Tcl result.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static int
TpoolNamesObjCmd(dummy, interp, objc, objv)
    ClientData  dummy;          /* Not used. */
    Tcl_Interp *interp;         /* Current interpreter. */
    int         objc;           /* Number of arguments. */
    Tcl_Obj    *CONST objv[];   /* Argument objects. */
{
    ThreadPool *tpoolPtr;
    Tcl_Obj *listObj = Tcl_NewListObj(0, NULL);
    
    Tcl_MutexLock(&listMutex);
    for (tpoolPtr = tpoolList; tpoolPtr; tpoolPtr = tpoolPtr->nextPtr) {
        char buf[32];
        sprintf(buf, "%s%p", TPOOL_HNDLPREFIX, tpoolPtr);
        Tcl_ListObjAppendElement(interp, listObj, Tcl_NewStringObj(buf,-1));
    }
    Tcl_MutexUnlock(&listMutex);
    Tcl_SetObjResult(interp, listObj);

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * CreateWorker --
 *
 *  Creates new worker thread for the given pool. Assumes the caller
 *  hods the pool mutex.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  Informs waiter thread (if any) about the new worker thread.
 *
 *----------------------------------------------------------------------
 */
static int
CreateWorker(interp, tpoolPtr)
    Tcl_Interp *interp;
    ThreadPool *tpoolPtr;
{
    Tcl_ThreadId id;
    TpoolResult result;

    /*
     * Initialize the result structure to be
     * passed to the new thread. This is used
     * as communication to and from the thread.
     */

    memset(&result, 0, sizeof(TpoolResult));
    result.retcode  = -1;
    result.tpoolPtr = tpoolPtr;

    /*
     * Create new worker thread here. Wait for the thread to start 
     * because it's using the ThreadResult arg which is on our stack.
     */

    Tcl_MutexLock(&startMutex);
    if (Tcl_CreateThread(&id, TpoolWorker, (ClientData)&result,
                         TCL_THREAD_STACK_DEFAULT, 0) != TCL_OK) {
        Tcl_SetResult(interp, "can't create a new thread", TCL_STATIC);
        Tcl_MutexUnlock(&startMutex);
        return TCL_ERROR;
    }
    while(result.retcode == -1) {
        Tcl_ConditionWait(&tpoolPtr->cond, &startMutex, NULL);
    }
    Tcl_MutexUnlock(&startMutex);

    /*
     * Set error-related information if the thread
     * failed to initialize correctly.
     */
    
    if (result.retcode == TCL_ERROR) {
        SetResult(interp, &result);
        return TCL_ERROR;
    }

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolWorker --
 *
 *  This is the main function of each of the threads in the pool.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static Tcl_ThreadCreateType
TpoolWorker(clientData)
    ClientData clientData;
{    
    TpoolResult         *rPtr  = (TpoolResult*)clientData;
    ThreadPool       *tpoolPtr = rPtr->tpoolPtr;

    int maj, min, ptch, type, tout = 0;
    Tcl_Interp *interp;
    Tcl_Time waitTime, *idlePtr;
    char *errMsg = "can't create new Tcl interpreter";

    Tcl_MutexLock(&startMutex);

    /*
     * Initialize the Tcl interpreter
     */

#ifdef NS_AOLSERVER
    interp = (Tcl_Interp*)Ns_TclAllocateInterp(NULL);
    rPtr->retcode = TCL_OK;
#else
    interp = Tcl_CreateInterp();
    rPtr->retcode = Tcl_Init(interp);
 
    /*
     *  Tcl_Init() under 8.3.[1,2] and 8.4a1 doesn't work under threads.
     */

    Tcl_GetVersion(&maj, &min, &ptch, &type);
    if (!((maj == 8) && (min == 3) && (ptch <= 2))
        && !((maj == 8) && (min == 4) && (ptch == 1)
             && (type == TCL_ALPHA_RELEASE)) && (rPtr->retcode != TCL_OK)) {
        rPtr->result = strcpy(Tcl_Alloc(strlen(errMsg)+1), errMsg);
        Tcl_ConditionNotify(&tpoolPtr->cond);
        Tcl_MutexUnlock(&startMutex);
        goto out;
    }
    rPtr->retcode = Thread_Init(interp);
#endif
    
    if (rPtr->retcode != TCL_OK) {
        rPtr->result = strcpy(Tcl_Alloc(strlen(errMsg)+1), errMsg);
        Tcl_ConditionNotify(&tpoolPtr->cond);
        Tcl_MutexUnlock(&startMutex);
        goto out;
    }

    /*
     * Initialize the interpreter
     */

    if (tpoolPtr->initScript) {
        TpoolEval(interp, tpoolPtr->initScript, -1, rPtr);
        if (rPtr->retcode != TCL_OK) {
            char *err = (char*)Tcl_GetStringResult(interp);
            rPtr->result = strcpy(Tcl_Alloc(strlen(err)+1), err);
            Tcl_ConditionNotify(&tpoolPtr->cond);
            Tcl_MutexUnlock(&startMutex);
            goto out;
        }
    }

    /*
     * Setup idle timer
     */

    if (tpoolPtr->idleTime == 0) {
        idlePtr = NULL;
    } else {
        waitTime.sec  = tpoolPtr->idleTime;
        waitTime.usec = 0;
        idlePtr = &waitTime;
    }

    /*
     * Tell caller we've started
     */

    tpoolPtr->numWorkers++; 
    Tcl_ConditionNotify(&tpoolPtr->cond);
    Tcl_MutexUnlock(&startMutex);

    /*
     * Wait for jobs to arrive. Note the handcrafted time test.
     * Tcl API misses the return value of the Tcl_ConditionWait.
     * Hence, we do not know why the call returned. Was it someone
     * signalled the variable or has the idle timer expired?
     */

    Tcl_MutexLock(&tpoolPtr->mutex);
    while (!tpoolPtr->tearDown) {
        tpoolPtr->idleWorkers++;
        SignalWaiter(tpoolPtr); /* Another worker available */
        while (!tpoolPtr->tearDown && !tout && !(rPtr = PopWork(tpoolPtr))) {
            Tcl_Time t1,t2;
            GetTime(&t1);
            Tcl_ConditionWait(&tpoolPtr->cond, &tpoolPtr->mutex, idlePtr);
            GetTime(&t2);
            if (tpoolPtr->idleTime) {
                if ((t2.sec - t1.sec) >= tpoolPtr->idleTime) {
                    tout = 1;
                }
            }
        }
        tpoolPtr->idleWorkers--;
        if (tpoolPtr->tearDown || tout) {
            break;
        }
        Tcl_MutexUnlock(&tpoolPtr->mutex);
        TpoolEval(interp, rPtr->script, rPtr->scriptLen, rPtr);
        Tcl_Free(rPtr->script);
        Tcl_MutexLock(&tpoolPtr->mutex);
        if (rPtr->detached) {
            Tcl_Free((char*)rPtr);
        } else {
            int new;
            Tcl_SetHashValue(Tcl_CreateHashEntry(&tpoolPtr->jobsDone, 
                                                 (char*)rPtr->jobId, &new), 
                             (ClientData)rPtr);
        }
    }

    /*
     * Tear down the worker
     */

    if (tpoolPtr->exitScript) {
        TpoolEval(interp, tpoolPtr->exitScript, -1, NULL);
    }

    tpoolPtr->numWorkers--;
    SignalWaiter(tpoolPtr);
    Tcl_MutexUnlock(&tpoolPtr->mutex);

 out:

#ifdef NS_AOLSERVER
    Ns_TclMarkForDelete(interp);
    Ns_TclDeAllocateInterp(interp);
#else
    Tcl_DeleteInterp(interp);
#endif
    Tcl_ExitThread(0);

    TCL_THREAD_CREATE_RETURN;
}

/*
 *----------------------------------------------------------------------
 *
 * RunStopEvent --
 *
 *  Signalizes the waiter thread to stop waiting.
 *
 * Results:
 *  1 (always)
 *
 * Side effects:
 *  None. 
 *
 *----------------------------------------------------------------------
 */
static int
RunStopEvent(eventPtr, mask)
    Tcl_Event *eventPtr; 
    int mask;
{
    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);

    tsdPtr->stop = 1;
    return 1;
}

/*
 *----------------------------------------------------------------------
 *
 * PushWork --
 *
 *  Adds a worker thread to the end of the workers list.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static void
PushWork(rPtr, tpoolPtr)
    TpoolResult *rPtr;
    ThreadPool *tpoolPtr;
{
    SpliceIn(rPtr, tpoolPtr->workHead);
    if (tpoolPtr->workTail == NULL) {
        tpoolPtr->workTail = rPtr;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * PopWork --
 *
 *  Pops the work ticket from the list
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static TpoolResult *
PopWork(tpoolPtr)
    ThreadPool *tpoolPtr;
{   
    TpoolResult *rPtr = tpoolPtr->workTail;

    if (rPtr == NULL) {
        return NULL;
    }

    tpoolPtr->workTail = rPtr->prevPtr;
    SpliceOut(rPtr, tpoolPtr->workHead);

    rPtr->nextPtr = rPtr->prevPtr = NULL;

    return rPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * PushWaiter --
 *
 *  Adds a waiter thread to the end of the waiters list.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static void
PushWaiter(tpoolPtr)
    ThreadPool *tpoolPtr;
{
    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);

    SpliceIn(tsdPtr->waitPtr, tpoolPtr->waitHead);
    if (tpoolPtr->waitTail == NULL) {
        tpoolPtr->waitTail = tsdPtr->waitPtr;
    }
} 

/*
 *----------------------------------------------------------------------
 *
 * PopWaiter --
 *
 *  Pops the first waiter from the head of the waiters list.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static TpoolWaiter*
PopWaiter(tpoolPtr)
    ThreadPool *tpoolPtr;
{
    TpoolWaiter *waitPtr =  tpoolPtr->waitTail;

    if (waitPtr == NULL) {
        return NULL;
    }

    tpoolPtr->waitTail = waitPtr->prevPtr;
    SpliceOut(waitPtr, tpoolPtr->waitHead);

    waitPtr->prevPtr = waitPtr->nextPtr = NULL;

    return waitPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * GetTpool 
 *
 *  Parses the Tcl threadpool handle and locates the
 *  corresponding threadpool maintenance structure. 
 *
 * Results:
 *  Pointer to the threadpool struct or NULL if none found, 
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static ThreadPool* 
GetTpool(tpoolName) 
    char *tpoolName;
{
    ThreadPool *tpoolPtr; 

    Tcl_MutexLock(&listMutex);
    tpoolPtr = GetTpoolUnl(tpoolName);
    Tcl_MutexUnlock(&listMutex);

    return tpoolPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * GetTpoolUnl 
 *
 *  Parses the threadpool handle and locates the
 *  corresponding threadpool maintenance structure. 
 *  Assumes caller holds the listMutex,
 *
 * Results:
 *  Pointer to the threadpool struct or NULL if none found, 
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */

static ThreadPool* 
GetTpoolUnl (tpoolName) 
    char *tpoolName;
{
    ThreadPool *tpool;
    ThreadPool *tpoolPtr = NULL;

    if (sscanf(tpoolName, TPOOL_HNDLPREFIX"%p", &tpool) != 1) {
        return NULL;
    }
    for (tpoolPtr = tpoolList; tpoolPtr; tpoolPtr = tpoolPtr->nextPtr) {
        if (tpoolPtr == tpool) {
            break;
        }
    }

    return tpoolPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolEval 
 *
 *  Evaluates the script and fills in the result structure. 
 *
 * Results:
 *  Standard Tcl result, 
 *
 * Side effects:
 *  Many, depending on the script.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolEval(interp, script, scriptLen, rPtr)
    Tcl_Interp *interp;
    char *script;
    int scriptLen;
    TpoolResult *rPtr;
{
    int ret, reslen;
    char *result, *errorCode, *errorInfo;
    
    ret = Tcl_EvalEx(interp, script, scriptLen, TCL_EVAL_GLOBAL);
    if (rPtr == NULL || rPtr->detached) {
        return ret;
    }
    rPtr->retcode = ret;
    if (ret == TCL_ERROR) {
        errorCode = (char*)Tcl_GetVar(interp, "errorCode", TCL_GLOBAL_ONLY);
        errorInfo = (char*)Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY);
        if (errorCode != NULL) {
            rPtr->errorCode = Tcl_Alloc(1 + strlen(errorCode));
            strcpy(rPtr->errorCode, errorCode);
        }
        if (errorInfo != NULL) {
            rPtr->errorInfo = Tcl_Alloc(1 + strlen(errorInfo));
            strcpy(rPtr->errorInfo, errorInfo);
        }
    }
    
    result = (char*)Tcl_GetStringResult(interp);
    reslen = strlen(result);
    
    if (reslen == 0) {
        rPtr->result = threadEmptyResult;
    } else {
        rPtr->result = strcpy(Tcl_Alloc(1 + reslen), result);
    }

    return ret;
}

/*
 *----------------------------------------------------------------------
 *
 * SetResult
 *
 *  Sets the result in current interpreter.
 *
 * Results:
 *  Standard Tcl result, 
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static void
SetResult(interp, rPtr)
    Tcl_Interp *interp;
    TpoolResult *rPtr;
{
    if (rPtr->result) {
        if (rPtr->result == threadEmptyResult) {
            if (interp) {
                Tcl_ResetResult(interp);
            }
        } else {
            if (interp) {
                Tcl_SetObjResult(interp, Tcl_NewStringObj(rPtr->result,-1));
            }
            Tcl_Free(rPtr->result);
            rPtr->result = NULL;
        }
    }
    if (rPtr->retcode == TCL_ERROR) {
        if (rPtr->errorCode) {
            if (interp) {
                Tcl_SetObjErrorCode(interp,Tcl_NewStringObj(rPtr->errorCode,-1));
            }
            Tcl_Free(rPtr->errorCode);
            rPtr->errorCode = NULL;
        }
        if (rPtr->errorInfo) {
            if (interp) {
                Tcl_AddObjErrorInfo(interp, rPtr->errorInfo, -1);
            }
            Tcl_Free(rPtr->errorInfo);
            rPtr->errorInfo = NULL;
        }
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolReserve --
 *
 *  Does the pool preserve and/or release. Assumes caller holds 
 *  the listMutex.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  May tear-down the threadpool if refcount drops to 0 or below.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolReserve(tpoolPtr)
    ThreadPool *tpoolPtr;
{
    return ++tpoolPtr->refCount;
}

/*
 *----------------------------------------------------------------------
 *
 * TpoolRelease --
 *
 *  Does the pool preserve and/or release. Assumes caller holds 
 *  the listMutex.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  May tear-down the threadpool if refcount drops to 0 or below.
 *
 *----------------------------------------------------------------------
 */
static int
TpoolRelease(tpoolPtr)
    ThreadPool *tpoolPtr;
{
    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);
    TpoolResult *rPtr;
    Tcl_HashEntry *hPtr;
    Tcl_HashSearch search;

    if (--tpoolPtr->refCount > 0) { 
        return tpoolPtr->refCount;
    }

    /*
     * Pool is going away; remove from the list of pools,
     */ 
    
    SpliceOut(tpoolPtr, tpoolList);
    InitWaiter();
    
    /*
     * Signal and wait for all workers to die.
     */
    
    tpoolPtr->tearDown = 1;
    Tcl_MutexLock(&tpoolPtr->mutex);
    while (tpoolPtr->numWorkers > 0) {
        PushWaiter(tpoolPtr);
        Tcl_ConditionNotify(&tpoolPtr->cond);
        Tcl_MutexUnlock(&tpoolPtr->mutex);
        tsdPtr->stop = -1;
        while(tsdPtr->stop == -1) {
            Tcl_DoOneEvent(TCL_ALL_EVENTS);
        }
        Tcl_MutexLock(&tpoolPtr->mutex);
    }
    Tcl_MutexUnlock(&tpoolPtr->mutex);
    
    /*
     * Tear down the pool structure
     */
    
    if (tpoolPtr->initScript) {
        Tcl_Free(tpoolPtr->initScript);
    }
    if (tpoolPtr->exitScript) {
        Tcl_Free(tpoolPtr->exitScript);
    }

    /*
     * Cleanup completed but not collected jobs
     */

    hPtr = Tcl_FirstHashEntry(&tpoolPtr->jobsDone, &search);
    while (hPtr != NULL) {
        rPtr = (TpoolResult*)Tcl_GetHashValue(hPtr);
        if (rPtr->result && rPtr->result != threadEmptyResult) {
            Tcl_Free(rPtr->result);
        }
        if (rPtr->retcode == TCL_ERROR) {
            if (rPtr->errorInfo) {
                Tcl_Free(rPtr->errorInfo);
            }
            if (rPtr->errorCode) {
                Tcl_Free(rPtr->errorCode);
            }
        }
        Tcl_Free((char*)rPtr);
        Tcl_DeleteHashEntry(hPtr);
        hPtr = Tcl_NextHashEntry(&search);
    }
    Tcl_DeleteHashTable(&tpoolPtr->jobsDone);

    /*
     * Cleanup jobs posted but never completed.
     */

    for (rPtr = tpoolPtr->workHead; rPtr; rPtr = rPtr->nextPtr) {
        Tcl_Free(rPtr->script);
        Tcl_Free((char*)rPtr);
    }
    Tcl_MutexFinalize(&tpoolPtr->mutex);
    Tcl_ConditionFinalize(&tpoolPtr->cond);
    Tcl_Free((char*)tpoolPtr);
    
    return 0;
}

/*
 *----------------------------------------------------------------------
 *
 * SignalWaiter --
 *
 *  Signals the waiter thread.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  The waiter thread will exit from the event loop.
 *
 *----------------------------------------------------------------------
 */
static void
SignalWaiter(tpoolPtr)
    ThreadPool *tpoolPtr;
{
    TpoolWaiter *waitPtr;
    Tcl_Event *evPtr;

    waitPtr = PopWaiter(tpoolPtr);
    if (waitPtr == NULL) {
        return;
    }

    evPtr = (Tcl_Event*)Tcl_Alloc(sizeof(Tcl_Event));
    evPtr->proc = RunStopEvent;

    Tcl_ThreadQueueEvent(waitPtr->threadId,(Tcl_Event*)evPtr,TCL_QUEUE_TAIL);
    Tcl_ThreadAlert(waitPtr->threadId);
}

/*
 *----------------------------------------------------------------------
 *
 * InitWaiter --
 *
 *  Setup poster thread to be able to wait in the event loop.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static void
InitWaiter ()
{
    ThreadSpecificData *tsdPtr = TCL_TSD_INIT(&dataKey);

    if (tsdPtr->waitPtr == NULL) {
        tsdPtr->waitPtr = (TpoolWaiter*)Tcl_Alloc(sizeof(TpoolWaiter));
        tsdPtr->waitPtr->prevPtr  = NULL;
        tsdPtr->waitPtr->nextPtr  = NULL;
        tsdPtr->waitPtr->threadId = Tcl_GetCurrentThread();
        Tcl_CreateThreadExitHandler(ThrExitHandler, (ClientData)tsdPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * ThrExitHandler --
 *
 *  Performs cleanup when a caller (poster) thread exits.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static void
ThrExitHandler(clientData)
    ClientData clientData;
{
    ThreadSpecificData *tsdPtr = (ThreadSpecificData *)clientData;

    Tcl_Free((char*)tsdPtr->waitPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * AppExitHandler 
 *
 *  Deletes all threadpools on application exit.
 *
 * Results:
 *  None. 
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
static void
AppExitHandler(clientData)
    ClientData clientData;
{
    ThreadPool *tpoolPtr;

    Tcl_MutexLock(&listMutex);
    for (tpoolPtr = tpoolList; tpoolPtr; tpoolPtr = tpoolPtr->nextPtr) {
        TpoolRelease(tpoolPtr);
    }
    Tcl_MutexUnlock(&listMutex);
}

/*
 *----------------------------------------------------------------------
 *
 * GetTime --
 *
 *  Wrapper for the Tcl_GetTime which is not available for 8.3.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  None.
 *
 *----------------------------------------------------------------------
 */
#ifdef __WIN32__
#include <sys/timeb.h>
#else
#include <sys/time.h>
#endif
static void
GetTime(timePtr)
    Tcl_Time *timePtr;
{
#ifdef __WIN32__
    struct timeb tb;
    (void)ftime(&tb);
    timePtr->sec  = tb.time;
    timePtr->usec = tb.millitm * 1000;
#else
    struct timeval tv;
    (void)gettimeofday(&tv, NULL);
    timePtr->sec  = tv.tv_sec;
    timePtr->usec = tv.tv_usec;
#endif
}

/*
 *----------------------------------------------------------------------
 *
 * Tpool_Init --
 *
 *  Create commands in current interpreter.
 *
 * Results:
 *  None.
 *
 * Side effects:
 *  On first load, creates application exit handler to clean up
 *  any threadpools left.
 *
 *----------------------------------------------------------------------
 */

int 
Tpool_Init (interp)
    Tcl_Interp *interp;                 /* Interp where to create cmds */
{
    static int initialized;

    TCL_CMD(interp, TPNS"create",   TpoolCreateObjCmd);
    TCL_CMD(interp, TPNS"names",    TpoolNamesObjCmd);
    TCL_CMD(interp, TPNS"post",     TpoolPostObjCmd);
    TCL_CMD(interp, TPNS"wait",     TpoolWaitObjCmd);
    TCL_CMD(interp, TPNS"cancel",   TpoolCancelObjCmd);
    TCL_CMD(interp, TPNS"get",      TpoolGetObjCmd);
    TCL_CMD(interp, TPNS"preserve", TpoolReserveObjCmd);
    TCL_CMD(interp, TPNS"release",  TpoolReleaseObjCmd);

    if (initialized == 0) {
        Tcl_MutexLock(&listMutex);
        if (initialized == 0) {
            Tcl_CreateExitHandler(AppExitHandler, (ClientData)-1);
            initialized = 1;
        }
        Tcl_MutexUnlock(&listMutex);
    }
    return TCL_OK;
}

/* EOF $RCSfile: threadPoolCmd.c,v $ */

/* Emacs Setup Variables */
/* Local Variables:      */
/* mode: C               */
/* indent-tabs-mode: nil */
/* c-basic-offset: 4     */
/* End:                  */
