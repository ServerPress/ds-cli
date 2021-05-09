# ds-cli
DS-CLI is now a core runtime component of DesktopServer. This project is an esemble of the latest command line interface tools such as Composer, PHPUnit, WP-CLI, and other cross-platform components that are important to professional WordPress developers. 

To build the latest runtime:

## Buliding
Ideally it would have been nice to use composer itself; but this presents two hurdles 1) chicken/egg scenario of composer obtaining composer and 2) the cross-platform bin definition composer uses to create .bat files and subsequent junctions within the vendor/bin directory is breaks when re-homing the vendor folder. Therefore, we the build script will obtain viable and portable .phar files where available and roll our own .bat launchers for windows compatibility.

1) Start a command line prompt (Terminal.app)
2) Change directory to project (i.e. /Users/jsmith/Documents/ds-cli)
3) Execute ./build.sh
