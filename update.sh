#!/bin/bash

# Skrypt aktualizacyjny dla wtyczki ZED FTP

set -e

# Definicje kolorów
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}=== Aktualizator wtyczki ZED FTP ===${RESET}"
echo

# Sprawdzenie, czy wtyczka została zbudowana
if [ ! -f "target/release/libzed_ftp.dylib" ] && [ ! -f "target/release/libzed_ftp.so" ]; then
    echo -e "${YELLOW}Budowanie wtyczki...${RESET}"
    cargo build --release
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Błąd podczas budowania wtyczki!${RESET}"
        exit 1
    fi
fi

# Określenie systemu operacyjnego
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    EXTENSION_DIR="$HOME/Library/Application Support/Zed/extensions/zed_ftp"
    LIB_FILE="target/release/libzed_ftp.dylib"
elif [ "$(uname)" == "Linux" ]; then
    # Linux
    EXTENSION_DIR="$HOME/.config/zed/extensions/zed_ftp"
    LIB_FILE="target/release/libzed_ftp.so"
else
    # Windows lub inny system
    echo -e "${RED}Nieobsługiwany system operacyjny: $(uname)${RESET}"
    echo -e "${YELLOW}Dla Windows, skopiuj ręcznie pliki do odpowiedniego katalogu ZED.${RESET}"
    exit 1
fi

# Sprawdzenie, czy katalog istnieje
if [ ! -d "$EXTENSION_DIR" ]; then
    echo -e "${YELLOW}Wtyczka nie jest jeszcze zainstalowana. Uruchamianie instalacji...${RESET}"
    ./install.sh
    exit 0
fi

# Kopiowanie plików
echo -e "${BLUE}Aktualizowanie plików wtyczki...${RESET}"
cp $LIB_FILE "$EXTENSION_DIR/"
cp extension/extension.json "$EXTENSION_DIR/"
cp README.md "$EXTENSION_DIR/"

# Ustawianie uprawnień
echo -e "${BLUE}Ustawianie uprawnień...${RESET}"
chmod +x "$EXTENSION_DIR/$(basename $LIB_FILE)"

echo -e "${GREEN}Wtyczka ZED FTP została pomyślnie zaktualizowana w:${RESET}"
echo -e "${YELLOW}$EXTENSION_DIR${RESET}"
echo
echo -e "${BLUE}Aby zobaczyć zmiany:${RESET}"
echo -e "1. Zrestartuj ZED (jeśli jest uruchomiony)"
echo -e "2. Upewnij się, że wtyczka FTP jest aktywowana"
echo
echo -e "${GREEN}Gotowe!${RESET}"