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

		$launch = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/boot.bat ";
		$launch .= "cd \"" . $cwd . "\" &";
		$launch .= "del %USERPROFILE%\\.bash_history &";
		$launch .= "c:\\xampplite\\ds-plugins\\ds-cli\\platform\\win32\\cygwin\\bin\\mintty";
	} else{
		// Macintosh
		$launch = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/mac/boot.sh ";
		$launch .= "osascript -e '";
		$launch .= "tell application \"Terminal\"\n";
		$launch .= "  do script \"\n";
		$launch .= "    source " . $ds_runtime->ds_plugins_dir . "/ds-cli/platform/mac/boot.sh" . "\n";
		$launch .= "    cd \\\"" . $cwd . "\\\"\n";
		$launch .= "    clear;history -c\"\n";
		$launch .= "  activate\n";
		$launch .= "end tell\n";
		$launch .= "'";
	}
	$ds_runtime->do_action( 'pre_ds_launch_cli', $launch );
	exec( $launch );
}
