#!/system/bin/sh
MODDIR=${0%/*}
STATE="$MODDIR/boot_pending"
LOG="$MODDIR/bootlog.txt"

log_msg() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [post-fs-data] $1" >> "$LOG"
}

# If previous boot never reached boot-completed, disable on this boot.
if [ -f "$STATE" ]; then
  touch "$MODDIR/disable"
  log_msg "Previous boot did not complete; module disabled for this boot."
  exit 0
fi

echo "pending" > "$STATE"
chmod 0600 "$STATE"
log_msg "Watchdog armed from post-fs-data."
exit 0
