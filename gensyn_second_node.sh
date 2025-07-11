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
    echo -e "${CYAN}2) Просмотр статуса${NC}"
    echo -e "${CYAN}3) Остановить вторую ноду${NC}"
    echo -e "${CYAN}4) Удаление второй ноды${NC}"

    echo -e "${YELLOW}Введите номер:${NC} "
    read choice

    case $choice in
        1)
            echo -e "${BLUE}Установка второй ноды Gensyn через Python venv...${NC}"

            # Проверка существования первой ноды
            if [ ! -d "$HOME/rl-swarm" ]; then
                echo -e "${RED}ОШИБКА: Первая нода (rl-swarm) не найдена! Установите сначала первую ноду.${NC}"
                exit 1
            fi

            # Удаляем если существует
            if [ -d "$HOME/rl-swarm1" ]; then
                echo -e "${YELLOW}Директория rl-swarm1 уже существует. Удаляем...${NC}"
                rm -rf $HOME/rl-swarm1
            fi

            echo -e "${BLUE}Клонирование репозитория для второй ноды...${NC}"
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
            echo -e "${YELLOW}Готова к настройке auth данных и запуску.${NC}"
            echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
            echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
            echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"
            ;;

        2)
            echo -e "${BLUE}Статус второй ноды:${NC}"
            if [ -d "$HOME/rl-swarm1" ]; then
                echo -e "${GREEN}✅ Директория rl-swarm1 существует${NC}"
                if screen -list | grep -q "gensyn1"; then
                    echo -e "${GREEN}✅ Screen сессия gensyn1 активна${NC}"
                else
                    echo -e "${YELLOW}⚠ Screen сессия gensyn1 не найдена${NC}"
                fi
            else
                echo -e "${RED}❌ Директория rl-swarm1 не найдена${NC}"
            fi
            ;;

        3)
            echo -e "${BLUE}Остановка второй ноды...${NC}"
            screen -XS gensyn1 quit 2>/dev/null || echo -e "${YELLOW}Screen сессия gensyn1 не найдена${NC}"
            pkill -f "rl-swarm1" 2>/dev/null || echo -e "${YELLOW}Процессы rl-swarm1 не найдены${NC}"
            echo -e "${GREEN}Вторая нода остановлена${NC}"
            ;;
            
        4)
            echo -e "${BLUE}Удаление второй ноды Gensyn...${NC}"

            # Остановка процессов
            echo -e "${YELLOW}Остановка процессов...${NC}"
            screen -XS gensyn1 quit 2>/dev/null || true
            pkill -f "rl-swarm1" 2>/dev/null || true

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
            echo -e "${RED}Неверный выбор. Пожалуйста, введите номер от 1 до 4!${NC}"
            ;;
    esac
