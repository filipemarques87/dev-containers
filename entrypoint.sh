#!/usr/bin/env bash
set -euo pipefail

# --- Init (run once) ---
INIT_SCRIPT="/workspace/.devcontainer/init.sh"
INIT_FLAG="/var/lib/devcontainer/.initialized"

if [ ! -f "$INIT_FLAG" ]; then
  echo "First container startup: running init..."
  mkdir -p /var/lib/devcontainer
  [ -f "$INIT_SCRIPT" ] && bash "$INIT_SCRIPT"
  touch "$INIT_FLAG"
fi

# --- Match UID/GID to host ---
USERNAME=devuser
TARGET_UID=${LOCAL_UID:-1000}
TARGET_GID=${LOCAL_GID:-1000}

if [ "$(id -g "$USERNAME")" != "$TARGET_GID" ]; then
  groupmod -g "$TARGET_GID" "$USERNAME"
fi

if [ "$(id -u "$USERNAME")" != "$TARGET_UID" ] || [ "$(id -g "$USERNAME")" != "$TARGET_GID" ]; then
  usermod -u "$TARGET_UID" -g "$TARGET_GID" "$USERNAME"
  chown -R "$TARGET_UID":"$TARGET_GID" "/home/$USERNAME"
fi

# --- Drop privileges and exec ---
exec gosu "$USERNAME" "$@"
