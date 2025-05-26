#!/bin/bash

# Skrypt instalacyjny dla wtyczki ZED FTP

set -e

# Definicje kolorów
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}=== Instalator wtyczki ZED FTP ===${RESET}"
echo

# Sprawdzenie, czy wtyczka została zbudowana
if [ ! -f "target/release/libzed_ftp.dylib" ] && [ ! -f "target/release/libzed_ftp.so" ]; then
    echo -e "${RED}Błąd: Nie znaleziono skompilowanej wtyczki. Wykonaj najpierw 'cargo build --release'.${RESET}"
    exit 1
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

# Tworzenie katalogu, jeśli nie istnieje
echo -e "${BLUE}Tworzenie katalogu instalacyjnego...${RESET}"
mkdir -p "$EXTENSION_DIR"

# Kopiowanie plików
echo -e "${BLUE}Kopiowanie plików wtyczki...${RESET}"
cp $LIB_FILE "$EXTENSION_DIR/"
cp extension/extension.json "$EXTENSION_DIR/"
cp README.md "$EXTENSION_DIR/"

# Ustawianie uprawnień
echo -e "${BLUE}Ustawianie uprawnień...${RESET}"
chmod +x "$EXTENSION_DIR/$(basename $LIB_FILE)"

echo -e "${GREEN}Wtyczka ZED FTP została pomyślnie zainstalowana w:${RESET}"
echo -e "${YELLOW}$EXTENSION_DIR${RESET}"
echo
echo -e "${BLUE}Aby aktywować wtyczkę:${RESET}"
echo -e "1. Uruchom ZED"
echo -e "2. Otwórz panel rozszerzeń (View -> Extensions lub Command+Shift+E)"
echo -e "3. Włącz wtyczkę FTP"
echo
echo -e "${GREEN}Gotowe!${RESET}"