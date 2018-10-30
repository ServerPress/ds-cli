# ds-cli
DS-CLI is an enhanced, cross-platform, command line interface for professional WordPress developers. Users can easily start working with CLI tools such as the included WP-CLI, Composer, Git, and PHPUnit. NodeJS and NPM are also included allowing easy installation of gulp, grunt, and many other NodeJS based tools.

## Installation
DS-CLI comes with DesktopServer Premium edition. However, manual installation can be performed by downloading and unzipping the ds-cli-xxx.zip file (where xxx is your platform mac for macOS or win for Windows). 

Windows users will need to fix symbolic links by running the following command once after installation. Make sure the DS-CLI plugin is enabled via DesktopServer's first "Stop or restart..." option. Next, launch a DS-CLI instance by visiting one of your site's DS-CLI prompts as listed under http://localhost, then type:

```
symfix $DS_CLI/platform/win32/cygwin
```

You will not need to run the command again after it is run once. It is only necessary if you have performed the above (unzip) manual installation. This is only necessary for Windows users.


