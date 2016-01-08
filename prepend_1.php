<?php
global $ds_runtime;
if ( $ds_runtime->last_ui_event !== false ) {

	/**
	 * Obtain the sitePath for the destination/current site folder.
	 */
	global $ds_cli_site_path;
	$ds_cli_site_path = '';
	$siteName = '';
	if ( in_array( $ds_runtime->last_ui_event->action, array( 'site_created', 'site_imported', 'site_exported', 'site_deployed', 'site_removed' ) ) ) {
		$siteName = $ds_runtime->last_ui_event->info[0];
	}
	if ( in_array( $ds_runtime->last_ui_event->action, array( 'site_copied', 'site_moved' ) ) ) {
		$siteName = $ds_runtime->last_ui_event->info[1];
	}
	if ( $siteName !== '' ) {
		$ds_cli_site_path = $ds_runtime->preferences->sites->{$siteName}->sitePath;
	}

	/**
	 * Execute the given cross-platform bash command on the DS_CLI shell.
	 *
	 * @param $bash The bash command to execute.
	 * @param bool|false $cwd optional current working directory, default is destination site path
	 */
	function ds_cli_exec( $bash, $cwd = false ) {
		global $ds_cli_site_path;
		global $ds_runtime;

		if ( false === $cwd ) {
			if ( $ds_cli_site_path !== '' ) {
				$bash = 'cd ' . $ds_cli_site_path . ';' . $bash;
			}
		}else{
			$bash = 'cd ' . $cwd . ';' . $bash;
		}
		if ( PHP_OS !== 'Darwin' ) {
			$bash = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/boot.bat bash -- " . $bash; // Windows
		}else{
			$bash = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/mac/boot.sh " . $bash;	// Mac
		}
		exec( $bash );
	}
	$ds_runtime->add_action( 'ds_cli_exec', 'ds_cli_exec' );

	/**
	 * Fix symbolic links on Windows core DS-CLI files when server starts and on site folders when created/imported.
	 */
	if ( PHP_OS !== 'Darwin' ) {
		if ( $ds_runtime->last_ui_event->action === 'site_created' || $ds_runtime->last_ui_event->action === 'site_imported' ) {
			ds_cli_exec( "symfix " . $ds_cli_site_path );
		}
		if ( $ds_runtime->last_ui_event->action === 'start_services' ) {
			$cygwin = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/cygwin";
			ds_cli_exec( "symfix " . $cygwin . "/etc" );
			ds_cli_exec( "symfix " . $cygwin . "/lib" );
			ds_cli_exec( "symfix " . $cygwin . "/bin" );
			ds_cli_exec( "symfix " . $cygwin . "/usr" );
			ds_cli_exec( "symfix " . $cygwin . "/Users" );
		}
	}
	/**
	 * Execute blueprint.php script if present.
	 */
	if ( $ds_runtime->last_ui_event->action === 'site_created' ) {
		if ( is_file ( $ds_cli_site_path . '/blueprint.php' ) ) {
			include_once( $ds_cli_site_path . '/blueprint.php' );
		}
	}

	return; // Remainder code not interested in events
}
if ( !$ds_runtime->is_localhost ) return; // Not localhost

/**
 * Create a menu item within our localhost tools pull down menu.
 * Add our menu to the localhost page.
 */
$ds_runtime->add_action( 'ds_head', 'ds_cli_head' );
function ds_cli_head() {
	global $ds_runtime;
	echo '<link href="http://localhost/ds-plugins/ds-cli/fontello/css/serverpress.css" rel="stylesheet">';
	echo '<link href="http://localhost/ds-plugins/ds-cli/css/localhost.css" rel="stylesheet">';
	echo '<script src="http://localhost/js/jquery.min.js"></script>';
}

$ds_runtime->add_action( 'ds_footer', 'ds_cli_localhost_scripts' );
function ds_cli_localhost_scripts() {
	echo '<script src="http://localhost/ds-plugins/ds-cli/js/localhost.js" rel="stylesheet"></script>';
}

$ds_runtime->add_action( 'list_domain', 'ds_cli_list_domain_link' );
function ds_cli_list_domain_link( $domain ) {
	echo '<div class="ds-site-actions-container">';
	echo '<a href="http://localhost/ds-plugins/ds-cli/ds-launch-cli.php" data-domain="'.$domain.'" class="ds-cli ds-action">DS CLI</a>';
	echo '</div>';
}
