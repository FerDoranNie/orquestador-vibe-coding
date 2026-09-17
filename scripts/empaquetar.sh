#!/usr/bin/env bash
# Empaquetador de la skill orquestador-vibe-coding en formato .zip
# Cumple estrictamente con los requisitos de subida de Gemini Spark / Claude:
# - Solo extensiones soportadas (.md, .html, .sh, etc.)
# - Excluye .ps1 y los propios scripts empaquetadores del paquete final.
#
# Uso:
#   bash scripts/empaquetar.sh [nombre-archivo.zip]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_ZIP="${1:-$ROOT_DIR/orquestador-vibe-coding.zip}"

cd "$ROOT_DIR"

echo "======================================================"
echo "📦 Empaquetando: orquestador-vibe-coding"
echo "📂 Directorio raíz: $ROOT_DIR"
echo "🎯 Archivo destino: $OUTPUT_ZIP"
echo "======================================================"

# Eliminar zip anterior si existe
if [ -f "$OUTPUT_ZIP" ]; then
  rm -f "$OUTPUT_ZIP"
fi

# Lista de extensiones permitidas por Gemini Spark:
# .txt, .md, .rst, .rtf, .tex, .log, .py, .sh, .json, .yaml, .csv, .toml, .xml, .env, .sql, .html, .css, .svg, Makefile, Dockerfile

python3 -c "
import zipfile, os

output = '$OUTPUT_ZIP'
allowed_extensions = {
    '.md', '.txt', '.rst', '.rtf', '.tex', '.log',
    '.py', '.sh',
    '.json', '.yaml', '.yml', '.csv', '.toml', '.xml', '.env', '.sql',
    '.html', '.css', '.svg'
}
allowed_filenames = {'Makefile', 'Dockerfile', 'SKILL.md', 'README.md'}

# Archivos o carpetas a incluir
targets = ['SKILL.md', 'README.md', 'assets', 'references', 'scripts/inventario.sh']
ignore_dirs = {'.git', '__pycache__', 'tmp', 'node_modules', '.venv', 'venv'}

with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for target in targets:
        if not os.path.exists(target):
            continue
        if os.path.isfile(target):
            zipf.write(target, target)
        elif os.path.isdir(target):
            for root, dirs, files in os.walk(target):
                dirs[:] = [d for d in dirs if d not in ignore_dirs and not d.startswith('.')]
                for file in files:
                    ext = os.path.splitext(file)[1].lower()
                    if ext in allowed_extensions or file in allowed_filenames:
                        full_path = os.path.join(root, file)
                        rel_path = os.path.relpath(full_path, '.')
                        zipf.write(full_path, rel_path)
"

if [ -f "$OUTPUT_ZIP" ]; then
  SIZE=$(du -h "$OUTPUT_ZIP" | cut -f1)
  echo "✅ Empaquetado exitoso (100% compatible con Gemini Spark):"
  echo "   Archivo: $OUTPUT_ZIP"
  echo "   Tamaño:  $SIZE"
  echo ""
  echo "📋 Archivos incluidos en el ZIP:"
  unzip -l "$OUTPUT_ZIP" 2>/dev/null || python3 -c "import zipfile; [print('  -', f) for f in zipfile.ZipFile('$OUTPUT_ZIP').namelist()]"
  echo ""
  echo "🚀 Listo para subir a Gemini Spark sin rechazos de tipo de archivo."
else
  echo "❌ Error al crear el archivo ZIP."
  exit 1
fi
