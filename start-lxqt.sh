#!/bin/bash
# ============================================================
#  start-lxqt.sh — Lance le bureau LXQt avec Openbox
# ============================================================

export DISPLAY=:1
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=LXQt
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"

# Attendre que Xvfb soit prêt
for i in $(seq 1 30); do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "[start-lxqt] Xvfb prêt ✔"
        break
    fi
    echo "[start-lxqt] Attente Xvfb... ($i/30)"
    sleep 1
done

# Configurer la résolution
if [ -n "$RESOLUTION" ]; then
    RES_WH=$(echo $RESOLUTION | cut -d'x' -f1,2)
    echo "[start-lxqt] Tentative de réglage résolution: $RES_WH"
    xrandr --display :1 --fb $RES_WH || true
    xrandr --display :1 --size $RES_WH || true
fi

# Paramètres LXQt/Qt
xrdb -merge << 'XRDB'
Xft.dpi: 96
Xft.antialias: 1
Xft.hinting: 1
Xft.hintstyle: hintslight
Xft.rgba: rgb
XRDB

# Démarrer le bus de session DBus si absent
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax) 2>/dev/null || true
fi

# Lancer LXQt
echo "[start-lxqt] Démarrage LXQt..."
exec startlxqt --display :1 2>&1
