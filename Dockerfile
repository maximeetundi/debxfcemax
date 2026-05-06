# ============================================================
#  ExenKit — Debian 13 (Trixie) | LXQt | noVNC | Dev Stack
# ============================================================
FROM debian:trixie-slim

# ══════════════════════════════════════════════════════════════
# ARGUMENTS DE CONSTRUCTION
# ══════════════════════════════════════════════════════════════
ARG INSTALL_FIREFOX=true
ARG INSTALL_VLC=true
ARG INSTALL_JAVA=true
ARG INSTALL_NODEJS=true
ARG INSTALL_WINDSURF=true
ARG INSTALL_XDM=true
ARG INSTALL_CLAUDE=true
ARG INSTALL_CODEX=true

# Utilisateur non-root
ARG USERNAME=exenkit
ARG USER_UID=1000
ARG USER_GID=$USER_UID

LABEL maintainer="ExenKit"
LABEL description="Debian 13 LXQt Desktop — VLC, Firefox, XDM, Windsurf, Claude Code, Codex, Telegram"

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    HOME=/home/$USERNAME \
    USER=$USERNAME \
    LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8 \
    RESOLUTION=1920x1080x24 \
    VNC_PASSWORD=ExenKit2025!

# ══════════════════════════════════════════════════════════════
# 1. PAQUETS SYSTÈME DE BASE & UTILISATEUR
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
    # Création utilisateur
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /usr/bin/zsh \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════
# 2. LXQT + VNC + noVNC + ICONES
# ══════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    lxqt-core lxqt-session lxqt-panel lxqt-qtplugin lxqt-config lxqt-notificationd \
    pcmanfm-qt qterminal lximage-qt screengrab \
    openbox obconf-qt \
    papirus-icon-theme breeze-icon-theme oxygen-icon-theme \
    x11vnc novnc websockify \
    supervisor \
    dbus-x11 at-spi2-core \
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
    && rm -rf /var/lib/apt/lists/*; \
    fi

# ══════════════════════════════════════════════════════════════
# 5. WINDSURF IDE
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
# 6. XDM 7.2.10
# ══════════════════════════════════════════════════════════════
RUN if [ "$INSTALL_XDM" = "true" ]; then \
    mkdir -p /tmp/xdm-install \
    && wget --progress=dot:giga \
        -O /tmp/xdm-install/xdm-setup-7.2.10.tar.xz \
        "https://github.com/subhra74/xdm/releases/download/7.2.10/xdm-setup-7.2.10.tar.xz" \
    && cd /tmp/xdm-install \
    && tar -xf xdm-setup-7.2.10.tar.xz \
    && chmod +x install.sh 2>/dev/null || true \
    && (yes "" | ./install.sh 2>/dev/null || true) \
    && if [ ! -f /usr/local/bin/xdm ]; then \
        printf '#!/bin/bash\nexec java -jar /opt/xdman/xdman.jar "$@"\n' > /usr/local/bin/xdm \
        && chmod +x /usr/local/bin/xdm; \
    fi \
    && rm -rf /tmp/xdm-install; \
    fi

# ══════════════════════════════════════════════════════════════
# 7. OH MY ZSH (User)
# ══════════════════════════════════════════════════════════════
USER $USERNAME
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh \
    && cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
        $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' $HOME/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)/' $HOME/.zshrc

# ══════════════════════════════════════════════════════════════
# 8. PRE-CONFIGURATION LXQT (ICONES)
# ══════════════════════════════════════════════════════════════
RUN mkdir -p $HOME/.config/lxqt \
    && printf '[General]\nicon_theme=Papirus\n' > $HOME/.config/lxqt/lxqt.conf \
    && mkdir -p $HOME/.config/pcmanfm-qt/default \
    && printf '[Desktop]\nWallpaper=/usr/share/images/desktop-base/default\n' > $HOME/.config/pcmanfm-qt/default/settings.conf

# ══════════════════════════════════════════════════════════════
# 9. CLAUDE & CODEX (Root permissions needed for -g)
# ══════════════════════════════════════════════════════════════
USER root
RUN if [ "$INSTALL_CLAUDE" = "true" ] && command -v npm >/dev/null 2>&1; then npm install -g @anthropic-ai/claude-code; fi \
    && if [ "$INSTALL_CODEX" = "true" ] && command -v npm >/dev/null 2>&1; then npm install -g oh-my-codex; fi

# ══════════════════════════════════════════════════════════════
# 10. noVNC index
# ══════════════════════════════════════════════════════════════
RUN printf '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>ExenKit Desktop</title>\n<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale&quality=9&compression=0">\n</head>\n<body style="background:#1a1a2e;color:#fff;font-family:monospace;text-align:center;padding-top:40px">\n<h2>ExenKit - Connexion en cours...</h2>\n<p>Debian 13 LXQt | Dev Desktop</p>\n</body>\n</html>\n' \
    > /usr/share/novnc/index.html

# ══════════════════════════════════════════════════════════════
# 11. PREPARATION & SCRIPTS
# ══════════════════════════════════════════════════════════════
RUN mkdir -p /var/log/supervisor /etc/exenkit /scripts /workspace \
    && chown -R $USERNAME:$USERNAME /var/log/supervisor /etc/exenkit /scripts /workspace

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY start-lxqt.sh /scripts/start-lxqt.sh
COPY start-vnc.sh /scripts/start-vnc.sh
COPY start-novnc.sh /scripts/start-novnc.sh

RUN chmod +x /entrypoint.sh /scripts/*.sh \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

WORKDIR /workspace
EXPOSE 5900 6515
ENTRYPOINT ["/entrypoint.sh"]
