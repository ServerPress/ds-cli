<?php
global $ds_runtime;
$domain = $_REQUEST['domain'];
$abspath = @$ds_runtime->preferences->sites->{$domain}->sitePath;
if ( empty( $abspath ) ) {
	die( 'Domain does not exist' );
}

if ( PHP_OS !== 'Darwin' ){
	// Windows
	$launch = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/boot.bat ";
	$launch .= "cd \"" . $abspath . "\" &";
	$launch .= "c:\\xampplite\\ds-plugins\\ds-cli\\platform\\win32\\cygwin\\bin\\mintty";
} else{
	// Macintosh
	$launch = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/mac/boot.sh ";
	$launch .= "osascript -e '";
	$launch .= "tell application \"Terminal\"\n";
	$launch .= "  do script \"\n";
	$launch .= "    source " . $ds_runtime->ds_plugins_dir . "/ds-cli/platform/mac/boot.sh" . "\n";
	$launch .= "    cd \\\"" . $abspath . "\\\"\n";
	$launch .= "    clear\"\n";
	$launch .= "  activate\n";
	$launch .= "end tell\n";
	$launch .= "'";
}
echo '<pre>'.print_r($launch, true).'</pre>';
exec( $launch );
exit();