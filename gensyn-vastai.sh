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

            # Fix .bashrc PS1 if needed
            if ! grep -q "case \\$- in" ~/.bashrc; then
                echo -e "${BLUE}Patching .bashrc to prevent PS1 errors...${NC}"
                echo -e '# ~/.bashrc: executed by bash(1) for non-login shells.\n\ncase $- in\n *i*) ;;\n *) return;;\nesac\n' | cat - ~/.bashrc > ~/.bashrc.tmp && mv ~/.bashrc.tmp ~/.bashrc
            fi

            cd ~
            git clone https://github.com/gensyn-ai/rl-swarm
            cd ~/rl-swarm/modal-login
            npm install viem@2.22.6
            cd

            # Check for login creds
            if [[ ! -f "$HOME/rl-swarm/swarm.pem" || ! -f "$HOME/rl-swarm/modal-login/temp-data/userData.json" || ! -f "$HOME/rl-swarm/modal-login/temp-data/userApiKey.json" ]]; then
                echo -e "${YELLOW}Warning: You are missing one or more login credentials.${NC}"
                echo -e "${CYAN}You will need to forward port 3000 and open http://localhost:3000 for login.${NC}"
            fi

            mkdir -p $HOME/gensyn-backup
            cp $HOME/rl-swarm/swarm.pem $HOME/gensyn-backup/ 2>/dev/null
            cp $HOME/rl-swarm/modal-login/temp-data/user*.json $HOME/gensyn-backup/ 2>/dev/null
            echo -e "${GREEN}Login credentials backed up to ~/gensyn-backup (if present).${NC}"

            echo -e "${YELLOW}To start your node, run:${NC}"
            echo -e "${CYAN}cd ~/rl-swarm && source .venv/bin/activate && ./run_rl_swarm.sh${NC}"
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
