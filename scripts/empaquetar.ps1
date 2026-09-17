<#
.SYNOPSIS
    Empaqueta la skill orquestador-vibe-coding en un archivo .zip compatible con Gemini Spark y Claude.
.DESCRIPTION
    Filtra estrictamente solo las extensiones de texto y código permitidas por Gemini Spark:
    (.md, .html, .sh, .py, .json, .yaml, .txt, etc.) y excluye archivos no soportados como .ps1.
.PARAMETER OutputFile
    Ruta o nombre del archivo .zip resultante. Por defecto: .\orquestador-vibe-coding.zip
.EXAMPLE
    .\scripts\empaquetar.ps1
    .\scripts\empaquetar.ps1 -OutputFile "mi-orquestador.zip"
#>

[CmdletBinding()]
param (
    [string]$OutputFile = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir ".."))

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = Join-Path $RootDir "orquestador-vibe-coding.zip"
} else {
    if (-not [System.IO.Path]::IsPathRooted($OutputFile)) {
        $OutputFile = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputFile))
    }
}

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Empaquetando skill compatible con Gemini Spark / Claude" -ForegroundColor Cyan
Write-Host "Directorio raiz: $RootDir" -ForegroundColor Gray
Write-Host "Archivo destino: $OutputFile" -ForegroundColor Gray
Write-Host "======================================================" -ForegroundColor Cyan

# Extensiones permitidas oficialmente por Gemini Spark:
$AllowedExtensions = @(
    ".md", ".txt", ".rst", ".rtf", ".tex", ".log",
    ".py", ".sh",
    ".json", ".yaml", ".yml", ".csv", ".toml", ".xml", ".env", ".sql",
    ".html", ".css", ".svg"
)
$AllowedFilenames = @("Makefile", "Dockerfile", "SKILL.md", "README.md")

# Eliminar zip anterior si existe
if (Test-Path -LiteralPath $OutputFile) {
    Remove-Item -LiteralPath $OutputFile -Force
}

# Crear directorio temporal para staging limpio
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("spark_skill_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    # 1. Copiar SKILL.md y README.md en la raiz del staging
    Copy-Item -LiteralPath (Join-Path $RootDir "SKILL.md") -Destination (Join-Path $TempDir "SKILL.md") -Force
    if (Test-Path (Join-Path $RootDir "README.md")) {
        Copy-Item -LiteralPath (Join-Path $RootDir "README.md") -Destination (Join-Path $TempDir "README.md") -Force
    }

    # 2. Copiar carpetas filtrando unicamente extensiones permitidas
    $FoldersToProcess = @("assets", "references", "scripts")

    foreach ($folder in $FoldersToProcess) {
        $srcFolder = Join-Path $RootDir $folder
        if (Test-Path -LiteralPath $srcFolder) {
            $destFolder = Join-Path $TempDir $folder
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null

            $allFiles = Get-ChildItem -Path $srcFolder -Recurse -File
            foreach ($file in $allFiles) {
                $ext = $file.Extension.ToLower()
                $name = $file.Name

                # Verificar si esta permitido y NO es un script de empaquetar
                $isAllowed = ($AllowedExtensions -contains $ext) -or ($AllowedFilenames -contains $name)
                $isPackager = $name.StartsWith("empaquetar")

                if ($isAllowed -and (-not $isPackager)) {
                    # Calcular ruta relativa sin TrimStart ambiguo
                    $relPath = $file.FullName.Substring($srcFolder.Length).TrimStart([char[]]@('\', '/'))
                    $targetFilePath = Join-Path $destFolder $relPath
                    $targetDir = Split-Path -Parent $targetFilePath
                    if (-not (Test-Path $targetDir)) {
                        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                    }
                    Copy-Item -LiteralPath $file.FullName -Destination $targetFilePath -Force
                } else {
                    Write-Host "   [Omitido por no soportado en Spark]: $($file.Name)" -ForegroundColor DarkGray
                }
            }
        }
    }

    # Comprimir usando Compress-Archive
    Compress-Archive -Path (Join-Path $TempDir "*") -DestinationPath $OutputFile -CompressionLevel Optimal -Force

    if (Test-Path -LiteralPath $OutputFile) {
        $fileInfo = Get-Item -LiteralPath $OutputFile
        $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
        Write-Host ""
        Write-Host "Empaquetado exitoso (100% compatible con Gemini Spark):" -ForegroundColor Green
        Write-Host "   Archivo: $OutputFile" -ForegroundColor White
        Write-Host "   Tamano:  $sizeKB KB" -ForegroundColor White
        Write-Host ""
        Write-Host "Contenido validado en el ZIP:" -ForegroundColor Cyan
        
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($OutputFile)
        foreach ($entry in $zip.Entries) {
            Write-Host "   OK $($entry.FullName)" -ForegroundColor Green
        }
        $zip.Dispose()

        Write-Host ""
        Write-Host "Listo! Este ZIP cumple al 100% con los requisitos de Gemini Spark." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Error durante el empaquetado: $_"
}
finally {
    if (Test-Path -LiteralPath $TempDir) {
        Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
