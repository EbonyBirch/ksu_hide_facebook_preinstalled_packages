#!/system/bin/sh
MODDIR=${0%/*}
STATE="$MODDIR/boot_pending"
LOG="$MODDIR/bootlog.txt"

log_msg() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [late-load] $1" >> "$LOG"
}

# KernelSU late-load mode replacement for post-fs-data.sh
if [ -f "$STATE" ]; then
  touch "$MODDIR/disable"
  log_msg "Previous boot did not complete; module disabled for this boot (late-load)."
  exit 0
fi

echo "pending" > "$STATE"
chmod 0600 "$STATE"
log_msg "Watchdog armed from late-load."
exit 0
