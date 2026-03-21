# KernelSU module installer customization
# Sourced by the KernelSU installer; do not add a shebang here.

SKIPUNZIP=0

ui_print "- Installing: Hide Facebook Preinstalled Packages"

if [ "$KSU" != "true" ]; then
  abort "This ZIP is intended for KernelSU only."
fi

META_LINK="/data/adb/metamodule"
META_PROP="$META_LINK/module.prop"

if [ ! -L "$META_LINK" ] || [ ! -f "$META_PROP" ]; then
  abort "No active KernelSU metamodule detected. Install a metamodule such as meta-overlayfs first, reboot, and then install this module again."
fi

if ! grep -Eiq '^metamodule=(1|true)$' "$META_PROP"; then
  abort "The active /data/adb/metamodule target does not look like a valid KernelSU metamodule. Install meta-overlayfs first."
fi

META_NAME=$(sed -n 's/^name=//p' "$META_PROP" | head -n 1)
META_ID=$(sed -n 's/^id=//p' "$META_PROP" | head -n 1)
[ -n "$META_NAME" ] && ui_print "- Active metamodule: $META_NAME${META_ID:+ ($META_ID)}"
ui_print "- KernelSU userspace version: $KSU_VER ($KSU_VER_CODE)"
ui_print "- KernelSU kernel version code: $KSU_KERNEL_VER_CODE"
ui_print "- Device ABI: $ARCH  API: $API"
ui_print "- Target directories to hide:"
ui_print "  * /product/app/app-com-facebook-appmanager"
ui_print "  * /product/priv-app/app-com-facebook-system"
ui_print "  * /product/priv-app/app-com-facebook-services"
ui_print "  * /product/app/app-com-facebook-katana-local-stub"

# KernelSU guide: REMOVE entries create whiteouts in the module path.
REMOVE="
/system/product/app/app-com-facebook-appmanager
/system/product/priv-app/app-com-facebook-system
/system/product/priv-app/app-com-facebook-services
/system/product/app/app-com-facebook-katana-local-stub
"

PACKAGES="
com.facebook.appmanager
com.facebook.services
com.facebook.system
com.facebook.katana
com.facebook.orca
"

get_user_ids() {
  /system/bin/pm list users 2>/dev/null | sed -n 's/.*{\([0-9]\+\):.*/\1/p'
}

wipe_pkg() {
  pkg="$1"
  ui_print "- Removing package/data: $pkg"

  for u in $(get_user_ids); do
    /system/bin/pm uninstall --user "$u" "$pkg" >/dev/null 2>&1 || true
  done

  /system/bin/pm clear "$pkg" >/dev/null 2>&1 || true

  for p in \
    "/data/data/$pkg" \
    /data/user/*/"$pkg" \
    /data/user_de/*/"$pkg" \
    /mnt/expand/*/user/*/"$pkg" \
    /mnt/expand/*/user_de/*/"$pkg"; do
    [ -e "$p" ] && rm -rf "$p"
  done

  find /data/app -maxdepth 2 -type d \( -name "$pkg" -o -name "$pkg-*" \) -exec rm -rf {} + 2>/dev/null || true
}

choose_wipe() {
  ui_print "- Optional cleanup before first reboot"
  ui_print "- Vol+ : uninstall listed Meta packages and remove user data"
  ui_print "- Vol- : keep current package/data state"
  ui_print "- Waiting up to 15 seconds for a volume key..."

  if [ ! -x /system/bin/getevent ]; then
    ui_print "! /system/bin/getevent is not available; defaulting to Vol- behavior"
    return 1
  fi

  event="$(timeout 15 /system/bin/getevent -qlc 1 2>/dev/null || true)"
  case "$event" in
    *KEY_VOLUMEUP*)
      ui_print "- Volume Up detected: cleanup enabled"
      return 0
      ;;
    *KEY_VOLUMEDOWN*)
      ui_print "- Volume Down detected: cleanup skipped"
      return 1
      ;;
    *)
      ui_print "! No recognizable volume key event detected; defaulting to skip cleanup"
      return 1
      ;;
  esac
}

if choose_wipe; then
  for pkg in $PACKAGES; do
    wipe_pkg "$pkg"
  done
  sync
  ui_print "- Cleanup pass finished"
else
  ui_print "- Cleanup pass skipped"
fi
