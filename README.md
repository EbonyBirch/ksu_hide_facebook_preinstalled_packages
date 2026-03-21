This is a KernelSU module that systemlessly hides:

- /product/app/app-com-facebook-appmanager
- /product/priv-app/app-com-facebook-system
- /product/priv-app/app-com-facebook-services
- /product/app/app-com-facebook-katana-local-stub

to allow installation of modded Meta app versions.

If you're getting errors in ReVanced and/or when you try to manually install the app you bump into:
- INSTALL_FAILED_UPDATE_INCOMPATIBLE
- Existing package (...) signatures do not match newer version; ignoring!
- INSTALL_FAILED_DUPLICATE_PERMISSION
despite erasing the app from the settings and maybe even removing stubs with adb/root,
this is the soluton for that problem.

Upon module installation you get a prompt to erase existing apps & data (having any leftovers laying around will forbid you from installing modded apps)