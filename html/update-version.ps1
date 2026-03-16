# tar1090 cache-bust version updater
# Her deployment'tan önce çalıştır: .\update-version.ps1

$ErrorActionPreference = "Stop"

# Mevcut timestamp'i version olarak kullan (YYYYMMDDHHmmss formatında)
$indexFile = Join-Path $PSScriptRoot "index.html"
$version = Get-Date -Format "yyyyMMddHHmmss"

Write-Host "Yeni version (timestamp): $version" -ForegroundColor Green

# index.html'deki tüm ?v= parametrelerini güncelle
$htmlContent = Get-Content $indexFile -Raw -Encoding UTF8

# Regex ile tüm ?v=XXXXXX pattern'lerini bul ve yeni version ile değiştir
$updatedContent = $htmlContent -replace '\?v=[^"''&\s]+', "?v=$version"

# Dosyayı kaydet (UTF-8 BOM olmadan)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($indexFile, $updatedContent, $utf8NoBom)

Write-Host "index.html güncellendi - tüm dosyalar ?v=$version ile etiketlendi" -ForegroundColor Cyan
Write-Host "Deployment'a hazır!" -ForegroundColor Green
