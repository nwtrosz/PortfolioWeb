<#
.SYNOPSIS
Zoptymalizowany skrypt wdrożeniowy dla serwerów UBUNTU.
#>

# ==========================================
# KONFIGURACJA SERWERA UBUNTU
# ==========================================
$ServerIP = "ADRES_IP_SERWERA"    # <-- WPISZ TU IP SWOJEGO VPS
$SSHUser  = "ubuntu"               # <-- Domyślny user na Ubuntu (zmień na 'root' jeśli używasz roota)
$RemoteDir = "/var/www/html"      # <-- Standardowy folder Nginx/Apache na Ubuntu
$UseSudo   = $true                 # <-- Ustaw na $false jeśli logujesz się jako root
# ==========================================

$LocalDir = $PSScriptRoot
$SudoCmd = if ($UseSudo) { "sudo " } else { "" }

Write-Host "🚀 Rozpoczynam wdrażanie na Ubuntu ($ServerIP)..." -ForegroundColor Cyan

# 1. Przygotowanie folderu na serwerze (jeśli nie istnieje)
Write-Host "1. Przygotowanie struktury folderów na Ubuntu..." -ForegroundColor Yellow
$prepareCmd = "ssh ${SSHUser}@${ServerIP} ""${SudoCmd}mkdir -p $RemoteDir && ${SudoCmd}chown -R ${SSHUser} $RemoteDir"""
Invoke-Expression $prepareCmd

# 2. Kopiowanie plików przez SCP
Write-Host "2. Przesyłanie plików portfolio..." -ForegroundColor Yellow
$scpCommand = "scp -r ""$LocalDir\*"" ${SSHUser}@${ServerIP}:$RemoteDir"
Invoke-Expression $scpCommand

if ($LASTEXITCODE -ne 0) {
    Write-Error "Błąd podczas przesyłania danych przez SCP."
    exit
}

# 3. Finalizacja uprawnień dla serwera WWW (www-data)
Write-Host "3. Optymalizacja uprawnień dla Nginx/Apache (www-data)..." -ForegroundColor Yellow
$finalCmd = "ssh ${SSHUser}@${ServerIP} ""${SudoCmd}chown -R www-data:www-data $RemoteDir && ${SudoCmd}chmod -R 755 $RemoteDir"""
Invoke-Expression $finalCmd

# 4. Bonus: Restart Nginx (opcjonalnie, aby odświeżyć cache)
Write-Host "4. Sprawdzanie statusu serwera..." -ForegroundColor Yellow
$statusCmd = "ssh ${SSHUser}@${ServerIP} ""${SudoCmd}systemctl is-active nginx || ${SudoCmd}systemctl is-active apache2"""
Invoke-Expression $statusCmd

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "✅ PORTFOLIO WDROŻONE NA UBUNTU!" -ForegroundColor Green
Write-Host "Adres strony: http://$ServerIP" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Green
