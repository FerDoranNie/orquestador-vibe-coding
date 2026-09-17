# Registro de herramientas

Punto de partida para la Fase 3. **Las URLs son puntos de entrada, no
respuestas.** Todo dato numérico (límites, precios, nombres de modelos) se
trae con `web_fetch` en esta corrida. Si una URL cambió, busca en el dominio
oficial con `web_search`.

Contenido:
1. [Claude Code](#claude-code)
2. [OpenCode](#opencode)
3. [Antigravity](#antigravity)
4. [Codex](#codex)
5. [Cursor](#cursor)
6. [GitHub Copilot](#github-copilot)
7. [Gemini CLI](#gemini-cli)
8. [Aider](#aider)
9. [Cline y Kilo Code](#cline-y-kilo-code)
10. [Modelos Locales (Ollama / LM Studio)](#modelos-locales-ollama--lm-studio)
11. [Herramienta no listada](#herramienta-no-listada)
12. [Preguntas que resuelve la doc](#preguntas-que-resuelve-la-doc)

---

## Claude Code

- Docs: https://docs.claude.com/en/docs/claude-code/overview
- Mapa de docs: https://docs.anthropic.com/en/docs/claude-code/claude_code_docs_map.md
- Precios de API y modelos: https://www.anthropic.com/pricing
- Límites y planes de suscripción: https://support.claude.com

Archivo de instrucciones: `CLAUDE.md`. Soporta `@ruta` para importar otros
archivos, que es lo que permite tener un `AGENTS.md` compartido sin duplicar.
Jerarquía: hay un archivo de usuario global y uno por proyecto.

Cupo: depende del plan y hay que verificarlo, no asumirlo. Los planes
individuales (Pro) y los asientos de organización (Team/Enterprise) se miden
por ventanas de tiempo (ej. 5 horas rodantes); los planes basados en consumo
de API se cobran por millón de tokens (input/output/cache). Esa distinción
cambia todo el ruteo, así que pregúntala. El cupo se comparte con el chat y
otras superficies del mismo plan.

Verifica con `/usage` dentro de la herramienta: es el único número que
refleja la cuenta real del usuario.

Contexto: `/clear`, `/compact`, plan mode, subagentes.

Fuerte en: diseño y planeación, refactors que cruzan muchos archivos,
depuración de bugs que ya resistieron otros modelos, seguir instrucciones
largas de un archivo de proyecto.

---

## OpenCode

- Docs: https://opencode.ai/docs/
- Plan Go: https://opencode.ai/docs/go/
- Catálogo de modelos y precios (OpenRouter / BYOK): https://openrouter.ai/models

Agente open source de terminal. Conecta muchos proveedores, incluyendo llaves
propias del usuario, y habla APIs compatibles con OpenAI y Anthropic, así que
también sirve como proveedor para otros agentes.

Archivo de instrucciones: `AGENTS.md`.

Cupo: si el usuario está en el plan Go, verifica en la doc cómo se mide hoy
(ha cambiado entre conteo de peticiones y medición en dólares) y qué modelos
incluye. Si usa llaves propias (BYOK), es pago por token sin ventanas.

Fuerte en: volumen. Implementar tareas ya especificadas, con modelos abiertos
que cuestan una fracción (DeepSeek V3, Qwen 2.5 Coder). Poder cambiar de modelo
cuando uno se atora, sin costo adicional, es su ventaja operativa real.

---

## Antigravity

- Docs: https://antigravity.google/docs/
- Modelos: https://antigravity.google/docs/models/
- Planes y cuotas: https://antigravity.google/docs/plans/
- Beneficios de suscripción: https://support.google.com/googleone y https://one.google.com/explore-plan

IDE con agentes autónomos que manejan editor, terminal y navegador integrado.

Archivo de instrucciones: verifica en la doc vigente, soporta reglas a nivel
global y workspace (`.agents/skills/` y reglas markdown).

Cupo: **revisa si tiene contadores separados por familia de modelo.** Cuando
los tiene, es la fuente de arbitraje más grande de todo el setup: permite
correr modelos de un proveedor sin tocar la suscripción directa del usuario a
ese mismo proveedor. Verifica también si hay créditos de sobrecupo y cómo se
activan.

Fuerte en: verificación de extremo a extremo con bucle visual (browser
subagent). Tareas de frontend donde la prueba es "ábrelo y compruébalo" en lugar
de un test unitario.

---

## Codex

- Docs: https://developers.openai.com/codex/
- Precios y límites: https://openai.com/pricing y https://chatgpt.com/#pricing
- Especificación de `AGENTS.md`: https://agents.md

Archivo de instrucciones: `AGENTS.md`.

Cupo: incluido en los planes de ChatGPT (Plus, Team, Pro), con ventanas de
tiempo. Verifica el nivel del usuario, si puede comprar crédito extra al topar,
y qué modelos tiene disponibles hoy.

Fuerte en: revisión independiente. Su valor en un setup multi-herramienta es
que falla distinto a los demás, así que encuentra cosas que un solo
proveedor no ve. Revisar diffs cuesta pocos tokens y cabe en cuotas chicas.

---

## Cursor

- Docs: https://docs.cursor.com
- Precios oficiales: https://www.cursor.com/pricing

Archivo de instrucciones: reglas en `.cursor/rules/` (formato moderno) y
`.cursorrules` (heredado).

Cupo: modelo híbrido de peticiones rápidas/premium incluidas al mes (ej. 500
fast requests en plan Pro de $20/mes) y uso extendido o basado en consumo de
API. Verifica los límites vigentes en su sitio.

Fuerte en: edición interactiva con contexto del editor, autocompletado en
línea (Tab predictivo), cambios chicos y frecuentes en archivos abiertos.

---

## GitHub Copilot

- Docs: https://docs.github.com/copilot
- Precios oficiales: https://github.com/features/copilot#pricing

Archivo de instrucciones: `.github/copilot-instructions.md`.

Cupo: suscripción mensual plana ($10 Individual, $19 Business, $39 Enterprise).
Verifica el modelo de peticiones premium o modelos alternativos permitidos.

Fuerte en: autocompletado en línea, integración profunda con GitHub (PRs,
issues) y cumplimiento corporativo para empresas que no permiten APIs externas
abiertas.

---

## Gemini CLI

- Docs y repos: organización google-gemini en GitHub.
- Precios y cuotas API: https://ai.google.dev/pricing

Archivo de instrucciones: `GEMINI.md`.

Cupo: nivel gratuito con cuota por minuto/día (RPM/RPD) y niveles de pago por
token consumido.

Fuerte en: tareas con ventanas de contexto gigantes (1M - 2M tokens), como
ingerir un repositorio entero, logs masivos o bibliotecas de documentación
completas en un solo prompt.

---

## Aider

- Docs: https://aider.chat/docs/
- Tabla de líderes y costos: https://aider.chat/docs/leaderboards/

Archivo de instrucciones: `CONVENTIONS.md`, cargado explícitamente.

Cupo: llaves propias (BYOK), pago por token según proveedor elegido.

Fuerte en: cambios quirúrgicos con commits de Git automáticos por edición,
y control fino de qué archivos entran al contexto gracias a su grafo de repo
(repo-map).

---

## Cline y Kilo Code

- Cline: https://docs.cline.bot
- Precios de modelos asociados (OpenRouter): https://openrouter.ai/pricing

Extensiones de VS Code que aceptan cualquier proveedor compatible con OpenAI.
Archivo de instrucciones: `.clinerules` o reglas del proyecto.

Fuerte en: ser el frente gráfico para un plan de terceros dentro de VS Code con
soporte para ejecutar comandos de terminal con confirmación paso a paso.

---

## Modelos Locales (Ollama / LM Studio)

- Ollama: https://ollama.com
- LM Studio: https://lmstudio.ai

Modelos de código recomendados para ejecución local: Qwen 2.5 Coder (7B, 14B,
32B), DeepSeek Coder, Llama 3 Code.

Requisitos de infraestructura recomendados:
- **Mínimo viable**: Mac con chip Apple Silicon (M1/M2/M3/M4) con 16GB+ de RAM,
  o PC con GPU NVIDIA (RTX 3060/4060 o superior con 8GB+ VRAM).
- **Óptimo para 32B**: 32GB a 64GB de memoria unificada o 16GB+ VRAM dedicada.

Cupo: **$0.00**, sin límite de peticiones ni ventanas rodantes. Totalmente
offline y privado.

Fuerte en: tareas de volumen mecánico (boilerplate, tests unitarios estándar,
documentación, formateo) cuando el hardware lo soporta y el usuario quiere
ahorrar el 100% de su cuota de cloud.

---

## Herramienta no listada

Si el usuario nombra algo que no está aquí:

1. `web_search` con el nombre más "docs", "pricing" y "AGENTS.md" o "instructions".
2. Averigua: modelos, cómo se mide el cupo, precios de suscripción o token,
   archivo de instrucciones, comandos de contexto, y cuál es su ventaja diferencial.
3. Si no encuentras documentación oficial, dilo. No inventes su
   funcionamiento. Trátala como caja negra en el plan y pregúntale al usuario.

---

## Preguntas que resuelve la doc

Checklist para no salir de la Fase 3 a medias:

- [ ] Nombres exactos de los modelos disponibles hoy
- [ ] Precios oficiales vigentes (mensualidad fija, crédito o costo por 1M tokens)
- [ ] Unidad de cupo: tiempo, peticiones, dólares, créditos, tokens
- [ ] ¿Hay bolsas separadas por familia de modelo?
- [ ] ¿Qué pasa al topar: esperar, crédito, tarifa de API?
- [ ] ¿El cupo se comparte con superficies que no son código?
- [ ] Nombre y ubicación del archivo de instrucciones, y si soporta imports
- [ ] Comandos de contexto disponibles (/clear, /compact)
- [ ] Fecha de consulta y URLs de referencia, para citarlas en el entregable
