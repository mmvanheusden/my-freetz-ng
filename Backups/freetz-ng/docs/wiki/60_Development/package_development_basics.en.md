# Package Development

This page is primarily for freetz package developers.

### Persistent Package Settings

Freetz provides a package configuration framework easing implementation
and allows settings to be stored persistently. Packages must provide two
files to use the framework:

1.  /etc/default.\$package/\$package.cfg --- This file must contain all
    configuration settings as exported shell variables; each variable
    has to start with the capitalized package name. Example:

    ```
    export PACKAGE_VAR1='var1'
    export PACKAGE_VAR2='var2'
    ```

<!-- -->

2.  /usr/lib/cgi-bin/\$package.cgi --- This is the cgi file used for
    package configuration. It has to be registered via 'modreg cgi'.
    For examples, have a look at some package providing a web interface
    page.

If this is implemented correctly, freetz takes care of saving and also
restarting the service, if the package provides one.

### Custom package saving mechanism

Freetz also provides a mechanism to hook into the 'normal' saving
procedure and execute custom code or do manual saving. An example using
this mechanism is the package mini_fo. This mechanism comes in quite
handy if the package needs to re-create configuration files or
start/stop special (non-default) services on changing the configuration.
It works as follows: If a package provides a file
/etc/default.\$package/\$package.save, it will be sourced by the saving
mechanism as a shell script (but it should not have a shebang line!).
The .save-script can implement any or all of the following shell
functions, which are executed at some special point during the saving
mechanims:

pkg_pre_save()
:   Executed before saving happens.

pkg_apply_save()
:   Executed after settings were changed, but before they are saved to
    flash. ATTENTION! This is not executed if there are no settings (no
    \$package.cfg file)!

pkg_post_save()
:   Executed after settings were saved to flash.

pkg_pre_def()
:   Executed before saving happens when loading the package defaults.

pkg_apply_def()
:   Executed after settings were changed, but before they are saved to
    flash when loading the package defaults. ATTENTION! This is not
    executed if there are no settings (no \$package.cfg file)!

pkg_post_def()
:   Executed after settings were saved to flash when loading the package
    defaults.


