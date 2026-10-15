#!/usr/bin/env bash
# Export Galaxy Reward's Android database and open the local copy.
set -euo pipefail

package='com.example.point_system'
remote_db='databases/galaxy_rewards.db'
output="$HOME/galaxy_rewards.db"
# Optional: ./view-db.sh DEVICE_SERIAL (useful with multiple devices).
adb_args=()
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [DEVICE_SERIAL]" >&2
  exit 1
fi
if [[ $# -eq 1 ]]; then
  adb_args=(-s "$1")
fi

for command in adb sqlitebrowser; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing $command. On Ubuntu: sudo apt install adb sqlitebrowser" >&2
    exit 1
  fi
done

if ! adb "${adb_args[@]}" get-state >/dev/null; then
  echo 'Connect your phone and allow USB debugging. Use adb devices to check.' >&2
  echo 'With multiple devices, run: ./view-db.sh DEVICE_SERIAL' >&2
  exit 1
fi

if ! adb "${adb_args[@]}" shell run-as "$package" ls "$remote_db" >/dev/null; then
  echo 'Database not available. Run the debug app, log in and open Home first.' >&2
  exit 1
fi

echo 'Stopping the phone app before copying its database...'
adb "${adb_args[@]}" shell am force-stop "$package"

# Stage the export so a failed copy cannot overwrite an existing database.
work_dir=$(mktemp -d "$HOME/.galaxy-db-export.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
adb "${adb_args[@]}" exec-out run-as "$package" cat "$remote_db" > "$work_dir/galaxy_rewards.db"
if [[ ! -s "$work_dir/galaxy_rewards.db" ]]; then
  echo 'Export failed: the database is empty.' >&2
  exit 1
fi

# Preserve WAL/journal sidecars, if present, to retain committed data.
for suffix in -wal -shm -journal; do
  if adb "${adb_args[@]}" shell run-as "$package" ls "${remote_db}${suffix}" >/dev/null 2>&1; then
    adb "${adb_args[@]}" exec-out run-as "$package" cat "${remote_db}${suffix}" > "$work_dir/galaxy_rewards.db${suffix}"
  fi
done

# Keep each export separate. This avoids overwriting an open browser database
# and preserves any edits made to earlier copies.
export_dir=$(mktemp -d "$HOME/galaxy-db-$(date +%Y%m%d-%H%M%S).XXXXXX")
mv -- "$work_dir"/galaxy_rewards.db* "$export_dir/"
output="$export_dir/galaxy_rewards.db"
echo "Opening: $output"
echo 'Choose Browse Data, then members, point_transactions or expiry_groups.'
echo 'This is a laptop copy. Editing it does not update the phone.'
echo 'Restart the phone app when you want to continue using it.'
sqlitebrowser "$output"
