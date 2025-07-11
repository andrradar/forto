#!/bin/bash
# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Отображаем логотип
curl -s https://raw.githubusercontent.com/noxuspace/cryptofortochka/main/logo_club.sh | bash

# Меню
echo -e "${YELLOW}Выберите действие:${NC}"
echo -e "${CYAN}1) Установка ноды${NC}"
echo -e "${CYAN}2) Обновление ноды${NC}"
echo -e "${CYAN}3) Просмотр логов${NC}"
echo -e "${CYAN}4) Удаление ноды${NC}"
echo -e "${YELLOW}Введите номер:${NC} "
read choice

case $choice in
    1)
        echo -e "${BLUE}Установка ноды Gensyn...${NC}"
        # Обновление и установка зависимостей
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
        
        # Проверка наличия Docker
        if ! command -v docker &> /dev/null; then
            echo -e "${BLUE}Docker не установлен. Устанавливаем Docker...${NC}"
            sudo apt update
            sudo apt install docker.io -y
            # Запуск Docker-демона, если он не запущен
            sudo systemctl enable --now docker
        fi
        
        # Проверка наличия Docker Compose
        if ! command -v docker-compose &> /dev/null; then
            echo -e "${BLUE}Docker Compose не установлен. Устанавливаем Docker Compose...${NC}"
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        sudo usermod -aG docker $USER
        sleep 1
        
        # Установка Python зависимостей
        sudo apt-get install python3 python3-pip python3-venv python3-dev -y
        sleep 1
        
        # Установка Node.js и Yarn
        sudo apt-get update
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
        node -v
        sudo npm install -g yarn
        yarn -v
        curl -o- -L https://yarnpkg.com/install.sh | bash
        export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
        source ~/.bashrc
        
        # Клонирование репозитория
        cd
        git clone https://github.com/gensyn-ai/rl-swarm/
        cd $HOME/rl-swarm/modal-login
        
        # ===== ИСПРАВЛЕННАЯ ЧАСТЬ: Установка всех необходимых зависимостей =====
        echo -e "${BLUE}Установка всех необходимых зависимостей...${NC}"
        
        # Удаление конфликтующих файлов
        rm -f package-lock.json
        
        # Установка всех зависимостей одной командой для избежания конфликтов
        yarn add @babel/preset-env @babel/core @wagmi/core@2.17.2 viem@2.29.2 encoding pino-pretty next@latest --ignore-engines
        
        # Установка react-native зависимостей (могут вызывать конфликты, но нужны для работы)
        yarn add react-native@0.76.0 react-native-inappbrowser-reborn@3.7.0 react-native-mmkv@3.1.0 --ignore-engines --ignore-peer-deps
        
        # Переустановка всех зависимостей с игнорированием предупреждений
        yarn install --ignore-engines --ignore-peer-deps
        
        echo -e "${GREEN}Все зависимости установлены!${NC}"
        echo -e "${YELLOW}Предупреждения о peer dependencies можно игнорировать - они не критичны для работы.${NC}"
        # =================================================================
        
        cd
        echo -e "${GREEN}Установка завершена! Теперь можете запускать ноду командой:${NC}"
        echo -e "${CYAN}source ~/.bashrc${NC}"
        echo -e "${CYAN}затем${NC}"
        echo -e "${CYAN}screen -S gensyn${NC}"
        echo -e "${CYAN}затем{NC}"
        echo -e "${CYAN}cd ~/rl-swarm${NC}"
        echo -e "${CYAN}python3 -m venv .venv${NC}"
        echo -e "${CYAN}source .venv/bin/activate${NC}"
        echo -e "${CYAN}./run_rl_swarm.sh${NC}"
        echo -e "${RED}Или следуйте дальнейшим инструкциям в текстовом гайде!${NC}"
        ;;
    2)
        echo -e "${BLUE}Обновление зависимостей ноды...${NC}"
        if [ -d "$HOME/rl-swarm" ]; then
            cd $HOME/rl-swarm/modal-login
            
            # Удаление конфликтующих файлов
            rm -f package-lock.json
            
            # Обновление всех зависимостей одной командой
            echo -e "${BLUE}Обновление зависимостей...${NC}"
            yarn add @babel/preset-env @babel/core @wagmi/core@2.17.2 viem@2.29.2 encoding pino-pretty next@latest --ignore-engines
            yarn add react-native@0.76.0 react-native-inappbrowser-reborn@3.7.0 react-native-mmkv@3.1.0 --ignore-engines --ignore-peer-deps
            yarn install --ignore-engines --ignore-peer-deps
            
            echo -e "${GREEN}Зависимости обновлены!${NC}"
            echo -e "${YELLOW}Предупреждения о peer dependencies можно игнорировать.${NC}"
            echo -e "${BLUE}Теперь можете перезапустить ноду.${NC}"
        else
            echo -e "${RED}Директория rl-swarm не найдена. Сначала установите ноду.${NC}"
        fi
        ;;
    3)
        cd
        screen -r gensyn
        ;;
        
    4)
        echo -e "${BLUE}Удаление ноды Gensyn...${NC}"
        # Находим все сессии screen, содержащие "gensyn"
        SESSION_IDS=$(screen -ls | grep "gensyn" | awk '{print $1}' | cut -d '.' -f 1)

        # Если сессии найдены, удаляем их
        if [ -n "$SESSION_IDS" ]; then
            echo -e "${BLUE}Завершение сессий screen с идентификаторами: $SESSION_IDS${NC}"
            for SESSION_ID in $SESSION_IDS; do
                screen -S "$SESSION_ID" -X quit
            done
        else
            echo -e "${BLUE}Сессии screen для ноды Gensyn не найдены, продолжаем удаление${NC}"
        fi
        # Удаление папки
        if [ -d "$HOME/rl-swarm" ]; then
            rm -rf $HOME/rl-swarm
            echo -e "${GREEN}Директория ноды удалена.${NC}"
        else
            echo -e "${RED}Директория ноды не найдена.${NC}"
        fi
        echo -e "${GREEN}Нода Gensyn успешно удалена!${NC}"
        # Завершающий вывод
        echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
        echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
        echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
        sleep 1
        ;;
    *)
        echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 4!${NC}"
        ;;
esac
