# OpenWRT Snapshot builds using GitHub actions
The builds include the following custom files:

1. updater/
    - check_for_updates.sh: Triggers an update check with openwrt server, if 
                            a new update is found, the router triggers a new 
                            build on GitHub in this repository. Requires a 
                            valid ssh key to work. Hence, fork it, and add the 
                            routers ssh key to your account. All files except 
                            this one should work on any router.
    - autoupdate.sh: Checks if a new build is available on GitHub. If there is, 
                    downloads the build and its sha256, calculates sha256 
                    manually, compares, and finally runs sysupgrade if the 
                    comparison is successful.
    - first_boot.sh: Copied to uci-defaults before reboot by `autoupdate.sh`. 
                    Writes an "upgrade successful" message to `/root/upgrade.log` 
                    after first boot.

2. setup/ (only on c6u for now)
    - first_stage.sh: Formats the external usb, and prepares extroot.
    - second_stage.sh: Installs a few additional packages, and enables a bunch 
                    of services that I require.
    - z_setup_*_stage: Executes the actual `*_stage.sh` script after being started 
                    by sysctl. `z_setup_first_stage` is enabled in very first boot. 

    These scripts also disable themselves after their respective work is done.

All logs are written to `/root/upgrade.log`. Make sure to preserve the file if 
you want.
