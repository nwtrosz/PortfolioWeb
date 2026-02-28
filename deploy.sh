#!/bin/bash

# ==========================================
# KONFIGURACJA SERWERA UBUNTU
# ==========================================
SERVER_IP="ADRES_IP_SERWERA"    # <-- WPISZ TU IP SWOJEGO VPS
SSH_USER="ubuntu"               # <-- Domyślny user na Ubuntu
REMOTE_DIR="/root/www/portfolio"      # <-- Folder docelowy w katalogu root
USE_SUDO=true                   # <-- Czy używać sudo na serwerze?
# ==========================================

LOCAL_DIR="."
SUDO_CMD=""
if [ "$USE_SUDO" = true ]; then
    SUDO_CMD="sudo "
fi

echo -e "\e[36m🚀 Rozpoczynam wdrażanie na Ubuntu ($SERVER_IP) przez Bash...\e[0m"

# 1. Przygotowanie folderu na serwerze
echo -e "\e[33m1. Przygotowanie struktury folderów...\e[0m"
ssh ${SSH_USER}@${SERVER_IP} "${SUDO_CMD}mkdir -p $REMOTE_DIR && ${SUDO_CMD}chown -R ${SSH_USER} $REMOTE_DIR"

# 2. Kopiowanie plików przez SCP
echo -e "\e[33m2. Przesyłanie plików portfolio...\e[0m"
# Kopiujemy zawartość obecnego folderu, wykluczając pliki gita i skrypty wdrożeniowe
scp -r $LOCAL_DIR/* ${SSH_USER}@${SERVER_IP}:$REMOTE_DIR

if [ $? -ne 0 ]; then
    echo -e "\e[31m❌ Błąd podczas przesyłania danych przez SCP.\e[0m"
    exit 1
fi

# 3. Finalizacja uprawnień dla www-data
echo -e "\e[33m3. Optymalizacja uprawnień dla www-data (Nginx/Apache)...\e[0m"
ssh ${SSH_USER}@${SERVER_IP} "${SUDO_CMD}chown -R www-data:www-data $REMOTE_DIR && ${SUDO_CMD}chmod -R 755 $RemoteDir"

# 4. Sprawdzenie statusu serwera
echo -e "\e[33m4. Weryfikacja serwera WWW...\e[0m"
ssh ${SSH_USER}@${SERVER_IP} "${SUDO_CMD}systemctl is-active nginx || ${SUDO_CMD}systemctl is-active apache2"

echo -e "
\e[32m==========================================\e[0m"
echo -e "\e[32m✅ PORTFOLIO WDROŻONE POMYŚLNIE!\e[0m"
echo -e "Adres strony: http://$SERVER_IP"
echo -e "\e[32m==========================================\e[0m"
