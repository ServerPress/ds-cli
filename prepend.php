<?php
/**
 * Create a menu item within our localhost tools pull down menu.
 */
global $ds_runtime;
if ( !$ds_runtime->is_localhost ) return; // Not localhost
if ( $ds_runtime->last_ui_event !== false ) return; // Not interested in events

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