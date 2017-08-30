<?php
global $ds_runtime;
if ( ! empty( $_REQUEST['domain'] ) ) {
	$cwd = @$ds_runtime->preferences->sites->{ $_REQUEST['domain'] }->sitePath;
	ds_launch_cli( $cwd );
}

/**
 * Launch the native Console/Terminal CLI window within the given folder.
 * Used by both the localhost page and the admin menu bar.
 *
 * @param $cwd The current working directory.
 */
function ds_launch_cli( $cwd ) {
	 global $ds_runtime;
	 if ( PHP_OS !== 'Darwin' ){
	 	// Windows
		$launch = getenv('DS_RUNTIME') . "\\bootstrap\\boot-win32.bat ";
		if ( strpos( $cwd, ':' ) === 1 ) {
			$launch .= substr( $cwd, 0, 2) . " &";
		}
		$launch .= "cd \"" . $cwd . "\" &";
		$launch .= "del %USERPROFILE%\\.bash_history &";
		$launch .= getenv("DS_RUNTIME") . "\\platform\\win32\\cygwin\\bin\\mintty";


		// Clean up user folder by hiding dot folders and files.
		$files = scandir( getenv('USERPROFILE') );
		foreach( $files as $dot ) {
			if ( substr( $dot, 0, 1 ) === '.' && $dot !== '.' && $dot !== '..' ) {
				exec( 'attrib +H "' . getenv('USERPROFILE') . "\\" . $dot . '"' );
			}
		}
	 } else{
	 	// Macintosh
    $launch = "osascript -e '";
    $launch .= "tell application \"Terminal\"\n";
    $launch .= "  do script \"\n";
    $launch .= "    source " . getenv('DS_RUNTIME') . "/bootstrap/boot-mac.sh cd \\\"$cwd\\\";clear;history -c";
    $launch .= "  \"\n";
    $launch .= "  activate\n";
    $launch .= "end tell'\n";
  }
	global $ds_launch_cli;
	$ds_launch_cli = $launch;
	$ds_runtime->do_action( 'pre_ds_launch_cli' );
  exec( $ds_launch_cli );
}
