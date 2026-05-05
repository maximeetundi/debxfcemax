#!/bin/bash
# ============================================================
#  start-xfce.sh — Lance le bureau XFCE4 avec DBus
# ============================================================

export DISPLAY=:1
export HOME=/root
export USER=root
export XDG_RUNTIME_DIR=/tmp/runtime-root
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE

# Attendre que Xvfb soit prêt
for i in $(seq 1 30); do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "[start-xfce] Xvfb prêt ✔"
        break
    fi
    echo "[start-xfce] Attente Xvfb... ($i/30)"
    sleep 1
done

# Configurer la résolution (bonus)
xrandr --display :1 --auto 2>/dev/null || true

# Paramètres XFCE — résolution DPI
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

# Lancer XFCE
echo "[start-xfce] Démarrage XFCE4..."
exec startxfce4 --display :1 2>&1
