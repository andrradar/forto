#!/bin/bash

# Tsveta dlya terminala
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Proverka na curl
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Logo
curl -s https://raw.githubusercontent.com/noxuspace/cryptofortochka/main/logo_club.sh | bash

# Menu
    echo -e "${YELLOW}Viberite deistvie:${NC}"
    echo -e "${CYAN}1) Ustanovka nody${NC}"
    echo -e "${CYAN}2) Obnovlenie nody${NC}"
    echo -e "${CYAN}3) Prosmotr logov${NC}"
    echo -e "${CYAN}4) Udalenie nody${NC}"

    echo -e "${YELLOW}Vvedite nomer:${NC} "
    read choice

    case $choice in
        1)
            echo -e "${BLUE}Ustanovka Gensyn node...${NC}"

            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev python3 python3-pip python3-venv python3-dev -y

            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt-get install -y nodejs
            sudo npm install -g yarn
            curl -o- -L https://yarnpkg.com/install.sh | bash
            export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
            source ~/.bashrc

            cd ~
            git clone https://github.com/gensyn-ai/rl-swarm
            cd ~/rl-swarm/modal-login
            npm install viem@2.22.6
            cd

            echo -e "${RED}Vernis k tekstovomu gaydu i sledui sleduyushchim shagom!${NC}"
            ;;

        2)
            echo -e "${BLUE}Sleduy instruktsiyam v razdele ob obnovlenii v gayde${NC}"
            ;;

        3)
            echo -e "${BLUE}Vykhod v logy screen (esli est):${NC}"
            tmux attach || echo -e "${RED}Net aktivnyh tmux sessii.${NC}"
            ;;

        4)
            echo -e "${BLUE}Udalenie Gensyn node...${NC}"

            if [ -d "$HOME/rl-swarm" ]; then
                rm -rf $HOME/rl-swarm
                echo -e "${GREEN}Direktoriya nody udalena.${NC}"
            else
                echo -e "${RED}Direktoriya nody ne naydena.${NC}"
            fi

            echo -e "${GREEN}Gensyn node uspeshno udalena!${NC}"
            echo -e "${PURPLE}-------------------------------------------------${NC}"
            echo -e "${GREEN}Crypto Fortochka — vsya kripta v odnom meste!${NC}"
            echo -e "${CYAN}Telegram: https://t.me/cryptoforto${NC}"
            sleep 1
            ;;

        *)
            echo -e "${RED}Nevernyy vibor. Vvedi ot 1 do 4.${NC}"
            ;;
    esac
