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
    echo -e "${CYAN}1) Установка второй ноды (rl-swarm1)${NC}"
    echo -e "${CYAN}2) Обновление второй ноды${NC}"
    echo -e "${CYAN}3) Просмотр логов второй ноды${NC}"
    echo -e "${CYAN}4) Рестарт второй ноды${NC}"
    echo -e "${CYAN}5) Удаление второй ноды${NC}"
    echo -e "${CYAN}6) Копирование auth данных из первой ноды${NC}"

    echo -e "${YELLOW}Введите номер:${NC} "
    read choice

    case $choice in
        1)
            echo -e "${BLUE}Установка ВТОРОЙ ноды Gensyn (rl-swarm1)...${NC}"
            echo -e "${YELLOW}ВНИМАНИЕ: Убедитесь, что первая нода работает в отдельной screen сессии!${NC}"

            # Проверка существования первой ноды
            if [ ! -d "$HOME/rl-swarm" ]; then
                echo -e "${RED}ОШИБКА: Первая нода (rl-swarm) не найдена! Установите сначала первую ноду.${NC}"
                exit 1
            fi

            # Клонируем репозиторий для второй ноды
            if [ -d "$HOME/rl-swarm1" ]; then
                echo -e "${YELLOW}Директория rl-swarm1 уже существует. Удаляем...${NC}"
                rm -rf $HOME/rl-swarm1
            fi

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

            # Копирование auth данных из первой ноды
            echo -e "${BLUE}Копирование auth данных из первой ноды...${NC}"
            if [ -d "$HOME/rl-swarm/modal-login" ]; then
                mkdir -p modal-login/temp-data/
                cp -r $HOME/rl-swarm/modal-login/temp-data/* modal-login/temp-data/ 2>/dev/null || echo -e "${YELLOW}Некоторые auth файлы не найдены, продолжаем...${NC}"
            fi

            if [ -f "$HOME/rl-swarm/swarm.pem" ]; then
                echo -e "${YELLOW}ВНИМАНИЕ: Копируем swarm.pem, но вторая нода создаст новый peer ID!${NC}"
                cp $HOME/rl-swarm/swarm.pem . 2>/dev/null || echo -e "${YELLOW}swarm.pem не найден в первой ноде${NC}"
            fi

            docker compose pull
            docker compose up --build -d

            # Заключительное сообщение
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${YELLOW}ВТОРАЯ НОДА УСТАНОВЛЕНА!${NC}"
            echo -e "${YELLOW}Команда для проверки логов ВТОРОЙ ноды:${NC}"
            echo "cd rl-swarm1 && docker compose logs -f swarm_node_2"
            echo -e "${CYAN}API второй ноды доступен на: http://localhost:8178${NC}"
            echo -e "${CYAN}P2P порт второй ноды: 38332${NC}"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 2
            docker compose logs -f swarm_node_2
            ;;

        2)
            echo -e "${BLUE}Обновление ВТОРОЙ ноды Gensyn...${NC}"
            VER=rl-swarm:v0.0.2
            cd rl-swarm1
            sed -i "s#\(image: europe-docker.pkg.dev/gensyn-public-b7d9/public/\).*#\1$VER#g" docker-compose.yaml
            docker compose pull
            docker compose up -d --force-recreate
            # Заключительное сообщение
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${YELLOW}Команда для проверки логов ВТОРОЙ ноды:${NC}"
            echo "cd rl-swarm1 && docker compose logs -f swarm_node_2"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 2
            docker compose logs -f swarm_node_2
            ;;

        3)
            echo -e "${BLUE}Просмотр логов ВТОРОЙ ноды...${NC}"
            cd rl-swarm1 && docker compose logs -f swarm_node_2
            ;;

        4)
            echo -e "${BLUE}Рестарт ВТОРОЙ ноды...${NC}"
            cd rl-swarm1 && docker compose restart
            docker compose logs -f swarm_node_2
            ;;
            
        5)
            echo -e "${BLUE}Удаление ВТОРОЙ ноды Gensyn...${NC}"

            # Остановка и удаление контейнера
            cd rl-swarm1 && docker compose down -v

            # Удаление папки
            if [ -d "$HOME/rl-swarm1" ]; then
                rm -rf $HOME/rl-swarm1
                echo -e "${GREEN}Директория ВТОРОЙ ноды удалена.${NC}"
            else
                echo -e "${RED}Директория ВТОРОЙ ноды не найдена.${NC}"
            fi

            echo -e "${GREEN}ВТОРАЯ нода Gensyn успешно удалена!${NC}"
            echo -e "${CYAN}Первая нода (rl-swarm) остается работать!${NC}"

            # Завершающий вывод
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            sleep 1
            ;;

        6)
            echo -e "${BLUE}Копирование auth данных из первой ноды в стиле ваших макросов...${NC}"
            
            # Копирование в стиле пользователя с его путями
            echo -e "${YELLOW}Вариант 1: Копирование из первой ноды (rl-swarm):${NC}"
            echo "mkdir -p ~/rl-swarm1/modal-login/temp-data/ && cp ~/rl-swarm/modal-login/temp-data/userData.json ~/rl-swarm1/modal-login/temp-data/ && cp ~/rl-swarm/modal-login/temp-data/userApiKey.json ~/rl-swarm1/modal-login/temp-data/ && cp ~/rl-swarm/swarm.pem ~/rl-swarm1/"
            
            echo -e "${YELLOW}Вариант 2: Копирование из исходного источника (ваш путь):${NC}"
            echo "mkdir -p ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userData.json ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userApiKey.json ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/swarm.pem ~/rl-swarm1/"
            
            echo -e "${CYAN}Выберите и выполните нужную команду вручную${NC}"
            ;;

        *)
            echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 6!${NC}"
            ;;
    esac
