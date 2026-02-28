# Instrukcja Wdrożenia Portfolio na VPS

Twoje portfolio jest statyczne (HTML/CSS), co oznacza, że jest niezwykle wydajne i bezpieczne. Możesz je hostować na dowolnym serwerze WWW.

## Opcja A: Najprostsza (Nginx / Apache)
1. Połącz się ze swoim VPS przez SFTP (np. używając FileZilla lub WinSCP).
2. Skopiuj całą zawartość folderu `Portfolio WEB` do katalogu głównego serwera WWW (zazwyczaj `/var/www/html/`).
3. Upewnij się, że uprawnienia plików są poprawne:
   ```bash
   sudo chown -R www-data:www-data /var/www/html/
   sudo chmod -R 755 /var/www/html/
   ```

## Opcja B: Automatyczna (jeśli masz zainstalowane Docker)
Jeśli chcesz użyć Dockera, stwórz plik `Dockerfile` w folderze głównym:
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```
Następnie zbuduj i uruchom:
```bash
docker build -t moje-portfolio .
docker run -d -p 80:80 moje-portfolio
```

## Opcja C: Darmowy hosting (GitHub Pages / Netlify)
Ponieważ nie używasz backendu, możesz to wrzucić za darmo na:
1. **GitHub Pages:** Wrzuć folder do repozytorium i włącz Pages w ustawieniach.
2. **Netlify:** Przeciągnij folder `Portfolio WEB` bezpośrednio do panelu Netlify.

### Optymalizacja pod VPS:
- Skonfiguruj **SSL (Let's Encrypt)** używając `certbot`, aby strona działała przez HTTPS.
- Włącz kompresję Gzip/Brotli w konfiguracji Nginx, aby strona ładowała się jeszcze szybciej.
