#!/bin/bash
# ============================================================
#  start-novnc.sh — Lance websockify pour noVNC
# ============================================================

# Attendre que x11vnc soit prêt sur le port 5900
for i in $(seq 1 60); do
    if nc -z localhost 5900 2>/dev/null; then
        echo "[start-novnc] x11vnc prêt sur :5900 ✔"
        break
    fi
    echo "[start-novnc] Attente x11vnc... ($i/60)"
    sleep 1
done

NOVNC_DIR="/usr/share/novnc"

# Vérifier que noVNC est présent
if [ ! -d "$NOVNC_DIR" ]; then
    echo "[start-novnc] ERREUR: $NOVNC_DIR introuvable"
    exit 1
fi

echo "[start-novnc] Démarrage websockify :6515 → :5900"
echo "[start-novnc] Interface: http://0.0.0.0:6515"

exec websockify \
    --web="$NOVNC_DIR" \
    --heartbeat=30 \
    6515 \
    localhost:5900 \
    2>&1
