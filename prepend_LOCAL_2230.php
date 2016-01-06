<?php
/**
 * Create a menu item within our localhost tools pull down menu.
 */
global $ds_runtime;
if ( !$ds_runtime->is_localhost ) return; // Not localhost
if ( $ds_runtime->last_ui_event !== false ) {
	/**
	 * Recursively search and fix symbolic links for the given Windows folder.
	 */
	function ds_cli_symfix( $folder ) {
		global $ds_runtime;
		if ( PHP_OS === 'Darwin' ) return; // Windows only
		$cmd = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/boot.bat bash -- symfix $folder";
		exec( $cmd );
	}

	/**
	 * Fix symbolic links on Windows core DS-CLI files.
	 */
	if ( $ds_runtime->last_ui_event->action === 'start_services' ) {
		$cygwin = $ds_runtime->ds_plugins_dir . "/ds-cli/platform/win32/cygwin";
		ds_cli_symfix( $cygwin . "/etc" );
		ds_cli_symfix( $cygwin . "/lib" );
		ds_cli_symfix( $cygwin . "/bin" );
		ds_cli_symfix( $cygwin . "/usr" );
	}

	/**
	 * Process composer files in blueprints when a site is created and fix any symbolic links.
	 */
	if ( $ds_runtime->last_ui_event->action === 'site_created' ) {
		trace("site_created");
		ds_cli_fix_win_symbolic_links( '/folder' );
	}
	return; // Remainder code not interested in events
}

/**
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
	echo '<a href="http://localhost/ds-plugins/ds-cli/launch-ds-cli.php" data-domain="'.$domain.'" class="ds-cli ds-action">DS CLI</a>';
	echo '</div>';
}
