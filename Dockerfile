# ============================================================
#  ExenKit — Debian 13 (Trixie) | XFCE | noVNC | Dev Stack
# ============================================================
FROM debian:trixie-slim

LABEL maintainer="ExenKit"
LABEL description="Debian 13 XFCE Desktop — VLC, Firefox, XDM 7.2.10, Windsurf, Claude Code, Codex, Telegram, Oh-My-Zsh"

# ── Environnement de base ───────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    HOME=/root \
    USER=root \
    LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8 \
    RESOLUTION=1920x1080x24 \
    VNC_PASSWORD=ExenKit2025!

# ══════════════════════════════════════════════════════════════
# 1. PAQUETS SYSTÈME DE BASE
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Outils essentiels
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    gnupg2 \
    apt-transport-https \
    software-properties-common \
    lsb-release \
    xz-utils \
    tar \
    unzip \
    zip \
    bzip2 \
    # Locales & timezone
    locales \
    tzdata \
    # Utilitaires système
    sudo \
    procps \
    htop \
    net-tools \
    iproute2 \
    iputils-ping \
    bash-completion \
    # Build tools (pour npm packages natifs)
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    # Zsh
    zsh \
    fonts-powerline \
    # Misc
    libnotify4 \
    xdg-utils \
    xdg-user-dirs \
    && sed -i '/fr_FR.UTF-8/s/^# //' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=fr_FR.UTF-8 \
    && ln -fs /usr/share/zoneinfo/Africa/Douala /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 2. ENVIRONNEMENT GRAPHIQUE XFCE + VNC + noVNC
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Serveur X virtuel
    xvfb \
    # XFCE Desktop complet
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-screenshooter \
    xfce4-notifyd \
    # Gestionnaire de fichiers
    thunar \
    thunar-volman \
    gvfs \
    # Apparence
    gnome-themes-extra \
    gtk2-engines-murrine \
    papirus-icon-theme \
    # VNC server
    x11vnc \
    # noVNC + WebSocket proxy
    novnc \
    websockify \
    # Gestionnaire de processus
    supervisor \
    # Support DBus / accessibility
    dbus \
    dbus-x11 \
    at-spi2-core \
    # Polices
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-color-emoji \
    # Outils X11
    xdotool \
    wmctrl \
    x11-xserver-utils \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 3. APPLICATIONS — Firefox, VLC, Telegram
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Navigateur web
    firefox-esr \
    # Lecteur multimédia
    vlc \
    vlc-plugin-base \
    vlc-plugin-video-output \
    # Messagerie
    telegram-desktop \
    # Java Runtime (requis pour XDM)
    default-jre \
    default-jdk \
    # Outils réseau
    aria2 \
    axel \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 4. NODE.JS 22 LTS (via NodeSource)
# ══════════════════════════════════════════════════════════════
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/* \
    && node --version \
    && npm --version

# ══════════════════════════════════════════════════════════════
# 5. WINDSURF IDE (Codeium)
# ══════════════════════════════════════════════════════════════
RUN curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" \
    | gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] \
        https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" \
    | tee /etc/apt/sources.list.d/windsurf.list \
    && apt-get update \
    && apt-get install -y windsurf \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 6. XDM 7.2.10 — Xtreme Download Manager (version EXACTE)
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /tmp/xdm-install \
    && wget --progress=dot:giga \
        -O /tmp/xdm-install/xdm-setup-7.2.10.tar.xz \
        "https://github.com/subhra74/xdm/releases/download/7.2.10/xdm-setup-7.2.10.tar.xz" \
    && cd /tmp/xdm-install \
    && tar -xf xdm-setup-7.2.10.tar.xz \
    && ls -la \
    # Installation (le script install.sh de XDM copie vers /opt/xdman)
    && chmod +x install.sh 2>/dev/null || true \
    && (yes "" | ./install.sh 2>/dev/null \
        || (mkdir -p /opt/xdman && cp -r /tmp/xdm-install/* /opt/xdman/)) \
    # Créer le lanceur si absent
    && if [ ! -f /usr/local/bin/xdm ]; then \
        echo '#!/bin/bash\nexec java -jar /opt/xdman/xdman.jar "$@"' > /usr/local/bin/xdm; \
        chmod +x /usr/local/bin/xdm; \
    fi \
    # Entrée .desktop
    && mkdir -p /usr/share/applications \
    && cat > /usr/share/applications/xdm.desktop << 'EOF'
[Desktop Entry]
Name=XDM - Xtreme Download Manager
Comment=Gestionnaire de téléchargements (v7.2.10)
Exec=/usr/local/bin/xdm
Icon=xdman
Terminal=false
Type=Application
Categories=Network;FileTransfer;
EOF
    && rm -rf /tmp/xdm-install

# ══════════════════════════════════════════════════════════════
# 7. OH MY ZSH
# ══════════════════════════════════════════════════════════════
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
    && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc \
    # Plugins utiles
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
        /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone --depth=1 https://github.com/zsh-users/zsh-completions \
        /root/.oh-my-zsh/custom/plugins/zsh-completions \
    # Configurer le thème et les plugins
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm docker zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' /root/.zshrc \
    # Zsh par défaut
    && chsh -s $(which zsh)

# ══════════════════════════════════════════════════════════════
# 8. CLAUDE CODE (Anthropic)
# ══════════════════════════════════════════════════════════════
RUN npm install -g @anthropic-ai/claude-code \
    && claude --version 2>/dev/null || echo "Claude Code installé"

# ══════════════════════════════════════════════════════════════
# 9. OPENAI CODEX CLI
# ══════════════════════════════════════════════════════════════
RUN npm install -g @openai/codex \
    && codex --version 2>/dev/null || echo "Codex CLI installé"

# ══════════════════════════════════════════════════════════════
# 10. OH-MY-CODEX — CLI avancé pour Codex (commande: omx)
# ══════════════════════════════════════════════════════════════
RUN npm install -g oh-my-codex \
    && echo "✔ oh-my-codex installé (commande: omx)" \
    || echo "⚠ oh-my-codex non trouvé sur npm registry, tentative via GitHub..." \
    # Fallback : install depuis les sources GitHub
    && (git clone --depth=1 https://github.com/nicholasgasior/oh-my-codex /opt/oh-my-codex 2>/dev/null \
        && cd /opt/oh-my-codex \
        && npm install \
        && npm link 2>/dev/null \
        || true) \
    # Créer l'alias omx si le binaire principal a un autre nom
    && if command -v omx >/dev/null 2>&1; then \
        echo "✔ commande omx disponible"; \
    elif command -v oh-my-codex >/dev/null 2>&1; then \
        ln -sf $(which oh-my-codex) /usr/local/bin/omx; \
        echo "✔ alias omx → oh-my-codex créé"; \
    fi \
    && npm cache clean --force

# ══════════════════════════════════════════════════════════════
# 11. CONFIGURATION noVNC
# ══════════════════════════════════════════════════════════════
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html \
    || true

# Page d'accueil noVNC customisée
RUN cat > /usr/share/novnc/index.html << 'NOVNC_EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ExenKit Desktop</title>
  <meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale&quality=6&compression=2">
</head>
<body style="background:#1a1a2e;color:#fff;font-family:monospace;text-align:center;padding-top:40px">
  <h2>🚀 ExenKit — Connexion en cours...</h2>
  <p>Debian 13 XFCE | Dev Desktop</p>
</body>
</html>
NOVNC_EOF

# ══════════════════════════════════════════════════════════════
# 12. CONFIGURATION SUPERVISORD
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d

COPY supervisord.conf /etc/supervisor/conf.d/exenkit.conf

# ══════════════════════════════════════════════════════════════
# 13. SCRIPTS UTILITAIRES
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /etc/exenkit /scripts

COPY entrypoint.sh /entrypoint.sh
COPY scripts/start-xfce.sh /scripts/start-xfce.sh
COPY scripts/start-vnc.sh /scripts/start-vnc.sh
COPY scripts/start-novnc.sh /scripts/start-novnc.sh

RUN chmod +x /entrypoint.sh /scripts/*.sh

# ══════════════════════════════════════════════════════════════
# 14. PROFIL SHELL — Aliases & PATH
# ══════════════════════════════════════════════════════════════
RUN cat >> /root/.zshrc << 'ZSHRC_EOF'

# ─── ExenKit Aliases ─────────────────────────────────────
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias cls='clear'
alias zshreload='source ~/.zshrc'
alias myip='curl -s ifconfig.me'

# Outils IA
alias cc='claude'
alias codex='codex'
alias omx='oh-my-codex'

# Applications
alias xdm='java -jar /opt/xdman/xdman.jar &'
alias ws='windsurf'

# ─── PATH ─────────────────────────────────────────────────
export PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"
export NODE_PATH="/usr/local/lib/node_modules"
ZSHRC_EOF

# Même chose pour bash
RUN cat >> /root/.bashrc << 'BASHRC_EOF'

# ExenKit
export PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"
alias ll='ls -lah --color=auto'
alias cc='claude'
BASHRC_EOF

# ══════════════════════════════════════════════════════════════
# 15. WORKSPACE
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /workspace

WORKDIR /workspace

EXPOSE 5900 6515

ENTRYPOINT ["/entrypoint.sh"]
