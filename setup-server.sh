#!/bin/bash

# ==========================================
# AUTONOMICZNY SKRYPT KONFIGURACJI SERWERA
# ==========================================
# Skrypt przygotowuje Nginx pod nową subdomenę, 
# nie ruszając istniejących stron.

# Zmień tę zmienną na swoją realną subdomenę:
SUBDOMAIN="portfolio.fachowo.net.pl" 
PROJECT_PATH="/root/www/portfolio"

echo -e "\e[36m🚀 Startujemy z konfiguracją Ubuntu pod Portfolio...\e[0m"

# 1. Uprawnienia do folderu /root (BEZ TEGO BĘDZIE BŁĄD 403)
echo -e "\e[33m[1/4] Ustawianie uprawnień dostępu do /root...\e[0m"
chmod +x /root
chmod +x /root/www
chown -R www-data:www-data $PROJECT_PATH
chmod -R 755 $PROJECT_PATH

# 2. Plik konfiguracyjny Nginx
echo -e "\e[33m[2/4] Tworzenie konfiguracji Nginx dla $SUBDOMAIN...\e[0m"
cat <<EOF | sudo tee /etc/nginx/sites-available/portfolio
server {
    listen 80;
    server_name $SUBDOMAIN;

    root $PROJECT_PATH;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /index.html;
}
EOF

# 3. Aktywacja nowej strony
echo -e "\e[33m[3/4] Aktywowanie strony w Nginx...\e[0m"
if [ ! -L /etc/nginx/sites-enabled/portfolio ]; then
    sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
fi

# 4. Weryfikacja i SSL (Certbot)
echo -e "\e[33m[4/5] Sprawdzanie konfiguracji i generowanie certyfikatu SSL...\e[0m"
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx

    # Próba instalacji SSL
    if command -v certbot > /dev/null; then
        echo -e "\e[33mGenerowanie certyfikatu SSL dla $SUBDOMAIN...\e[0m"
        sudo certbot --nginx -d $SUBDOMAIN --non-interactive --agree-tos --register-unsafely-without-email
    else
        echo -e "\e[31mCertbot nie jest zainstalowany. Zainstaluj go: sudo apt install certbot python3-certbot-nginx\e[0m"
    fi

    echo -e "\n\e[32m==========================================\e[0m"
    echo -e "✅ GOTOWE! Twoje portfolio powinno działać pod HTTPS."
    echo -e "Adres: https://$SUBDOMAIN"
    echo -e "==========================================\e[0m"
else
    echo -e "\e[31m❌ Błąd konfiguracji Nginx.\e[0m"
fi
fi
