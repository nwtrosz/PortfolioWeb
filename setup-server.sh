#!/bin/bash

# ==========================================
# AUTONOMICZNY SKRYPT KONFIGURACJI SERWERA
# ==========================================
# Skrypt przygotowuje Nginx pod nową subdomenę.

SUBDOMAIN="portfolio.fachowo.net.pl" 
PROJECT_PATH="/root/www/portfolio"

echo -e "\e[36m🚀 Konfiguracja serwera dla Portfolio...\e[0m"

# 1. Uprawnienia dostępu (tylko dla folderów nadrzędnych)
echo -e "\e[33m[1/3] Nadawanie uprawnień przejścia dla Nginx...\e[0m"
# To musi zostać, aby Nginx mógł "wejść" do /root, ale nie dotyka plików w środku projektu
chmod +x /root
chmod +x /root/www

# 2. Plik konfiguracyjny Nginx
echo -e "\e[33m[2/3] Tworzenie konfiguracji Nginx dla $SUBDOMAIN...\e[0m"
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

# 3. Aktywacja strony w Nginx
if [ ! -L /etc/nginx/sites-enabled/portfolio ]; then
    echo -e "\e[33m[3/3] Aktywowanie strony...\e[0m"
    sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
fi

# 4. SSL (Certbot)
echo -e "\e[33mSprawdzanie konfiguracji i SSL...\e[0m"
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
    if command -v certbot > /dev/null; then
        sudo certbot --nginx -d $SUBDOMAIN --non-interactive --agree-tos --register-unsafely-without-email
    fi
    echo -e "\n\e[32m✅ GOTOWE! Strona działa pod adresem: https://$SUBDOMAIN\e[0m"
else
    echo -e "\e[31m❌ Błąd konfiguracji Nginx.\e[0m"
fi
