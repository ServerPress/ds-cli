--- src/hostapi/coreaudio/pa_mac_core.c.orig	2013-08-29 09:36:56.000000000 +0900
+++ src/hostapi/coreaudio/pa_mac_core.c	2014-02-01 13:00:46.000000000 +0900
@@ -1158,8 +1158,8 @@
                                    const double sampleRate,
                                    void *refCon )
 {
-    ComponentDescription desc;
-    Component comp;
+    AudioComponentDescription desc;
+    AudioComponent comp;
     /*An Apple TN suggests using CAStreamBasicDescription, but that is C++*/
     AudioStreamBasicDescription desiredFormat;
     OSStatus result = noErr;
@@ -1230,7 +1230,7 @@
     desc.componentFlags        = 0;
     desc.componentFlagsMask    = 0;
     /* -- find the component -- */
-    comp = FindNextComponent( NULL, &desc );
+    comp = AudioComponentFindNext( NULL, &desc );
     if( !comp )
     {
        DBUG( ( "AUHAL component not found." ) );
@@ -1239,7 +1239,7 @@
        return paUnanticipatedHostError;
     }
     /* -- open it -- */
-    result = OpenAComponent( comp, audioUnit );
+    result = AudioComponentInstanceNew( comp, audioUnit );
     if( result )
     {
        DBUG( ( "Failed to open AUHAL component." ) );
@@ -1592,7 +1592,7 @@
 #undef ERR_WRAP
 
     error:
-       CloseComponent( *audioUnit );
+       AudioComponentInstanceDispose( *audioUnit );
        *audioUnit = NULL;
        if( result )
           return PaMacCore_SetError( result, line, 1 );
@@ -2613,13 +2613,13 @@
        }
        if( stream->outputUnit && stream->outputUnit != stream->inputUnit ) {
           AudioUnitUninitialize( stream->outputUnit );
-          CloseComponent( stream->outputUnit );
+          AudioComponentInstanceDispose( stream->outputUnit );
        }
        stream->outputUnit = NULL;
        if( stream->inputUnit )
        {
           AudioUnitUninitialize( stream->inputUnit );
-          CloseComponent( stream->inputUnit );
+          AudioComponentInstanceDispose( stream->inputUnit );
           stream->inputUnit = NULL;
        }
        if( stream->inputRingBuffer.buffer )
@@ -2679,12 +2679,12 @@
 
 // it's not clear from appl's docs that this really waits
 // until all data is flushed.
-static ComponentResult BlockWhileAudioUnitIsRunning( AudioUnit audioUnit, AudioUnitElement element )
+static OSStatus BlockWhileAudioUnitIsRunning( AudioUnit audioUnit, AudioUnitElement element )
 {
     Boolean isRunning = 1;
     while( isRunning ) {
        UInt32 s = sizeof( isRunning );
-       ComponentResult err = AudioUnitGetProperty( audioUnit, kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, element,  &isRunning, &s );
+       OSStatus err = AudioUnitGetProperty( audioUnit, kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, element,  &isRunning, &s );
        if( err )
           return err;
        Pa_Sleep( 100 );
