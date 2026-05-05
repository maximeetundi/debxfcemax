#!/bin/bash
# ============================================================
#  start-vnc.sh — Lance x11vnc avec ou sans mot de passe
# ============================================================

export DISPLAY=:1

# Attendre que Xvfb soit prêt
for i in $(seq 1 40); do
    if xdpyinfo -display :1 >/dev/null 2>&1; then
        echo "[start-vnc] Display :1 disponible ✔"
        break
    fi
    echo "[start-vnc] Attente display... ($i/40)"
    sleep 1
done

# Attendre XFCE (quelques secondes de plus)
sleep 4

# Charger le flag d'authentification
if [ -f /etc/exenkit/vnc.env ]; then
    source /etc/exenkit/vnc.env
fi

# Choisir le mode auth
if [ -f /root/.vnc/passwd ]; then
    AUTH_OPTS="-rfbauth /root/.vnc/passwd"
    echo "[start-vnc] Mode: mot de passe VNC"
else
    AUTH_OPTS="-nopw"
    echo "[start-vnc] Mode: sans mot de passe"
fi

echo "[start-vnc] Démarrage x11vnc sur :5900..."

exec x11vnc \
    -display :1 \
    $AUTH_OPTS \
    -listen 0.0.0.0 \
    -rfbport 5900 \
    -xkb \
    -ncache 10 \
    -ncache_cr \
    -forever \
    -shared \
    -repeat \
    -cursor most \
    -env FD_XDM=1 \
    2>&1
