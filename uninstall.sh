#!/bin/bash

# Skrypt deinstalacyjny dla wtyczki ZED FTP

set -e

# Definicje kolorów
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}=== Deinstalator wtyczki ZED FTP ===${RESET}"
echo

# Określenie systemu operacyjnego
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    EXTENSION_DIR="$HOME/Library/Application Support/Zed/extensions/zed_ftp"
elif [ "$(uname)" == "Linux" ]; then
    # Linux
    EXTENSION_DIR="$HOME/.config/zed/extensions/zed_ftp"
else
    # Windows lub inny system
    echo -e "${RED}Nieobsługiwany system operacyjny: $(uname)${RESET}"
    echo -e "${YELLOW}Dla Windows, usuń ręcznie pliki z odpowiedniego katalogu ZED.${RESET}"
    exit 1
fi

# Sprawdzenie, czy katalog istnieje
if [ ! -d "$EXTENSION_DIR" ]; then
    echo -e "${YELLOW}Wtyczka nie jest zainstalowana w lokalizacji:${RESET}"
    echo -e "${YELLOW}$EXTENSION_DIR${RESET}"
    echo -e "${YELLOW}Nie ma nic do usunięcia.${RESET}"
    exit 0
fi

# Potwierdzenie od użytkownika
echo -e "${RED}Uwaga: Ta operacja usunie wtyczkę ZED FTP z:${RESET}"
echo -e "${YELLOW}$EXTENSION_DIR${RESET}"
read -p "Czy na pewno chcesz kontynuować? (t/N): " confirm

if [[ "$confirm" != "t" && "$confirm" != "T" ]]; then
    echo -e "${BLUE}Deinstalacja anulowana.${RESET}"
    exit 0
fi

# Usunięcie katalogu
echo -e "${BLUE}Usuwanie wtyczki...${RESET}"
rm -rf "$EXTENSION_DIR"

# Sprawdzenie, czy katalog został usunięty
if [ ! -d "$EXTENSION_DIR" ]; then
    echo -e "${GREEN}Wtyczka ZED FTP została pomyślnie usunięta.${RESET}"
else
    echo -e "${RED}Wystąpił błąd podczas usuwania wtyczki.${RESET}"
    exit 1
fi

echo
echo -e "${BLUE}Wskazówka: Aby ponownie zainstalować wtyczkę, użyj ./install.sh${RESET}"
echo
echo -e "${GREEN}Gotowe!${RESET}"