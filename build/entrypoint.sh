#!/bin/bash

# This script is used to start a VNC server with a virtual display and a lightweight desktop environment (LXDE)

export DISPLAY=:0
export RESOLUTION=1280x720
# The default user is 'docker', but it can be overridden by the VNC_USER environment variable if exists
export USER=${VNC_USER:-docker}
export HOME=/home/$USER

# Crear usuario si no existe
if ! id "$USER" &>/dev/null; then
  useradd -m -s /bin/bash "$USER"
fi

echo "Run virtual graphic desktop on $DISPLAY..."
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &

sleep 2

echo "[i] Start LXDE..."
su "$USER" -c "startlxde &"

sleep 2

echo "[i] Set VNC password..."
mkdir -p "$HOME/.vnc"
echo -e "${VNC_PASS:-letmein}\n${VNC_PASS:-letmein}\n" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"
chown -R "$USER:$USER" "$HOME/.vnc"

echo "[i] Up and running x11vnc server..."
# Running x11vnc server without password authentication
x11vnc -display $DISPLAY -nopw -forever -shared -bg

echo "[i] Up and running websockify on http://localhost:6080"
websockify --web=/usr/share/novnc 6080 localhost:5900 &

echo "Access to desktop LXDE at http://localhost:6080"

tail -f /dev/null