#!/bin/bash

# Media Stack Installer for Ubuntu 22.04 LTS
# Version: 1.0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root. Use sudo.${NC}"
   exit 1
fi

prepare_system() {
    echo -e "${YELLOW}Preparing system and installing dependencies...${NC}"
    
    apt-get update

    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        git \
        wget

    install_docker
}

install_docker() {
    echo -e "${YELLOW}Installing Docker...${NC}"
    
    apt-get remove docker docker-engine docker.io containerd runc -y

    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker "$SUDO_USER"
    fi
}

create_media_stack() {
    echo -e "${YELLOW}Setting up Media Stack...${NC}"
    
    # Create directory
    mkdir -p /opt/media-stack
    cd /opt/media-stack

    # Download docker-compose.yml
    wget https://raw.githubusercontent.com/Goshko812/media-stack-script/refs/heads/main/docker-compose.yml || {
        echo -e "${RED}Failed to download docker-compose.yml${NC}"
        exit 1
    }

}

# Configure VPN (optional)(haven't tried yet so yeah this will probably get removed or some shit later)
configure_vpn() {
    echo -e "${YELLOW}VPN Configuration${NC}"
    
    read -p "Do you want to use a VPN? (y/n): " use_vpn
    
    if [[ $use_vpn == "y" ]]; then
        echo -e "${YELLOW}Available VPN Providers:${NC}"
        echo "1. NordVPN"
        echo "2. ExpressVPN"
        echo "3. SurfShark"
        echo "4. ProtonVPN"
        echo "5. Custom OpenVPN"
        
        read -p "Choose VPN Provider (1-5): " vpn_choice
        
        read -p "Enter VPN Username: " vpn_username
        read -sp "Enter VPN Password: " vpn_password
        echo
        
        read -p "Enter Server Country (e.g., Switzerland): " server_country

        # Export VPN variables
        export VPN_SERVICE_PROVIDER=$(case $vpn_choice in
            1) echo "nordvpn" ;;
            2) echo "expressvpn" ;;
            3) echo "surfshark" ;;
            4) echo "protonvpn" ;;
            5) read -p "Enter custom VPN provider name: " custom_vpn; echo "$custom_vpn" ;;
            *) echo "nordvpn" ;;
        esac)
        export OPENVPN_USER="$vpn_username"
        export OPENVPN_PASSWORD="$vpn_password"
        export SERVER_COUNTRIES="$server_country"
    fi
}

deploy_media_stack() {
    echo -e "${YELLOW}Deploying Media Stack...${NC}"
    
    docker network create --subnet 172.20.0.0/16 mynetwork || true

    # Deploy with or without VPN
    if [ -n "$VPN_SERVICE_PROVIDER" ]; then
        echo -e "${GREEN}Deploying with VPN: $VPN_SERVICE_PROVIDER${NC}"
        docker compose --profile vpn up -d
    else
        echo -e "${GREEN}Deploying without VPN${NC}"
        docker compose --profile no-vpn up -d
    fi

    docker exec qbittorrent mkdir -p /downloads/movies /downloads/tvshows
    docker exec qbittorrent chown 1000:1000 /downloads/movies /downloads/tvshows
}

post_install_instructions() {
    echo -e "${GREEN}Media Stack Installation Complete!${NC}"
    echo -e "${YELLOW}Access your services at the following default ports:${NC}"
    echo "- qBittorrent: http://localhost:5080"
    echo "- Radarr: http://localhost:7878"
    echo "- Sonarr: http://localhost:8989"
    echo "- Prowlarr: http://localhost:9696"
    echo "- Jellyfin: http://localhost:8096"
    echo "- Jellyseerr: http://localhost:5055"
    
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "1. Configure each service through its web interface"
    echo "2. Set up indexers in Prowlarr"
    echo "3. Add download clients in Radarr/Sonarr"
    echo "4. Create media libraries in Jellyfin"
    
    echo -e "\n${RED}IMPORTANT:${NC}"
    echo "- Default credentials for qbittorrent can be found using the ${RED}docker logs qbittorrent${NC} command"
    echo "- Change default password immediately"
    echo "- If using VPN, ensure your VPN credentials are correct"

    read -p "Do you want a detailed configuration guide? (y/n): " show_guide
    
    if [[ $show_guide == "y" ]]; then
        display_configuration_guide
    fi
}

display_configuration_guide() {
    echo -e "\n${GREEN}=== Detailed Configuration Guide ===${NC}"
    echo -e "\n${YELLOW}## Configure qBittorrent${NC}"
    echo "- Open qBitTorrent at http://localhost:5080. Default username is 'admin'."
    echo "- Temporary password can be collected from container log: ${RED}docker logs qbittorrent${NC}"
    echo "- Go to Tools --> Options --> WebUI --> Change password"

    echo -e "\n${YELLOW}## Configure Radarr${NC}"
    echo "- Open Radarr at http://localhost:7878"
    echo "- Settings --> Media Management --> Check 'Movies deleted from disk are automatically unmonitored in Radarr'"
    echo "- Add Root Folder: /downloads/movies"
    echo "- Configure Download Client: Add qBittorrent (host: qbittorrent, port: 5080)"
    echo "- ${RED}Note:${NC} If using VPN, use 'vpn' as host instead"

    echo -e "\n${YELLOW}## Configure Sonarr${NC}"
    echo "- Similar configuration to Radarr, but for TV shows"
    echo "- Root Folder: /downloads/tvshows"

    echo -e "\n${YELLOW}## Configure Jellyfin${NC}"
    echo "- Open Jellyfin at http://localhost:8096"
    echo "- Follow the initial setup wizard"
    echo "- Add media library folder: /data/movies/"

    echo -e "\n${YELLOW}## Configure Jellyseerr${NC}"
    echo "- Open Jellyseerr at http://localhost:5055"
    echo "- Follow the initial setup wizard"
    echo "- Provide Sonarr and Radarr details"
    echo "- Detailed setup: https://docs.overseerr.dev/"

    echo -e "\n${YELLOW}## Configure Prowlarr${NC}"
    echo "- Open Prowlarr at http://localhost:9696"
    echo "- Set up Authentication"
    echo "- Add Indexers"
    echo "- Add Radarr and Sonarr as applications"
    echo -e "${RED}Note:${NC} With VPN, use static IPs or modified service names"

    echo -e "\n${YELLOW}## Configure Bazarr${NC}"
    echo "- Open Prowlarr at http://localhost:6767"
    echo "- Set up Authentication"
    echo "- Add Providers"
    echo "- Add default languages"
    echo "- Add Radarr and Sonarr"
}

main() {
    clear
    echo -e "${GREEN}Media Stack Automated Installer${NC}"
    
    prepare_system
    
    create_media_stack
    
    configure_vpn
    
    deploy_media_stack
    
    post_install_instructions
}

main
