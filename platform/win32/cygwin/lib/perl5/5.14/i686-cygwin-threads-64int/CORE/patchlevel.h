/*    patchlevel.h
 *
 *    Copyright (C) 1993, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002,
 *    2003, 2004, 2005, 2006, 2007, 2008, 2009, by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 */

#ifndef __PATCHLEVEL_H_INCLUDED__

/* do not adjust the whitespace! Configure expects the numbers to be
 * exactly on the third column */

#define PERL_REVISION	5		/* age */
#define PERL_VERSION	14		/* epoch */
#define PERL_SUBVERSION	4		/* generation */

/* The following numbers describe the earliest compatible version of
   Perl ("compatibility" here being defined as sufficient binary/API
   compatibility to run XS code built with the older version).
   Normally this should not change across maintenance releases.

   Note that this only refers to an out-of-the-box build.  Many non-default
   options such as usemultiplicity tend to break binary compatibility
   more often.

   This is used by Configure et al to figure out
   PERL_INC_VERSION_LIST, which lists version libraries
   to include in @INC.  See INSTALL for how this works.

   Porting/bump-perl-version will automatically set these to the version of perl
   to be released for blead releases, and to 5.X.0 for maint releases. Manually
   changing them should not be necessary.
*/
#define PERL_API_REVISION	5
#define PERL_API_VERSION	14
#define PERL_API_SUBVERSION	0
/*
   XXX Note:  The selection of non-default Configure options, such
   as -Duselonglong may invalidate these settings.  Currently, Configure
   does not adequately test for this.   A.D.  Jan 13, 2000
*/

#define __PATCHLEVEL_H_INCLUDED__
#endif

/*
	local_patches -- list of locally applied less-than-subversion patches.
	If you're distributing such a patch, please give it a name and a
	one-line description, placed just before the last NULL in the array
	below.  If your patch fixes a bug in the perlbug database, please
	mention the bugid.  If your patch *IS* dependent on a prior patch,
	please place your applied patch line after its dependencies. This
	will help tracking of patch dependencies.

	Please either use 'diff --unified=0' if your diff supports
	that or edit the hunk of the diff output which adds your patch
	to this list, to remove context lines which would give patch
	problems. For instance, if the original context diff is

	   *** patchlevel.h.orig	<date here>
	   --- patchlevel.h	<date here>
	   *** 38,43 ***
	   --- 38,44 ---
	     	,"FOO1235 - some patch"
	     	,"BAR3141 - another patch"
	     	,"BAZ2718 - and another patch"
	   + 	,"MINE001 - my new patch"
	     	,NULL
	     };

	please change it to
	   *** patchlevel.h.orig	<date here>
	   --- patchlevel.h	<date here>
	   *** 41,43 ***
	   --- 41,44 ---
	   + 	,"MINE001 - my new patch"
	     	,NULL
	     };

	(Note changes to line numbers as well as removal of context lines.)
	This will prevent patch from choking if someone has previously
	applied different patches than you.

        History has shown that nobody distributes patches that also
        modify patchlevel.h. Do it yourself. The following perl
        program can be used to add a comment to patchlevel.h:

#!perl
die "Usage: perl -x patchlevel.h comment ..." unless @ARGV;
open PLIN, "patchlevel.h" or die "Couldn't open patchlevel.h : $!";
open PLOUT, ">patchlevel.new" or die "Couldn't write on patchlevel.new : $!";
my $seen=0;
while (<PLIN>) {
    if (/\t,NULL/ and $seen) {
       while (my $c = shift @ARGV){
	    $c =~ s|\\|\\\\|g;
	    $c =~ s|"|\\"|g;
            print PLOUT qq{\t,"$c"\n};
       }
    }
    $seen++ if /local_patches\[\]/;
    print PLOUT;
}
close PLOUT or die "Couldn't close filehandle writing to patchlevel.new : $!";
close PLIN or die "Couldn't close filehandle reading from patchlevel.h : $!";
close DATA; # needed to allow unlink to work win32.
unlink "patchlevel.bak" or warn "Couldn't unlink patchlevel.bak : $!"
  if -e "patchlevel.bak";
rename "patchlevel.h", "patchlevel.bak" or
  die "Couldn't rename patchlevel.h to patchlevel.bak : $!";
rename "patchlevel.new", "patchlevel.h" or
  die "Couldn't rename patchlevel.new to patchlevel.h : $!";
__END__

Please keep empty lines below so that context diffs of this file do
not ever collect the lines belonging to local_patches() into the same
hunk.

 */

#if !defined(PERL_PATCHLEVEL_H_IMPLICIT) && !defined(LOCAL_PATCH_COUNT)
#  if defined(PERL_IS_MINIPERL)
#    define PERL_PATCHNUM "UNKNOWN-miniperl"
#    define PERL_GIT_UNPUSHED_COMMITS /*leave-this-comment*/
#  elif defined(PERL_MICRO)
#    define PERL_PATCHNUM "UNKNOWN-microperl"
#    define PERL_GIT_UNPUSHED_COMMITS /*leave-this-comment*/
#  else
#include "git_version.h"
#  endif
static const char * const local_patches[] = {
	NULL
#ifdef PERL_GIT_UNCOMMITTED_CHANGES
	,"uncommitted-changes"
#endif
	PERL_GIT_UNPUSHED_COMMITS    	/* do not remove this line */
        ,"rurban/0c612ce82        Fix building static extensions on cygwin, -UUSEIMPORTLIB"
        ,"perl.cygwin_autorebase  Rebase DLL after building (skip for cygport builds)"
        ,"v5.14.0-RC2-6-gfc6f691  skip testing cygwin utf8 readdir() with Win32 ANSI API"
        ,"v5.14.0-RC2-7-g3877b86  Fix test 50 on cygwin: \\WINDOWS"
        ,"v5.14.0-RC2-10-gd22b5bd revert +x global.sym from 3691eaa79cc6a"
        ,"v5.15.0-579-g8375c93    Export store_cop_label for the perl compiler"
        ,"v5.15.3-232-g1bac5ec    sv.c: S_anonymise_cv_maybe UTF8 cleanup."
        ,"v5.15.7-75-g803e389     CYG17 utf8 paths"
        ,"v5.15.7-302-g5bc802d    Revise perlcygwin.pod for cygwin-1.7"
        ,"v5.15.7-303-g286f819    add Cygwin::sync_winenv [perl #110190]"
        ,"v5.19.8-494-g6cc44f6    avoid a \"FILE\" name conflict with cygwin's wchar.h"
        ,"v5.19.8-496-g3383030    [perl #120936] op/taint.t handling of no ipcsysv on cygwin"
        ,"v5.19.8-509-g288d0d9    cygwin doesn't implement $^E (except as a read of $!)"
        ,"v5.21.4-548-g860874c    wrap the failing call_checker test in an eval and TODO it"
	,NULL
};



/* Initial space prevents this variable from being inserted in config.sh  */
#  define	LOCAL_PATCH_COUNT	\
	((int)(sizeof(local_patches)/sizeof(local_patches[0])-2))

/* the old terms of reference, add them only when explicitly included */
#define PATCHLEVEL		PERL_VERSION
#undef  SUBVERSION		/* OS/390 has a SUBVERSION in a system header */
#define SUBVERSION		PERL_SUBVERSION
#endif
