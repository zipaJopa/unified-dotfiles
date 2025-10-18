# 🏠 Pavle's Unified Dotfiles - Phone Home System

**SAMO JAKO!** 💪

One dotfiles repo to rule them all - phones, servers, desktops - sinhronizovano preko GitHuba.

## 🎯 Cilj

Jednom napravi, svugde koristi. Nikad više:
- ❌ Izgubljeni konfigi
- ❌ Zaboravljeni API keys
- ❌ Duplirani setup skripte
- ❌ "Gde sam ja to čuvao?"

## 📦 Šta sadrži?

```
unified-dotfiles/
├── agents/           # Agent system (Python)
├── scripts/          # Magisk, network, utilities
├── termux/           # Termux-specific configs
├── voice/            # TTS/Voice system
├── configs/          # Universal configs
└── phone-home/       # Auto-sync system 🔥
```

## 🚀 Brzi Start

### Na novom uređaju (Android/Termux):
```bash
curl -fsSL https://raw.githubusercontent.com/pavlebradic/unified-dotfiles/main/install.sh | bash
```

### Na Linux/WSL:
```bash
git clone https://github.com/pavlebradic/unified-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## 📡 Phone-Home Sistem

Automatski syncuje izmene sa GitHubom svaki sat.

### Manual sync:
```bash
~/.dotfiles/phone-home/sync.sh
```

## 🛡️ Sigurnost

- Credentials NE idu na GitHub! (.gitignore ih blokira)
- API keys čuvaj u .env (lokalno)

## 📱 Podržani Uređaji

- ✅ Android (Termux)
- ✅ Linux (Ubuntu, Debian, Arch)
- ✅ WSL
- ✅ Proxmox LXC

## 📊 Stats

- **Uređaji**: 10+
- **Fajlova**: 38+
- **Linija koda**: 2388+

---

**Made with ❤️ and Claude Code**

SAMO JAKO! 💪
