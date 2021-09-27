<?php
/**
 * Here we overwrite the binaries in our bin folder to properly support
 * Windows operating systems.
 */

require __DIR__ . '/../vendor/steveorevo/gstring/src/GString.php';
require __DIR__ . '/../vendor/steveorevo/gstring/src/GStringIndexOutOfBoundsException.php';
use Steveorevo\GString as GString;

// Analyze list of all composer files from the vendor folder
$vendor = new RecursiveDirectoryIterator(__DIR__ . "/../vendor/");
foreach(new RecursiveIteratorIterator($vendor) as $file) {
	if ($file->getFilename() == "composer.json") {

		// Find bin definitions and write shell/bat script wrappers to invoke them
		$obj = json_decode(file_get_contents($file->getRealPath()));
		if (property_exists($obj, "bin")) {


			// First cleanup existing binaries, this prevents writing to symlink destinations
			foreach($obj->bin as $bin) {
				$fname = __DIR__ . "/../bin/" . (new GString($bin))->getRightMost("/")->__toString();
				@unlink($fname);
				@unlink($fname . ".bat");				
			}

			// Write out new binary proxy wrappers
			foreach($obj->bin as $bin) {
				$bin = ".." . (new GString($file->getPath()))->delLeftMost('..') . "/" . $bin;
				$fname = __DIR__ . "/../bin/" . (new GString($bin))->getRightMost("/");
				if (false === strpos($fname, ".bat")) {
					
					// Create wrapper shell scripts for mac, linux, etc.
					$content = "#!/bin/bash\n";

					// Include support for cygwin
					$content .= 'if [[ -z "${CYGWIN_HOME}" ]]; then' . "\n";
					$content .= '  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"' . "\n";
					$content .= '  $SCRIPT_DIR/' . $bin . ' "$@"' . "\n";
					$content .= 'else' . "\n";
					$content .= '  ' . (new GString($bin))->getRightMost("/") . '.bat "$@"' . "\n";
					$content .= 'fi';
					file_put_contents($fname, $content);
					chmod($fname, 0755);
					
					// Create wrapper bat scripts for Windows that invoke the php interpreter
					$content = "@echo off\n";
					$content .= "php %~dp0" . $bin . " %*";
					$fname .= ".bat";
					file_put_contents($fname, $content);					
				}
			}

			// Lastly write out any wrappers for existing bat files without interpreter
			// Sometimes we have these of the same name and should favor using them (i.e. wp.bat)
			foreach($obj->bin as $bin) {
				$bin = ".." . (new GString($file->getPath()))->delLeftMost('..') . "/" . $bin;
				$fname = __DIR__ . "/../bin/" . (new GString($bin))->getRightMost("/")->__toString();

				if (strpos($fname, ".bat") > 0) {
					
					// For existing Windows bat scripts, skip the php interpreter
					@unlink($fname); // remove any php wrapper we made prior
					$content = "@echo off\n";
					$content .= "%~dp0" . $bin . " %*";
					file_put_contents($fname, $content);
				}
			}
		};
	}
}

