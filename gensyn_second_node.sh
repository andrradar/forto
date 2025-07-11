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
    echo -e "${YELLOW}Выберите действие для ВТОРОЙ НОДЫ:${NC}"
    echo -e "${CYAN}1) Установка второй ноды${NC}"
    echo -e "${CYAN}2) Обновление второй ноды${NC}"
    echo -e "${CYAN}3) Просмотр логов второй ноды${NC}"
    echo -e "${CYAN}4) Рестарт второй ноды${NC}"
    echo -e "${CYAN}5) Удаление второй ноды${NC}"

    echo -e "${YELLOW}Введите номер:${NC} "
    read choice

    case $choice in
        1)
            echo -e "${BLUE}Установка второй ноды Gensyn...${NC}"

            # Обновление и установка зависимостей
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install curl build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y

            # Проверка наличия Docker и Docker Compose
            if ! command -v docker &> /dev/null; then
                echo -e "${BLUE}Docker не установлен. Устанавливаем Docker...${NC}"
                sudo apt install docker.io -y
            fi
    
            if ! command -v docker-compose &> /dev/null; then
                echo -e "${BLUE}Docker Compose не установлен. Устанавливаем Docker Compose...${NC}"
                sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
            fi

            sudo usermod -aG docker $USER
            sleep 1
            sudo apt-get install python3 python3-pip
            sleep 1

            git clone https://github.com/gensyn-ai/rl-swarm/ rl-swarm1
            cd rl-swarm1

            mv docker-compose.yaml docker-compose.yaml.old

            cat << 'EOF' > docker-compose.yaml
version: '3'

services:
  otel-collector-node2:
    image: otel/opentelemetry-collector-contrib:0.120.0
    ports:
      - "4319:4317"  # OTLP gRPC (изменен порт для второй ноды)
      - "4320:4318"  # OTLP HTTP (изменен порт для второй ноды)
      - "55680:55679"  # Prometheus metrics (изменен порт для второй ноды)
    environment:
      - OTEL_LOG_LEVEL=DEBUG

  swarm_node_2:
    image: europe-docker.pkg.dev/gensyn-public-b7d9/public/rl-swarm:v0.0.2
    command: ./run_hivemind_docker.sh
    #runtime: nvidia  # Enables GPU support; remove if no GPU is available
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector-node2:4317
      - PEER_MULTI_ADDRS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
      - HOST_MULTI_ADDRS=/ip4/0.0.0.0/tcp/38332
    ports:
      - "38332:38332"  # Изменен порт P2P для второй ноды
    depends_on:
      - otel-collector-node2

  fastapi_node2:
    build:
      context: .
      dockerfile: Dockerfile.webserver
    environment:
      - OTEL_SERVICE_NAME=rlswarm-fastapi-node2
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector-node2:4317
      - INITIAL_PEERS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
    ports:
      - "8178:8000"  # Изменен API порт для второй ноды (8178 вместо 8177)
    depends_on:
      - otel-collector-node2
      - swarm_node_2
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/healthz"]
      interval: 30s
      retries: 3
EOF

            # Проверка доступности docker-compose
            if command -v docker-compose &> /dev/null; then
                COMPOSE_CMD="docker-compose"
            elif docker compose version &> /dev/null; then
                COMPOSE_CMD="docker compose"
            else
                echo -e "${RED}Docker Compose не найден! Устанавливаем...${NC}"
                sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
                COMPOSE_CMD="docker-compose"
            fi

            $COMPOSE_CMD pull
            $COMPOSE_CMD up -d

            # Заключительное сообщение
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${YELLOW}Команда для проверки логов второй ноды:${NC}"
            echo "cd rl-swarm1 && $COMPOSE_CMD logs -f swarm_node_2"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 2
            $COMPOSE_CMD logs -f swarm_node_2
            ;;

        2)
            echo -e "${BLUE}Обновление второй ноды Gensyn...${NC}"
            VER=rl-swarm:v0.0.2
            cd rl-swarm1
            
            # Проверка доступности docker-compose
            if command -v docker-compose &> /dev/null; then
                COMPOSE_CMD="docker-compose"
            elif docker compose version &> /dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
            
            sed -i "s#\(image: europe-docker.pkg.dev/gensyn-public-b7d9/public/\).*#\1$VER#g" docker-compose.yaml
            $COMPOSE_CMD pull
            $COMPOSE_CMD up -d --force-recreate
            # Заключительное сообщение
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${YELLOW}Команда для проверки логов второй ноды:${NC}"
            echo "cd rl-swarm1 && $COMPOSE_CMD logs -f swarm_node_2"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 2
            $COMPOSE_CMD logs -f swarm_node_2
            ;;

        3)
            echo -e "${BLUE}Просмотр логов второй ноды...${NC}"
            cd rl-swarm1
            
            # Проверка доступности docker-compose
            if command -v docker-compose &> /dev/null; then
                COMPOSE_CMD="docker-compose"
            elif docker compose version &> /dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
            
            $COMPOSE_CMD logs -f swarm_node_2
            ;;

        4)
            echo -e "${BLUE}Рестарт второй ноды...${NC}"
            cd rl-swarm1
            
            # Проверка доступности docker-compose
            if command -v docker-compose &> /dev/null; then
                COMPOSE_CMD="docker-compose"
            elif docker compose version &> /dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
            
            $COMPOSE_CMD restart
            $COMPOSE_CMD logs -f swarm_node_2
            ;;
            
        5)
            echo -e "${BLUE}Удаление второй ноды Gensyn...${NC}"

            cd rl-swarm1
            
            # Проверка доступности docker-compose
            if command -v docker-compose &> /dev/null; then
                COMPOSE_CMD="docker-compose"
            elif docker compose version &> /dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi

            # Остановка и удаление контейнера
            $COMPOSE_CMD down -v

            # Удаление папки
            if [ -d "$HOME/rl-swarm1" ]; then
                rm -rf $HOME/rl-swarm1
                echo -e "${GREEN}Директория второй ноды удалена.${NC}"
            else
                echo -e "${RED}Директория второй ноды не найдена.${NC}"
            fi

            echo -e "${GREEN}Вторая нода Gensyn успешно удалена!${NC}"
            echo -e "${CYAN}Первая нода (rl-swarm) остается работать!${NC}"

            # Завершающий вывод
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 1
            ;;

        *)
            echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 5!${NC}"
            ;;
    esac
