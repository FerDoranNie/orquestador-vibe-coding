#!/usr/bin/env bash
# Inventario mecánico de un repo. Saca lo que un script puede saber.
# La lectura cualitativa (riesgo, volumen, reglas de dominio) la hace el agente.
#
# Uso: bash inventario.sh <ruta-al-repo>

set -uo pipefail
REPO="${1:-.}"
cd "$REPO" 2>/dev/null || { echo "No existe la ruta: $REPO"; exit 1; }

hr() { printf '\n== %s ==\n' "$1"; }

echo "Inventario de: $(pwd)"
echo "Fecha: $(date +%Y-%m-%d)"

hr "Tamaño y forma"
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Commits: $(git rev-list --count HEAD 2>/dev/null || echo n/a)"
  echo "Rama: $(git branch --show-current 2>/dev/null || echo n/a)"
  echo "Último commit: $(git log -1 --format=%cd --date=short 2>/dev/null || echo n/a)"
  echo "Contribuyentes: $(git shortlog -sn --all 2>/dev/null | wc -l | tr -d ' ')"
  FILES=$(git ls-files 2>/dev/null)
else
  echo "(sin repositorio git)"
  FILES=$(find . -type f -not -path '*/.*' -not -path '*/node_modules/*' \
    -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' 2>/dev/null)
fi
echo "Archivos versionados: $(echo "$FILES" | grep -c . || echo 0)"

hr "Lenguajes por número de archivos"
echo "$FILES" | grep -oE '\.[A-Za-z0-9]+$' | sort | uniq -c | sort -rn | head -18

hr "Líneas por extensión de código"
for ext in py ts tsx js jsx go rs java kt rb php cs swift sql sh; do
  n=$(echo "$FILES" | grep -E "\.${ext}$" | tr '\n' '\0' 2>/dev/null \
      | xargs -0 wc -l 2>/dev/null | tail -1 | awk '{print $1}')
  [ -n "${n:-}" ] && [ "${n:-0}" -gt 0 ] 2>/dev/null && printf '%-6s %s\n' "$ext" "$n"
done

hr "Manifiestos y build"
for f in package.json pyproject.toml requirements.txt setup.py Pipfile poetry.lock \
         go.mod Cargo.toml pom.xml build.gradle build.gradle.kts Gemfile composer.json \
         Makefile Justfile Taskfile.yml Dockerfile docker-compose.yml compose.yaml; do
  [ -e "$f" ] && echo "  $f"
done

hr "Scripts declarados"
if [ -f package.json ]; then
  echo "-- package.json scripts --"
  (command -v jq >/dev/null && jq -r '.scripts // {} | to_entries[] | "  \(.key): \(.value)"' package.json) \
    2>/dev/null || grep -A30 '"scripts"' package.json | head -32
fi
if [ -f Makefile ]; then
  echo "-- targets de Makefile --"
  grep -E '^[a-zA-Z0-9_.-]+:' Makefile | cut -d: -f1 | sed 's/^/  /' | head -25
fi
if [ -f pyproject.toml ]; then
  echo "-- pyproject: herramientas configuradas --"
  grep -E '^\[tool\.' pyproject.toml | sed 's/^/  /' | head -15
fi

hr "Bucle de retroalimentación"
TESTS=$(echo "$FILES" | grep -icE '(^|/)(tests?|spec|__tests__)/|(_test|\.test|\.spec|_spec)\.' || true)
echo "Archivos que parecen de test: ${TESTS:-0}"
CODE=$(echo "$FILES" | grep -cE '\.(py|ts|tsx|js|jsx|go|rs|java|kt|rb|php|cs)$' || true)
if [ "${CODE:-0}" -gt 0 ] 2>/dev/null; then
  echo "Archivos de código: $CODE"
  echo "Proporción test/código: $(awk -v t="${TESTS:-0}" -v c="$CODE" 'BEGIN{printf "%.2f", t/c}')"
fi
echo "-- CI --"
ls -1 .github/workflows/ 2>/dev/null | sed 's/^/  /' || echo "  (sin .github/workflows)"
for f in .gitlab-ci.yml .circleci/config.yml Jenkinsfile azure-pipelines.yml; do
  [ -e "$f" ] && echo "  $f"
done
echo "-- calidad --"
for f in .pre-commit-config.yaml .eslintrc .eslintrc.json eslint.config.js \
         .ruff.toml ruff.toml mypy.ini .flake8 tsconfig.json .editorconfig; do
  [ -e "$f" ] && echo "  $f"
done

hr "Configuración de agentes ya presente"
FOUND=0
for f in AGENTS.md CLAUDE.md GEMINI.md CONVENTIONS.md .cursorrules \
         .github/copilot-instructions.md .windsurfrules .clinerules; do
  if [ -e "$f" ]; then echo "  $f ($(wc -l <"$f" | tr -d ' ') líneas)"; FOUND=1; fi
done
[ -d .cursor/rules ] && { echo "  .cursor/rules/"; ls -1 .cursor/rules | sed 's/^/    /'; FOUND=1; }
[ -d .claude ] && { echo "  .claude/"; ls -1 .claude | sed 's/^/    /'; FOUND=1; }
[ "$FOUND" = 0 ] && echo "  (ninguna: se crean desde cero)"

hr "Documentación existente"
echo "$FILES" | grep -iE '\.(md|rst|adoc)$' | grep -viE 'node_modules|CHANGELOG' | head -20 | sed 's/^/  /'

hr "Estructura de directorios (2 niveles)"
echo "$FILES" | awk -F/ 'NF>1{print $1"/"($2 ~ /\./ ? "" : $2)}' \
  | sort | uniq -c | sort -rn | head -22

hr "Archivos más modificados (últimos 200 commits)"
if git rev-parse --git-dir >/dev/null 2>&1; then
  git log -200 --name-only --pretty=format: 2>/dev/null \
    | grep -E '\.(py|ts|tsx|js|jsx|go|rs|java|kt|rb|php|cs|sql)$' \
    | sort | uniq -c | sort -rn | head -15
else
  echo "(requiere git)"
fi

hr "Señales de riesgo a inspeccionar a mano"
echo "-- posible manejo de dinero (revisar si usa float) --"
grep -rilE 'decimal|currency|amount|price|monto|importe|comision' \
  --include='*.py' --include='*.ts' --include='*.go' --include='*.java' \
  --include='*.rb' --include='*.cs' . 2>/dev/null | grep -v node_modules | head -10
echo "-- migraciones --"
echo "$FILES" | grep -iE 'migrat|alembic|flyway|liquibase|schema\.rb' | head -8
echo "-- auth y permisos --"
grep -rilE 'jwt|oauth|password|authenticate|permission|authoriz' \
  --include='*.py' --include='*.ts' --include='*.go' --include='*.java' . 2>/dev/null \
  | grep -v node_modules | head -10
echo "-- integraciones externas --"
grep -rhoE 'https?://[a-zA-Z0-9.-]+\.[a-z]{2,}' \
  --include='*.py' --include='*.ts' --include='*.go' --include='*.yml' \
  --include='*.yaml' --include='*.json' . 2>/dev/null \
  | grep -viE 'localhost|127\.0\.0\.1|example\.|schema|w3\.org|npmjs|github\.com' \
  | sort -u | head -12
echo "-- silenciamiento de errores --"
grep -rnE 'except:\s*pass|catch\s*\(\s*\)\s*\{\s*\}|catch\s*\{\s*\}|# ?type: ?ignore|@ts-ignore' \
  --include='*.py' --include='*.ts' --include='*.tsx' . 2>/dev/null \
  | grep -v node_modules | head -10
echo "-- deuda declarada --"
grep -rn 'TODO\|FIXME\|HACK\|XXX' --include='*.py' --include='*.ts' --include='*.tsx' \
  --include='*.go' --include='*.java' . 2>/dev/null | grep -v node_modules | wc -l \
  | awk '{print "  marcas TODO/FIXME/HACK: "$1}'

hr "Fin"
echo "Siguiente paso: lectura cualitativa. Abre los archivos más modificados"
echo "y los de riesgo listados arriba. Busca reglas de dominio implícitas."
