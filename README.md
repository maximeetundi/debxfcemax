# 🚀 ExenKit — Debian 13 Desktop Suite

> Bureau LXQt complet dans Docker, accessible depuis votre navigateur via noVNC.

---

## 📦 Stack installée

| Outil | Description |
|-------|-------------|
| **Debian 13 (Trixie)** | Base système |
| **LXQt + Core Apps** | Bureau graphique léger (Qt) |
| **noVNC** | Accès web au bureau |
| **Firefox ESR** | Navigateur web |
| **VLC** | Lecteur multimédia |
| **Telegram Desktop** | Messagerie |
| **XDM 7.2.10** | Gestionnaire de téléchargements (version exacte) |
| **Windsurf IDE** | Éditeur de code (Codeium) |
| **Claude Code** | CLI Anthropic IA |
| **Codex CLI** | CLI OpenAI |
| **oh-my-codex** | CLI avancé Codex — commande `omx` |
| **Oh My Zsh** | Shell avancé + plugins |
| **Node.js 22 LTS** | Runtime JavaScript |

---

## 🛠 Démarrage rapide

### 1. Préparer les variables

```bash
cp .env.example .env
# Éditez .env avec vos clés API et mot de passe VNC
nano .env
```

### 2. Construire et lancer

```bash
docker compose up -d --build
```

> ⏳ La première build prend ~10–20 min selon votre connexion.

### 3. Accéder au bureau

Ouvrez votre navigateur :

```
http://localhost:6515
```

Mot de passe VNC par défaut : `ExenKit2025!`

---

## 🖥 Ports exposés

| Port | Service |
|------|---------|
| `6515` | noVNC (interface web) |
| `5900` | VNC direct (client VNC) |

---

## 💻 Utiliser les outils IA

### Claude Code
```bash
# Dans le terminal LXQt (QTerminal)
claude "Explique ce code"
claude --help
```

### OpenAI Codex
```bash
codex "Crée une API REST en Python"
codex --help
```

### Raccourcis (Oh My Zsh)
```bash
cc      # alias → claude
codex   # OpenAI Codex CLI
omx     # oh-my-codex CLI
ws      # alias → windsurf
xdm     # lancer XDM Download Manager
```

---

## 📁 Volumes persistants

| Volume | Contenu |
|--------|---------|
| `exenkit-home` | `/home/exenkit` — configuration & fichiers user |
| `exenkit-projects` | `/workspace` — vos projets |

---

## 🔧 Commandes utiles

```bash
# Voir les logs en direct
docker compose logs -f

# Redémarrer le bureau
docker compose restart

# Accéder au terminal du conteneur
docker compose exec exenkit zsh

# Arrêter proprement
docker compose down

# Supprimer + volumes (reset complet)
docker compose down -v
```

---

## 🔑 Changer le mot de passe VNC

Dans le `.env` ou à la volée :
```bash
docker compose exec exenkit x11vnc -storepasswd MonNouveauMotDePasse /root/.vnc/passwd
```

---

## 📝 Notes

- **XDM 7.2.10** : version exacte depuis `https://github.com/subhra74/xdm/releases/download/7.2.10/`
- **Windsurf** : installez vos extensions depuis l'interface Codeium intégrée
- **Résolution** : changez `RESOLUTION` dans `.env` (ex: `2560x1440x24`)
- **Fuseau horaire** : par défaut `Africa/Douala` (Cameroun)
