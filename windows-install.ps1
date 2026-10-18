<#
.SYNOPSIS
    Empaqueta los archivos compilados de PrusaSlicer 3.0.0 en una version portable para Windows y genera un archivo ZIP.
.DESCRIPTION
    Copia el ejecutable principal, todas las DLLs requeridas y la carpeta de recursos
    en una carpeta independiente, genera un lanzador portable con perfiles aislados
    y comprime el resultado final en un archivo .zip listo para distribuir.
#>

param (
    [string]$OutputDir = "$PSScriptRoot\build\PrusaSlicer",
    [string]$ZipPath = "",
    [switch]$SkipZip
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$BuildRelease = Join-Path $RepoRoot "build\src\slic3r-app-launcher\Release"
$SourceResources = Join-Path $RepoRoot "resources"
$TargetDir = [System.IO.Path]::GetFullPath($OutputDir)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " PrusaSlicer 3.0.0 - Empaquetador Windows" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Comprobar que los binarios compilados existan
$LauncherExe = Join-Path $BuildRelease "slic3r-app-launcher.exe"
if (-not (Test-Path $LauncherExe)) {
    Write-Error "No se encontro el ejecutable compilado en: $LauncherExe`nAsegurate de haber compilado el proyecto en modo Release antes de ejecutar este script."
    exit 1
}

# 2. Comprobar que resources exista
if (-not (Test-Path $SourceResources)) {
    Write-Error "No se encontro la carpeta de recursos en: $SourceResources"
    exit 1
}

Write-Host "Directorio destino : $TargetDir" -ForegroundColor Yellow

# 3. Crear directorio destino
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

# 4. Copiar ejecutable
Write-Host "[1/5] Copiando ejecutables..." -ForegroundColor Gray
Copy-Item -Path $LauncherExe -Destination (Join-Path $TargetDir "prusa-slicer.exe") -Force
Copy-Item -Path $LauncherExe -Destination (Join-Path $TargetDir "slic3r-app-launcher.exe") -Force

# 5. Copiar DLLs
Write-Host "[2/5] Copiando DLLs requeridas..." -ForegroundColor Gray
$dlls = Get-ChildItem -Path $BuildRelease -Filter "*.dll"
foreach ($dll in $dlls) {
    Copy-Item -Path $dll.FullName -Destination $TargetDir -Force
    Write-Host "  -> $($dll.Name)" -ForegroundColor DarkGray
}

# 6. Copiar carpeta resources
Write-Host "[3/5] Copiando carpeta de recursos (resources)..." -ForegroundColor Gray
$TargetResources = Join-Path $TargetDir "resources"
if (Test-Path $TargetResources) {
    Remove-Item -Recurse -Force $TargetResources
}
Copy-Item -Path $SourceResources -Destination $TargetResources -Recurse -Force

# 7. Crear script lanzador portable
Write-Host "[4/5] Creando lanzador portable..." -ForegroundColor Gray
$LauncherBatContent = @"
@echo off
start "" "%~dp0prusa-slicer.exe" --datadir "%~dp0data" %*
"@
Set-Content -Path (Join-Path $TargetDir "PrusaSlicer-Portable.bat") -Value $LauncherBatContent -Encoding ASCII

# 8. Comprimir en ZIP
if (-not $SkipZip) {
    if (-not $ZipPath) {
        $ZipPath = "$TargetDir.zip"
    } else {
        $ZipPath = [System.IO.Path]::GetFullPath($ZipPath)
    }

    Write-Host "[5/5] Comprimiendo en archivo ZIP..." -ForegroundColor Gray
    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    try {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($TargetDir, $ZipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    }
    catch {
        Write-Warning "Metodo .NET fallo, intentando con Compress-Archive..."
        Compress-Archive -Path "$TargetDir\*" -DestinationPath $ZipPath -Force
    }

    $zipItem = Get-Item $ZipPath
    $zipSizeMB = [math]::Round($zipItem.Length / 1MB, 2)
    Write-Host "  -> ZIP generado: $ZipPath ($zipSizeMB MB)" -ForegroundColor DarkGray
}

Write-Host "==================================================" -ForegroundColor Green
Write-Host " PrusaSlicer empaquetado exitosamente!" -ForegroundColor Green
Write-Host " Carpeta : $TargetDir" -ForegroundColor Green
if (-not $SkipZip) {
    Write-Host " Archivo : $ZipPath" -ForegroundColor Green
}
Write-Host " Para iniciar:" -ForegroundColor Yellow
Write-Host "   - Ejecuta 'PrusaSlicer-Portable.bat' para modo 100% portable (perfiles en carpeta data)." -ForegroundColor White
Write-Host "   - O 'prusa-slicer.exe' directamente para usar %APPDATA%." -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Green
