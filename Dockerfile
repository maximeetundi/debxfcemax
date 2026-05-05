# ============================================================
#  ExenKit — Debian 13 (Trixie) | XFCE | noVNC | Dev Stack
# ============================================================
FROM debian:trixie-slim

# ══════════════════════════════════════════════════════════════
# ARGUMENTS DE CONSTRUCTION (Optionnels via .env)
# ══════════════════════════════════════════════════════════════
ARG INSTALL_FIREFOX=true
ARG INSTALL_VLC=true
ARG INSTALL_JAVA=true
ARG INSTALL_NODEJS=true
ARG INSTALL_WINDSURF=true
ARG INSTALL_XDM=true
ARG INSTALL_CLAUDE=true
ARG INSTALL_CODEX=true

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
    apt-transport-https \
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
# 3. APPLICATIONS — Firefox, VLC, Java
# ══════════════════════════════════════════════════════════════
RUN apt-get update && \
    PKGS="" && \
    if [ "$INSTALL_FIREFOX" = "true" ]; then PKGS="$PKGS firefox-esr"; fi && \
    if [ "$INSTALL_VLC" = "true" ]; then PKGS="$PKGS vlc vlc-plugin-base vlc-plugin-video-output"; fi && \
    if [ "$INSTALL_JAVA" = "true" ]; then PKGS="$PKGS default-jre default-jdk"; fi && \
    PKGS="$PKGS aria2 axel" && \
    apt-get install -y --no-install-recommends $PKGS && \
    rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 4. NODE.JS 22 LTS
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_NODEJS" = "true" ]; then \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node --version && npm --version; \
    fi

# ══════════════════════════════════════════════════════════════
# 5. WINDSURF IDE (Codeium)
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_WINDSURF" = "true" ]; then \
    curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" \
    | gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" \
    | tee /etc/apt/sources.list.d/windsurf.list \
    && apt-get update \
    && apt-get install -y windsurf \
    && rm -rf /var/lib/apt/lists/*; \
    fi

# ══════════════════════════════════════════════════════════════
# 6. XDM 7.2.10 — version EXACTE
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_XDM" = "true" ]; then \
    mkdir -p /tmp/xdm-install \
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
    && rm -rf /tmp/xdm-install; \
    fi

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
RUN if [ "$INSTALL_CLAUDE" = "true" ] && command -v npm >/dev/null 2>&1; then \
    npm install -g @anthropic-ai/claude-code \
    && claude --version 2>/dev/null || echo "Claude Code installe"; \
    fi

# ══════════════════════════════════════════════════════════════
# 9. OPENAI CODEX CLI
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_CODEX" = "true" ] && command -v npm >/dev/null 2>&1; then \
    npm install -g @openai/codex \
    && codex --version 2>/dev/null || echo "Codex CLI installe"; \
    fi

# ══════════════════════════════════════════════════════════════
# 10. OH-MY-CODEX (commande: omx)
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_CODEX" = "true" ] && command -v npm >/dev/null 2>&1; then \
    npm install -g oh-my-codex 2>/dev/null \
    && echo "oh-my-codex installe" \
    ; if command -v omx >/dev/null 2>&1; then \
        echo "commande omx ok"; \
    elif command -v oh-my-codex >/dev/null 2>&1; then \
        ln -sf "$(which oh-my-codex)" /usr/local/bin/omx; \
        echo "symlink omx cree"; \
    fi \
    && npm cache clean --force; \
    fi

# ══════════════════════════════════════════════════════════════
# 11. PAGE noVNC — auto-connect
# ══════════════════════════════════════════════════════════════
RUN printf '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>ExenKit Desktop</title>\n<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale&quality=9&compression=0">\n</head>\n<body style="background:#1a1a2e;color:#fff;font-family:monospace;text-align:center;padding-top:40px">\n<h2>ExenKit - Connexion en cours...</h2>\n<p>Debian 13 XFCE | Dev Desktop</p>\n</body>\n</html>\n' \
    > /usr/share/novnc/index.html

# ══════════════════════════════════════════════════════════════
# 12. PROFIL SHELL — Aliases & PATH
# ══════════════════════════════════════════════════════════════
RUN printf '\n# --- ExenKit ---\nalias ll="ls -lah --color=auto"\nalias la="ls -A --color=auto"\nalias cls="clear"\nalias zshreload="source ~/.zshrc"\nalias myip="curl -s ifconfig.me"\nalias cc="claude"\nalias omx="oh-my-codex"\nalias ws="windsurf"\nexport PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"\nexport NODE_PATH="/usr/local/lib/node_modules"\n' \
    >> /root/.zshrc \
    && printf '\n# --- ExenKit ---\nexport PATH="$PATH:/usr/local/bin:/opt/xdman:/root/.npm-global/bin"\nalias ll="ls -lah --color=auto"\nalias cc="claude"\nalias omx="oh-my-codex"\n' \
    >> /root/.bashrc

# ══════════════════════════════════════════════════════════════
# 13. SCRIPTS EMBARQUÉS (générés dans l'image, pas copiés)
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d /etc/exenkit /scripts /workspace

# --- start-xfce.sh ---
RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
export HOME=/root\n\
export USER=root\n\
export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
export XDG_SESSION_TYPE=x11\n\
export XDG_CURRENT_DESKTOP=XFCE\n\
mkdir -p /tmp/runtime-root && chmod 700 /tmp/runtime-root\n\
for i in $(seq 1 30); do\n\
    xdpyinfo -display :1 >/dev/null 2>&1 && echo "[xfce] Xvfb pret" && break\n\
    echo "[xfce] Attente Xvfb ($i/30)..."\n\
    sleep 1\n\
done\n\
xrandr --display :1 --auto 2>/dev/null || true\n\
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then\n\
    eval $(dbus-launch --sh-syntax) 2>/dev/null || true\n\
fi\n\
echo "[xfce] Demarrage XFCE4..."\n\
exec startxfce4 --display :1 2>&1\n' \
    > /scripts/start-xfce.sh

# --- start-vnc.sh ---
RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
for i in $(seq 1 40); do\n\
    xdpyinfo -display :1 >/dev/null 2>&1 && echo "[vnc] Display :1 ok" && break\n\
    echo "[vnc] Attente display ($i/40)..."\n\
    sleep 1\n\
done\n\
sleep 4\n\
if [ -f /root/.vnc/passwd ]; then\n\
    AUTH_OPTS="-rfbauth /root/.vnc/passwd"\n\
else\n\
    AUTH_OPTS="-nopw"\n\
fi\n\
echo "[vnc] Demarrage x11vnc..."\n\
exec x11vnc \\\n\
    -display :1 \\\n\
    $AUTH_OPTS \\\n\
    -listen 0.0.0.0 \\\n\
    -rfbport 5900 \\\n\
    -xkb -ncache 10 -ncache_cr \\\n\
    -forever -shared -repeat \\\n\
    -cursor most 2>&1\n' \
    > /scripts/start-vnc.sh

# --- start-novnc.sh ---
RUN printf '#!/bin/bash\n\
for i in $(seq 1 60); do\n\
    nc -z localhost 5900 2>/dev/null && echo "[novnc] x11vnc pret" && break\n\
    echo "[novnc] Attente x11vnc ($i/60)..."\n\
    sleep 1\n\
done\n\
NOVNC_DIR="/usr/share/novnc"\n\
echo "[novnc] Demarrage websockify :6515 -> :5900"\n\
exec websockify \\\n\
    --web="$NOVNC_DIR" \\\n\
    --heartbeat=30 \\\n\
    6515 \\\n\
    localhost:5900 2>&1\n' \
    > /scripts/start-novnc.sh

RUN chmod +x /scripts/start-xfce.sh /scripts/start-vnc.sh /scripts/start-novnc.sh

# ══════════════════════════════════════════════════════════════
# 14. SUPERVISORD CONFIG
# ══════════════════════════════════════════════════════════════
COPY supervisord.conf /etc/supervisor/conf.d/exenkit.conf

# ══════════════════════════════════════════════════════════════
# 15. ENTRYPOINT
# ══════════════════════════════════════════════════════════════
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace
EXPOSE 5900 6515
ENTRYPOINT ["/entrypoint.sh"]
