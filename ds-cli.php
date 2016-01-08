<?php
/*
Plugin Name: DS-CLI
Plugin URI: https://serverpress.com/ds-cli
Description: DS-CLI is an enhanced, cross-platform, command line interface for professional WordPress developers. Users can easily start working with CLI tools such as WordShell or the included WP-CLI, Composer, Git, and PHPUnit. NodeJS and NPM are included to allow installation of GRUNT, Gulp, and other Node dependencies.
Author: Stephen J. Carnam
Version: 1.0.0
*/

require __DIR__ . '/vendor/autoload.php';

use Steveorevo\String;
use Steveorevo\WP_Hooks;
include_once( 'ds-launch-cli.php' );

/**
 * Lets get started
 */
class DS_CLI extends WP_Hooks {

	/**
	 * Include our admin interface icons from DS4 core
	 */
	function admin_enqueue_scripts() {
		$this->enqueue_scripts();
	}
	function wp_enqueue_scripts() {
		$this->enqueue_scripts();
	}
	private function enqueue_scripts() {
		$url = new String( site_url() );
		$url = $url->getLeftMost( '.dev' )->concat( '.dev/ds-plugins/ds-cli' )->__toString();
		wp_enqueue_style( 'serverpress', $url .  '/fontello/css/serverpress.css' );
		wp_enqueue_style( 'sp-animation', $url .  '/fontello/css/animation.css' );
		wp_enqueue_script( 'ds-cli', $url . '/js/ds-cli.js', array( 'jquery' ) );
		wp_localize_script( 'ds-cli', 'ds_cli', array(
			'ajaxurl' => admin_url( 'admin-ajax.php' ),
			'nonce' => wp_create_nonce( 'ds-cli-nonce' )
		) );
	}


	/**
	 * Include our CLI icon on the toolbar
	 */
	public function admin_print_styles() {
		// Require that user have manage options
		if ( ! current_user_can( 'manage_options' ) ) return;
		?>
		<style type="text/css">
			li#wp-admin-bar-ds-cli .ab-icon:before {
				font-family: 'serverpress';
				position: relative;
				font-size: small;
				content: '\e824';
				top: -3px;
			}
		</style>
		<?php
	}

	/**
	 * Include icon when login and on front end
	 */
	public function wp_head() {
		if ( is_user_logged_in() ) {
			$this->admin_print_styles();
		}
	}

	/**
	 * Add our Dev-CLI button to the interface button
	 */
	public function admin_bar_menu_180( WP_Admin_Bar $wp_admin_bar ) {

		// Require that user have manage options
		if ( ! current_user_can( 'manage_options' ) ) return;

		// Add the DS-CLI admin bar button
		$wp_admin_bar->add_menu(
			array(
				'id'        => 'ds-cli',
				'title'     => '<span class="ab-icon"></span><span class="ab-label">DS-CLI</span>',
				'href'      => '#ds-cli',
				'meta'      => array(
					'class' => 'ds-cli',
					'title' 	=> 'DesktopServer Command Line Interface'
				)
			)
		);
	}



	/**
	 * Launch our CLI in the context of the given WordPress development site
	 */
	public function wp_ajax_ds__cli__submit() {
		if ( ! wp_verify_nonce( $_POST['nonce'], 'ds-cli-nonce' ) ) return;
		ds_launch_cli( ABSPATH );
		exit();
	}
}
global $ds_runtime;
$ds_runtime->ds_cli = new DS_CLI();
