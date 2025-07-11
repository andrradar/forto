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
    echo -e "${YELLOW}Выберите действие для ВТОРОЙ НОДЫ (Python venv):${NC}"
    echo -e "${CYAN}1) Установка второй ноды (rl-swarm1)${NC}"
    echo -e "${CYAN}2) Просмотр логов второй ноды${NC}"
    echo -e "${CYAN}3) Остановить вторую ноду${NC}"
    echo -e "${CYAN}4) Удаление второй ноды${NC}"
    echo -e "${CYAN}5) Копирование auth данных${NC}"
    echo -e "${CYAN}6) Команды для макросов${NC}"

    echo -e "${YELLOW}Введите номер:${NC} "
    read choice

    case $choice in
        1)
            echo -e "${BLUE}Установка ВТОРОЙ ноды Gensyn (rl-swarm1) через Python venv...${NC}"
            
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

            echo -e "${BLUE}Клонирование репозитория...${NC}"
            git clone https://github.com/gensyn-ai/rl-swarm/ rl-swarm1
            cd rl-swarm1

            echo -e "${BLUE}Настройка Python окружения...${NC}"
            python3 -m venv .venv
            source .venv/bin/activate
            
            echo -e "${BLUE}Обновление репозитория...${NC}"
            git fetch origin
            git reset --hard origin/main

            # Заключительное сообщение
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}ВТОРАЯ НОДА УСТАНОВЛЕНА!${NC}"
            echo -e "${YELLOW}Установка завершена. Репозиторий готов к настройке.${NC}"
            echo -e "${CYAN}Используйте другие опции меню для дальнейшей настройки.${NC}"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            ;;

        2)
            echo -e "${BLUE}Для просмотра логов второй ноды используйте:${NC}"
            echo -e "${CYAN}screen -r gensyn1${NC}"
            echo -e "${YELLOW}Или если нода запущена в background:${NC}"
            echo -e "${CYAN}tail -f /tmp/rlswarm_stdout.log${NC}"
            ;;

        3)
            echo -e "${BLUE}Остановка второй ноды...${NC}"
            echo -e "${YELLOW}Выберите способ:${NC}"
            echo -e "${CYAN}1. Остановить screen сессию: screen -XS gensyn1 quit${NC}"
            echo -e "${CYAN}2. Найти и убить процессы из rl-swarm1:${NC}"
            echo "pkill -f rl-swarm1"
            ;;
            
        4)
            echo -e "${BLUE}Удаление ВТОРОЙ ноды Gensyn...${NC}"

            # Остановка процессов
            echo -e "${YELLOW}Остановка процессов...${NC}"
            pkill -f rl-swarm1 2>/dev/null || true
            screen -XS gensyn1 quit 2>/dev/null || true

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
            ;;

        5)
            echo -e "${BLUE}Команды для копирования auth данных:${NC}"
            echo ""
            echo -e "${YELLOW}Вариант 1 - Из оригинального источника:${NC}"
            echo "mkdir -p ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userData.json ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userApiKey.json ~/rl-swarm1/modal-login/temp-data/"
            echo ""
            echo -e "${YELLOW}Вариант 2 - Из первой ноды:${NC}"
            echo "mkdir -p ~/rl-swarm1/modal-login/temp-data/ && cp ~/rl-swarm/modal-login/temp-data/userData.json ~/rl-swarm1/modal-login/temp-data/ && cp ~/rl-swarm/modal-login/temp-data/userApiKey.json ~/rl-swarm1/modal-login/temp-data/"
            echo ""
            echo -e "${YELLOW}Копирование swarm.pem (если нужен тот же peer ID):${NC}"
            echo "cp ~/rl-swarm/swarm.pem ~/rl-swarm1/"
            echo ""
            echo -e "${GREEN}Скопируйте и выполните нужную команду${NC}"
            ;;

        6)
            echo -e "${BLUE}Команды для макросов второй ноды:${NC}"
            echo ""
            echo -e "${YELLOW}0) Комментирование modal credentials:${NC}"
            echo "cd ~/rl-swarm1 && sed -i 's/^[[:space:]]*rm -r \\\$ROOT_DIR\\/modal-login\\/temp-data\\/\\*\\.json/# &/' run_rl_swarm.sh && echo \"Line processed:\" && grep -n -A1 -B1 \"modal-login.*temp-data\" run_rl_swarm.sh && echo \"Done!\""
            echo ""
            echo -e "${YELLOW}1) Скачивание auto_restart.sh:${NC}"
            echo "cd ~/rl-swarm1 && wget https://raw.githubusercontent.com/andrradar/forto/refs/heads/main/auto_restart.sh && chmod +x auto_restart.sh && echo \"auto_restart.sh ready in \$(pwd)\""
            echo ""
            echo -e "${YELLOW}2) Копирование auth данных:${NC}"
            echo "mkdir -p ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userData.json ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/userApiKey.json ~/rl-swarm1/modal-login/temp-data/ && cp /root/node_tools/projects/gensyn/\$(hostname)/gensyn-temp/swarm.pem ~/rl-swarm1/"
            echo ""
            echo -e "${YELLOW}3) Настройка окружения:${NC}"
            echo "cd rl-swarm1 && python3 -m venv .venv && source .venv/bin/activate && git fetch origin && git reset --hard origin/main"
            echo ""
            echo -e "${GREEN}Для screen макроса используйте эти команды по порядку${NC}"
            ;;

        *)
            echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 6!${NC}"
            ;;
    esac
