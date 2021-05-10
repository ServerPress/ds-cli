<?php
/**
 * Here we overwrite the binaries in our bin folder to properly support
 * Windows operating systems.
 */

require __DIR__ . '/../vendor/steveorevo/gstring/src/GString.php';
require __DIR__ . '/../vendor/steveorevo/gstring/src/GStringIndexOutOfBoundsException.php';

// Analyze list of all composer files from the vendor folder
$vendor = new RecursiveDirectoryIterator(__DIR__ . "/../vendor/");
foreach(new RecursiveIteratorIterator($vendor) as $file) {
	if ($file->getFilename() == "composer.json") {

		// Find bin definitions; we currently only support one per package
		$obj = json_decode(file_get_contents($file->getRealPath()));
		if (property_exists($obj, "bin")) {

			// Favor batch file if present
			$bin = array_filter($obj->bin, function($v) {
				return (strpos($v, ".bat") > 0);
			});

			// Write out our proxy bin file that calls the right bin
			if (empty($bin)) {
				$bin = $obj->bin[0];
				$fname = (new Steveorevo\GString($bin))->getRightMost("/") . ".bat";
				$bin = ".." . (new Steveorevo\GString($file->getPath()))->delLeftMost('..') . "/" . $bin;
				$bin = str_replace("/", "\\", $bin);

				// Write out bat file that invokes PHP
				$cmd = "php %~dp0" . $bin . " %*";
			}else{
				$bin = end($bin);
				$fname = (new Steveorevo\GString($bin))->getRightMost("/")->__toString();
				$bin = ".." . (new Steveorevo\GString($file->getPath()))->delLeftMost('..') . "/" . $bin;
				$bin = str_replace("/", "\\", $bin);

				// Write out bat file that calls existing bat file
				$cmd = "%~dp0" . $bin . " %*";
			}
			$fname = __DIR__ . "/../bin/" . $fname;
			if (file_exists($fname)) {
				unlink($fname);
			}
			file_put_contents($fname, $cmd);
		};
	}
}
