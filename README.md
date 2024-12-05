# Media Stack Automated Installer

## Overview

This bash script provides an automated installation and setup for a comprehensive media management and streaming stack on Ubuntu 22.04 LTS. The script simplifies the process of setting up a home media server with various tools for downloading, managing, and streaming movies and TV shows.

## 🚀 Features

- Automated Docker and Docker Compose installation
- One-click deployment of media stack services
- Optional VPN integration
- Automatic network and volume configuration
- Support for multiple VPN providers

## 📦 Included Services

- **qBittorrent**: Torrent client
- **Radarr**: Movie management and download automation
- **Sonarr**: TV show management and download automation
- **Prowlarr**: Indexer management
- **Jellyfin**: Media server and streaming platform
- **Jellyseerr**: Media recommendation and request system

## 🛠️ Prerequisites

- Ubuntu 22.04 LTS
- Sudo/root access
- Stable internet connection

## 🔧 Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/Goshko812/media-stack-script/refs/heads/main/setup.sh
```

2. Make the script executable:
```bash
chmod +x setup.sh
```

3. Run the script with sudo:
```bash
sudo ./setup.sh
```

## 🌐 VPN Configuration(Not Tested - Might Remove It Later)

The script supports optional VPN configuration with the following providers:
- NordVPN
- ExpressVPN
- SurfShark
- ProtonVPN
- Custom OpenVPN

During installation, you'll be prompted to:
- Choose a VPN provider
- Enter VPN credentials
- Select server country

## 🖥️ Service Access

After installation, access services at these default ports:
- qBittorrent: `http://localhost:5080`
- Radarr: `http://localhost:7878`
- Sonarr: `http://localhost:8989`
- Prowlarr: `http://localhost:9696`
- Jellyfin: `http://localhost:8096`
- Jellyseerr: `http://localhost:5055`
- Or at your public IP + port

## ⚠️ Important Notes

- Change default passwords immediately
- Verify VPN credentials if using VPN
- Check qBittorrent logs for default login credentials

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Goshko812/media-stack-script/issues).

## 📝 License

[MIT](https://github.com/Goshko812/media-stack-script/blob/main/LICENSE)

## 🙏 Acknowledgments
- [Navilg](https://github.com/navilg/media-stack) for the original docker compose script
- Docker
- Docker Compose
- All the amazing open-source projects integrated in this media stack
