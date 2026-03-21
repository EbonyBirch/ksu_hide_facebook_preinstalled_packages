#!/system/bin/sh
MODDIR=${0%/*}
STATE="$MODDIR/boot_pending"
LOG="$MODDIR/bootlog.txt"

log_msg() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [boot-completed] $1" >> "$LOG"
}

rm -f "$STATE"
log_msg "Boot completed; watchdog cleared."
exit 0
