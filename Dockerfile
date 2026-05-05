# ============================================================
#  ExenKit — Debian 13 (Trixie) | XFCE | noVNC | Dev Stack
# ============================================================
FROM debian:trixie-slim

LABEL maintainer="ExenKit"
LABEL description="Debian 13 XFCE Desktop — VLC, Firefox, XDM 7.2.10, Windsurf, Claude Code, Codex, Telegram, Oh-My-Zsh"

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
    ca-certificates curl wget git gnupg gnupg2 \
    apt-transport-https software-properties-common \
    lsb-release xz-utils tar unzip zip bzip2 \
    locales tzdata sudo procps htop \
    net-tools iproute2 iputils-ping netcat-openbsd \
    bash-completion build-essential \
    python3 python3-pip python3-venv \
    zsh fonts-powerline libnotify4 \
    xdg-utils xdg-user-dirs \
    && sed -i '/fr_FR.UTF-8/s/^# //' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=fr_FR.UTF-8 \
    && ln -fs /usr/share/zoneinfo/Africa/Douala /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 2. XFCE + VNC + noVNC
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    xfce4 xfce4-goodies xfce4-terminal xfce4-taskmanager \
    xfce4-screenshooter xfce4-notifyd \
    thunar thunar-volman gvfs \
    gnome-themes-extra gtk2-engines-murrine papirus-icon-theme \
    x11vnc novnc websockify \
    supervisor \
    dbus dbus-x11 at-spi2-core \
    fonts-dejavu fonts-liberation fonts-noto fonts-noto-color-emoji \
    xdotool wmctrl x11-xserver-utils x11-utils \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 3. APPLICATIONS — Firefox, VLC, Telegram
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    firefox-esr \
    vlc vlc-plugin-base vlc-plugin-video-output \
    telegram-desktop \
    default-jre default-jdk \
    aria2 axel \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 4. NODE.JS 22 LTS
# ══════════════════════════════════════════════════════════════
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/* \
    && node --version && npm --version

# ══════════════════════════════════════════════════════════════
# 5. WINDSURF IDE (Codeium)
# ══════════════════════════════════════════════════════════════
RUN curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" \
    | gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" \
    | tee /etc/apt/sources.list.d/windsurf.list \
    && apt-get update \
    && apt-get install -y windsurf \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 6. XDM 7.2.10 — version EXACTE (pas la dernière)
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /tmp/xdm-install \
    && wget --progress=dot:giga \
        -O /tmp/xdm-install/xdm-setup-7.2.10.tar.xz \
        "https://github.com/subhra74/xdm/releases/download/7.2.10/xdm-setup-7.2.10.tar.xz" \
    && cd /tmp/xdm-install \
    && tar -xf xdm-setup-7.2.10.tar.xz \
    && ls -la \
    && chmod +x install.sh 2>/dev/null || true \
    && (yes "" | ./install.sh 2>/dev/null \
        || (mkdir -p /opt/xdman && cp -r /tmp/xdm-install/* /opt/xdman/)) \
    && if [ ! -f /usr/local/bin/xdm ]; then \
        printf '#!/bin/bash\nexec java -jar /opt/xdman/xdman.jar "$@"\n' > /usr/local/bin/xdm \
        && chmod +x /usr/local/bin/xdm; \
    fi \
    && mkdir -p /usr/share/applications \
    && printf '[Desktop Entry]\nName=XDM - Xtreme Download Manager\nComment=Gestionnaire de telechargements v7.2.10\nExec=/usr/local/bin/xdm\nIcon=xdman\nTerminal=false\nType=Application\nCategories=Network;FileTransfer;\n' \
        > /usr/share/applications/xdm.desktop \
    && rm -rf /tmp/xdm-install

# ══════════════════════════════════════════════════════════════
# 7. OH MY ZSH + PLUGINS
# ══════════════════════════════════════════════════════════════
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
    && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
        /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone --depth=1 https://github.com/zsh-users/zsh-completions \
        /root/.oh-my-zsh/custom/plugins/zsh-completions \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm docker zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' /root/.zshrc \
    && chsh -s $(which zsh)

# ══════════════════════════════════════════════════════════════
# 8. CLAUDE CODE (Anthropic)
# ══════════════════════════════════════════════════════════════
RUN npm install -g @anthropic-ai/claude-code \
    && claude --version 2>/dev/null || echo "Claude Code installe"

# ══════════════════════════════════════════════════════════════
# 9. OPENAI CODEX CLI
# ══════════════════════════════════════════════════════════════
RUN npm install -g @openai/codex \
    && codex --version 2>/dev/null || echo "Codex CLI installe"

# ══════════════════════════════════════════════════════════════
# 10. OH-MY-CODEX (commande: omx)
# ══════════════════════════════════════════════════════════════
RUN npm install -g oh-my-codex 2>/dev/null \
    && echo "oh-my-codex installe" \
    ; if command -v omx >/dev/null 2>&1; then \
        echo "commande omx ok"; \
    elif command -v oh-my-codex >/dev/null 2>&1; then \
        ln -sf "$(which oh-my-codex)" /usr/local/bin/omx; \
        echo "symlink omx cree"; \
    fi \
    && npm cache clean --force

# ══════════════════════════════════════════════════════════════
# 11. PAGE noVNC — auto-connect au démarrage
# ══════════════════════════════════════════════════════════════
RUN printf '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>ExenKit Desktop</title>\n<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale&quality=6&compression=2">\n</head>\n<body style="background:#1a1a2e;color:#fff;font-family:monospace;text-align:center;padding-top:40px">\n<h2>ExenKit - Connexion en cours...</h2>\n<p>Debian 13 XFCE | Dev Desktop</p>\n</body>\n</html>\n' \
    > /usr/share/novnc/index.html

# ══════════════════════════════════════════════════════════════
# 12. PROFIL SHELL — Aliases & PATH
# ══════════════════════════════════════════════════════════════
RUN printf '\n# --- ExenKit ---\nalias ll="ls -lah --color=auto"\nalias la="ls -A --color=auto"\nalias cls="clear"\nalias zshreload="source ~/.zshrc"\nalias myip="curl -s ifconfig.me"\nalias cc="claude"\nalias omx="oh-my-codex"\nalias ws="windsurf"\nexport PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"\nexport NODE_PATH="/usr/local/lib/node_modules"\n' \
    >> /root/.zshrc \
    && printf '\n# --- ExenKit ---\nexport PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"\nalias ll="ls -lah --color=auto"\nalias cc="claude"\nalias omx="oh-my-codex"\n' \
    >> /root/.bashrc

# ══════════════════════════════════════════════════════════════
# 13. STRUCTURE + SCRIPTS
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d /etc/exenkit /scripts /workspace

COPY supervisord.conf /etc/supervisor/conf.d/exenkit.conf
COPY entrypoint.sh /entrypoint.sh
COPY scripts/start-xfce.sh /scripts/start-xfce.sh
COPY scripts/start-vnc.sh /scripts/start-vnc.sh
COPY scripts/start-novnc.sh /scripts/start-novnc.sh

RUN chmod +x /entrypoint.sh /scripts/*.sh

WORKDIR /workspace
EXPOSE 5900 6515
ENTRYPOINT ["/entrypoint.sh"]
