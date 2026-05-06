#!/bin/bash
# ============================================================
#  ExenKit — Entrypoint
#  Initialise l'environnement puis lance supervisord
# ============================================================

set -e

# ─── Couleurs ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    echo "  ███████╗██╗  ██╗███████╗███╗   ██╗██╗  ██╗██╗████████╗"
    echo "  ██╔════╝╚██╗██╔╝██╔════╝████╗  ██║██║ ██╔╝██║╚══██╔══╝"
    echo "  █████╗   ╚███╔╝ █████╗  ██╔██╗ ██║█████╔╝ ██║   ██║   "
    echo "  ██╔══╝   ██╔██╗ ██╔══╝  ██║╚██╗██║██╔═██╗ ██║   ██║   "
    echo "  ███████╗██╔╝ ██╗███████╗██║ ╚████║██║  ██╗██║   ██║   "
    echo "  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "  ${YELLOW}Debian 13 LXQt | Dev Desktop Suite${NC}"
    echo "  ─────────────────────────────────────────────────────"
    echo ""
}

log_info()    { echo -e "  ${GREEN}[✔]${NC} $1"; }
log_warn()    { echo -e "  ${YELLOW}[⚠]${NC} $1"; }
log_error()   { echo -e "  ${RED}[✘]${NC} $1"; }
log_section() { echo -e "\n  ${BLUE}▶ $1${NC}"; }

banner

# ─── 1. Timezone ─────────────────────────────────────────────
log_section "Configuration Timezone"
TZ="${TZ:-Africa/Douala}"
ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata 2>/dev/null || true
log_info "Timezone: $TZ"

# ─── 2. Résolution écran ─────────────────────────────────────
log_section "Résolution"
export RESOLUTION="${RESOLUTION:-1920x1080x24}"
log_info "Résolution: $RESOLUTION"

# ─── 3. Mot de passe VNC ─────────────────────────────────────
log_section "Configuration VNC"
mkdir -p "$HOME/.vnc"
VNC_PASSWORD="${VNC_PASSWORD:-ExenKit2025!}"

if [ -n "$VNC_PASSWORD" ]; then
    x11vnc -storepasswd "$VNC_PASSWORD" "$HOME/.vnc/passwd" 2>/dev/null
    log_info "Mot de passe VNC configuré"
    export VNC_AUTH_FLAG="-rfbauth $HOME/.vnc/passwd"
else
    log_warn "Aucun mot de passe VNC — accès sans authentification"
    export VNC_AUTH_FLAG="-nopw"
fi

# Écrire le flag pour les scripts enfants
echo "VNC_AUTH_FLAG=$VNC_AUTH_FLAG" > /etc/exenkit/vnc.env
chmod 644 /etc/exenkit/vnc.env

# ─── 4. XDG Runtime ──────────────────────────────────────────
mkdir -p "/tmp/runtime-$USER"
chmod 700 "/tmp/runtime-$USER"
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
chown "$USER:$USER" "/tmp/runtime-$USER"

# ─── 5. Dossiers utilisateur ─────────────────────────────────
log_section "Dossiers"
mkdir -p "$HOME"/{Desktop,Downloads,Documents,Projects,.config}
mkdir -p /workspace
chown -R "$USER:$USER" "$HOME" /workspace
log_info "Dossiers configurés pour $USER"

# ─── 6. Clés API (optionnelles) ──────────────────────────────
log_section "Clés API"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> "$HOME/.zshrc"
    echo "export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> "$HOME/.bashrc"
    log_info "ANTHROPIC_API_KEY chargée → Claude Code prêt"
fi

if [ -n "$OPENAI_API_KEY" ]; then
    echo "export OPENAI_API_KEY=$OPENAI_API_KEY" >> "$HOME/.zshrc"
    echo "export OPENAI_API_KEY=$OPENAI_API_KEY" >> "$HOME/.bashrc"
    log_info "OPENAI_API_KEY chargée → Codex & omx prêts"
fi

# ─── 7. Lancement ────────────────────────────────────────────
log_section "Démarrage des services"
echo ""
echo -e "  ${CYAN}┌─────────────────────────────────────────┐${NC}"
echo -e "  ${CYAN}│  🌐  noVNC → http://localhost:6515       │${NC}"
echo -e "  ${CYAN}│  🖥  VNC   → localhost:5900              │${NC}"
echo -e "  ${CYAN}│  🔑  Pass  → $VNC_PASSWORD               │${NC}"
echo -e "  ${CYAN}└─────────────────────────────────────────┘${NC}"
echo ""
echo -e "  ${GREEN}Stack installée :${NC}"
echo -e "    • Firefox ESR    🦊"
echo -e "    • VLC            🎬"
echo -e "    • Telegram       💬"
echo -e "    • XDM 7.2.10     ⬇"
echo -e "    • Windsurf IDE   🌊"
echo -e "    • Claude Code    🤖"
echo -e "    • Codex CLI      🧠"
echo -e "    • Oh My Zsh      🐚"
echo ""

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
