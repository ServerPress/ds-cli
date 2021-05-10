# ds-cli
DS-CLI is now a core runtime component of DesktopServer. This project esembles the latest command line interface tools such as Composer, PHPUnit, WP-CLI, and other cross-platform components that are important to professional WordPress developers. The vendor folder is intensionally included in this repo as it serves as part of the runtime delivery mechanism for DesktopServer.

The DS-CLI project includes it's own bin folder to ensure cross-platform access that is currently problematic using composer's built-in vendor/bin folder. In example, orphaned junctions on Windows, etc. see links below for status and details of known issues. 

The DS-CLI project includes it's own bin builder that wraps binaries for proper cross-platform execution. Adding ds-cli/bin to your system path ensures proper access to the included command line interface utilities regardless of platform.  

https://github.com/composer/composer/issues/7256
