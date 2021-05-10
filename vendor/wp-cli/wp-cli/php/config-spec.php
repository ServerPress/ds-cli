<?php

return array(
	'path'              => array(
		'runtime' => '=<path>',
		'file'    => '<path>',
		'desc'    => 'Path to the WordPress files.',
	),

	'url'               => array(
		'runtime' => '=<url>',
		'file'    => '<url>',
		'desc'    => 'Pretend request came from given URL. In multisite, this argument is how the target site is specified.',
	),

	'ssh'               => array(
		'runtime' => '=[<scheme>:][<user>@]<host|container>[:<port>][<path>]',
		'file'    => '[<scheme>:][<user>@]<host|container>[:<port>][<path>]',
		'desc'    => 'Perform operation against a remote server over SSH (or a container using scheme of "docker", "docker-compose", "vagrant").',
	),

	'http'              => array(
		'runtime' => '=<http>',
		'file'    => '<http>',
		'desc'    => 'Perform operation against a remote WordPress installation over HTTP.',
	),

	'blog'              => array(
		'deprecated' => 'Use --url instead.',
		'runtime'    => '=<url>',
	),

	'user'              => array(
		'runtime' => '=<id|login|email>',
		'file'    => '<id|login|email>',
		'desc'    => 'Set the WordPress user.',
	),

	'skip-plugins'      => array(
		'runtime' => '[=<plugins>]',
		'file'    => '<list>',
		'desc'    => 'Skip loading all plugins, or a comma-separated list of plugins. Note: mu-plugins are still loaded.',
		'default' => '',
	),

	'skip-themes'       => array(
		'runtime' => '[=<themes>]',
		'file'    => '<list>',
		'desc'    => 'Skip loading all themes, or a comma-separated list of themes.',
		'default' => '',
	),

	'skip-packages'     => array(
		'runtime' => '',
		'file'    => '<bool>',
		'desc'    => 'Skip loading all installed packages.',
		'default' => false,
	),

	'require'           => array(
		'runtime'  => '=<path>',
		'file'     => '<path>',
		'desc'     => 'Load PHP file before running the command (may be used more than once).',
		'multiple' => true,
		'default'  => array(),
	),

	'disabled_commands' => array(
		'file'    => '<list>',
		'default' => array(),
		'desc'    => '(Sub)commands to disable.',
	),

	'color'             => array(
		'runtime' => true,
		'file'    => '<bool>',
		'default' => 'auto',
		'desc'    => 'Whether to colorize the output.',
	),

	'debug'             => array(
		'runtime' => '[=<group>]',
		'file'    => '<group>',
		'default' => false,
		'desc'    => 'Show all PHP errors and add verbosity to WP-CLI output. Built-in groups include: bootstrap, commandfactory, and help.',
	),

	'prompt'            => array(
		'runtime' => '[=<assoc>]',
		'file'    => false,
		'default' => false,
		'desc'    => 'Prompt the user to enter values for all command arguments, or a subset specified as comma-separated values.',
	),

	'quiet'             => array(
		'runtime' => '',
		'file'    => '<bool>',
		'default' => false,
		'desc'    => 'Suppress informational messages.',
	),

	'apache_modules'    => array(
		'file'     => '<list>',
		'desc'     => 'List of Apache Modules that are to be reported as loaded.',
		'multiple' => true,
		'default'  => array(),
	),

	# --allow-root => (NOT RECOMMENDED) Allow wp-cli to run as root. This poses
	# a security risk, so you probably do not want to do this.
	'allow-root'        => array(
		'file'    => false, # Explicit. Just in case the default changes.
		'runtime' => '',
		'hidden'  => true,
	),

);
