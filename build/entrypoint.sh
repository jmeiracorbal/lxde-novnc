#!/bin/bash

# This script is used to start a VNC server with a virtual display and a lightweight desktop environment (LXDE)

export DISPLAY=:0
export RESOLUTION=1280x720

# Configure the Linux system user for configure home directory
export USER=${SYSTEM_USER:-docker}
export HOME=/home/$USER

# Remove stale X lock file if exists
rm -f /tmp/.X0-lock

# Create the user if it does not exist
if ! id "$USER" &>/dev/null; then
  echo "Creating user $USER..."
  useradd -m -s /bin/bash "$USER"
fi

# Create the LXDE configuration directory and copy from skel if it does not exist
mkdir -p "$HOME/.config/lxpanel/LXDE/panels"
cp -f /etc/skel/.config/lxpanel/LXDE/panels/panel "$HOME/.config/lxpanel/LXDE/panels/panel"
chown -R "$USER:$USER" "$HOME/.config/lxpanel"

echo "[INFO] Executing virtual graphical environment on $DISPLAY..."
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &

sleep 2

echo "[INFO] Running x11vnc server..."

mkdir -p "$HOME/.vnc"
chown -R "$USER:$USER" "$HOME/.vnc"

if [ "$ALLOW_NOPW" = "true" ]; then
  echo -e "[INFO] You're executing ALLOW_NOPW=true x11vnc without password authentication."
  echo -e "[WARNING] This is not recommended for production environments as it allows anyone to connect without a password."
  x11vnc -display $DISPLAY -nopw -forever -shared -bg
else
  if [ -z "$VNC_PASS" ]; then
    echo "[ERROR] VNC_PASS it's not defined and ALLOW_NOPW it's not enabled. Abort."
    echo "[INFO] Define VNC_PASS to stabled a password o mark ALLOW_NOPW=true to deactivate authentication (no recommended)."
    exit 1
  fi

  echo "[INFO] Configuring authentication VNC with password..."
  TMP_PASSWD_FILE=$(mktemp)
  vncpasswd -f <<< "${VNC_PASS}"$'\n'"${VNC_PASS}" > "$TMP_PASSWD_FILE"

  if [ ! -s "$TMP_PASSWD_FILE" ]; then
    echo "[ERROR] Fail generating the the password file for VNC. Aborting..."
    exit 1
  fi

  mv "$TMP_PASSWD_FILE" "$HOME/.vnc/passwd"
  chmod 600 "$HOME/.vnc/passwd"
  chown -R "$USER:$USER" "$HOME/.vnc"

  x11vnc -display $DISPLAY -rfbauth "$HOME/.vnc/passwd" -forever -shared -bg
fi

sleep 2

echo "[INFO] Running the LXDE desktop..."

# Asegurar entorno correcto para las apps lanzadas desde LXDE
cd "$HOME"
su "$USER" -c "cd \$HOME && startlxde &"

sleep 2

echo "[INFO] Running websockify en http://localhost:6080..."
websockify --web=/usr/share/novnc 6080 localhost:5900 &

echo "[INFO] Graphical environment LXDE enabled on http://localhost:6080"

tail -f /dev/null