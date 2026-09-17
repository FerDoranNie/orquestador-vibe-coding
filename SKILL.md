---
name: orquestador-vibe-coding
description: Analiza una carpeta local o repo de GitHub, evalúa la infraestructura del usuario (SO, hardware local, privacidad, suites de prueba), consulta precios y documentación oficial vigente de herramientas de IA (Claude Code, Antigravity, Cursor, Codex, Copilot, OpenCode, Aider, Cline, Ollama), y entrega un plan de orquestación completo — estrategia de vibe coding (Harness, Spec-Driven, Evaluator Loop), CLAUDE.md y AGENTS.md sin duplicación, matriz de ruteo de modelos por riesgo vs volumen, higiene de contexto (/clear y /compact) y presupuesto de suscripciones — como tablero HTML visual y archivos listos para commitear. Úsala cuando el usuario pida un plan de orquestación, pregunte qué herramientas comprar o usar según precios oficiales, quiera saber cómo estructurar su bucle de desarrollo con IA (harness/loop), o busque aprovechar mejor sus cuotas y créditos.
---

# Orquestador de vibe coding

Convierte un repo real, la infraestructura del desarrollador y un inventario de
herramientas de IA en un plan de ejecución concreto: qué herramientas son ideales,
qué estrategia de bucle (Harness o Loop) aplicar, quién hace qué tarea, con qué
modelo, en qué orden, y con qué higiene de contexto.

El valor de esta skill no está en dar consejos generales de IA. Está en que
cada recomendación salga de evidencia observada en *ese* repo, de la
infraestructura *real* del usuario, y de la documentación y precios *vigentes*
de *esas* herramientas. Un plan genérico no sirve: el usuario ya lo puede
escribir solo.

## Principio que gobierna todo lo demás

**Nunca afirmes un límite, precio, nombre de modelo o cuota desde memoria.**
Cambian cada pocas semanas y los datos de entrenamiento están viejos casi por
definición. Todo dato numérico de una herramienta se obtiene consultando la
documentación oficial y páginas de precios en esta corrida, o se marca
explícitamente como "verificar". Un plan construido sobre un límite o costo
inventado hace daño: el usuario planea su presupuesto y su semana con él.

## Flujo

Cinco fases. No brinques a los entregables sin haber hecho las dos primeras.

### Fase 1 — Inventario del repo

Determina primero de dónde sale el código:

- **Carpeta local** (Cowork, o una ruta que el usuario dio): trabájala directo.
- **Repo de GitHub**: clona somero para no gastar tiempo ni disco.
  ```bash
  git clone --depth 50 <url> /tmp/repo-analisis && cd /tmp/repo-analisis
  ```
  Si el clon falla por permisos, es privado: pide al usuario que lo suba como
  carpeta o que dé acceso, y no adivines su contenido.
- **Nada de lo anterior**: pregunta. No inventes un repo hipotético a menos
  que el usuario lo pida explícitamente.

Corre el inventario determinista:

```bash
bash scripts/inventario.sh <ruta-al-repo>
```

Ese script saca lo mecánico (lenguajes, tamaño, tests, CI, configs de agentes
ya existentes, archivos más tocados). Léelo y luego **haz la lectura
cualitativa tú**, que es la parte que un script no puede hacer:

1. **¿Dónde vive el riesgo?** Busca el código donde un error cuesta caro:
   dinero, permisos, datos de usuarios, migraciones, integraciones con
   terceros que no se pueden reintentar. Eso define qué se manda al modelo
   más capaz.
2. **¿Dónde vive el volumen?** Boilerplate, CRUD, DTOs, tests de tabla,
   endpoints repetidos, componentes de UI parecidos. Eso define qué se manda
   al modelo más barato.
3. **¿Qué reglas de dominio están implícitas?** Busca las convenciones que
   solo se entienden leyendo el código: cómo se manejan errores, si el dinero
   es decimal, si hay una capa que no debe importar frameworks, qué
   nombramiento se repite. Estas son las líneas más valiosas del AGENTS.md
   porque son las que ningún agente puede inferir de fuera.
4. **¿Qué tan bueno es el bucle de retroalimentación?** ¿Hay tests que
   corran rápido (<30s)? ¿CI? Sin esto, ningún plan de agentes funciona y
   decirlo es más útil que cualquier matriz de ruteo. Si el repo no tiene tests,
   la primera recomendación del plan es construir el arnés de pruebas (harness).
5. **¿Ya hay AGENTS.md, CLAUDE.md, .cursorrules, .github/copilot-instructions?**
   Si existen, el trabajo es mejorarlos y unificarlos, no reemplazarlos. Léelos
   y respeta lo que el usuario ya decidió.

Antes de seguir, resume al usuario en 5-8 líneas qué encontraste. Si te
equivocaste sobre el dominio, quieres saberlo ahora y no en el entregable.

### Fase 2 — Entrevista de herramientas, infraestructura y presupuesto

Pregunta al usuario de forma ágil y tapeable (con `ask_question` o selector
interactivo si está disponible). No hagas un interrogatorio largo; son 4
bloques concisos:

1. **Modalidad del objetivo**:
   - *Optimizar stack actual*: Ya tiene herramientas y planes contratados y
     quiere el mejor plan de ruteo y ahorro.
   - *Recomendar stack y presupuesto ideal*: No tiene herramientas fijas o
     evalúa qué comprar/usar según el costo-beneficio oficial para este proyecto.
2. **Herramientas y planes actuales** (si aplica):
   - Herramientas: Claude Code, Antigravity, Cursor, Codex, GitHub Copilot,
     OpenCode, Aider, Cline, etc.
   - Planes: Pro, Max, Team, Go, o llaves de API propias (BYOK).
3. **Infraestructura del usuario**:
   - **Sistema Operativo y Shell**: macOS, Linux, WSL2, o Windows nativo.
     (Vital: herramientas CLI puras como Claude Code o scripts bash sufren en
     Windows nativo; entornos con IDE visual o WSL2 son preferibles).
   - **Hardware local**: ¿Cuenta con equipo para modelos locales a $0 de costo?
     (Mac Apple Silicon con 16GB-32GB+ RAM o PC con GPU NVIDIA con 8GB-16GB+
     VRAM para Ollama / LM Studio).
   - **Políticas de Privacidad y Red**: ¿Puede enviar código a APIs en la nube
     o la empresa exige modo de privacidad estricto / modelos self-hosted?
4. **Cuello de botella principal**:
   - Se le acaba el cupo/dinero, calidad del código generado, velocidad de
     entrega, o no sabe qué herramienta usar en cada momento.

### Fase 3 — Leer la documentación y precios vigentes

Para cada herramienta evaluada (sea que el usuario la tenga o que se le vaya a
recomendar), lee `references/herramientas.md` para conocer las URLs oficiales de
documentación y páginas de pricing. Consulta la información en vivo:

Lo que tienes que salir sabiendo, con datos verificados:

- **Precios y tiers oficiales vigentes**: Costo mensual de suscripción fija
  (Pro, Team, Business), modelos pay-per-token por millón de tokens (input,
  output, cache write/read), o gratuidad de modelos locales.
- **Modelos disponibles hoy y sus nombres exactos**: No asumas versiones.
- **Cómo se mide el cupo**: Ventana rodante (ej. 5 horas), peticiones rápidas
  mensuales, créditos en dólares o tokens.
- **Si hay bolsas separadas por familia de modelo**: La fuente de arbitraje
  más grande (ej. usar modelos incluidos en una suite sin gastar la cuota
  directa del proveedor).
- **Nombre exacto del archivo de instrucciones**: `AGENTS.md`, `CLAUDE.md`,
  `.cursor/rules/`, etc.
- **Comandos de contexto que expone**: `/clear`, `/compact`, o equivalentes.

Cita la fuente y URL de cada dato numérico y precio en el entregable con la
fecha de consulta.

### Fase 4 — Derivar estrategia, ruteo y presupuesto

Cruza los datos del repo con los de infraestructura y precios:

1. **Selecciona la Estrategia de Vibe Coding Decisiva** (lee
   `references/estrategias.md`):
   - **Test Harness Loop**: Si el repo tiene tests rápidos. El agente itera en
     bucle local (código → harness → fix) antes de commitear.
   - **Spec-Driven Loop**: Si el proyecto requiere features nuevas o control
     estricto de presupuesto. Modelo caro diseña la spec en `PLAN.md`; modelo
     barato ejecuta tareas atómicas.
   - **Evaluator-Optimizer Loop**: Si el código toca lógica de alto riesgo
     (pagos, seguridad). Un agente genera y otro independiente audita el diff.
   - **Context Reset Loop**: Obligatorio en todos los casos. Micro-sesiones con
     `/clear` tras cada commit para erradicar el *context rot*.

2. **Deriva la Matriz de Ruteo** (lee `references/ruteo.md`):
   - Cruza **Costo del error** vs **Volumen de tokens** para cada tarea que
     *realmente exista* en este repo.
   - Si el hardware lo permite y no hay riesgo, asigna boilerplate a modelos
     locales (Ollama) o modelos ultrabaratos (DeepSeek V3 / Flash) a costo
     mínimo.
   - Asigna lógica de dominio y arquitectura a modelos frontera con thinking.

3. **Recomendación de Presupuesto y Herramientas Ideales**:
   - Si el usuario pidió recomendación, presenta el desglose del stack ideal:
     herramienta de arquitectura + herramienta de edición/volumen, con su
     costo mensual estimado en dólares basado en las páginas oficiales.

4. **Puntos de Higiene de Contexto** (lee `references/contexto.md`):
   - Dónde hacer `/clear` y dónde `/compact`.

### Fase 5 — Entregables

Cuatro archivos en el directorio de salida, y luego `present_files` con el
tablero primero:

1. **`tablero-orquestacion.html`** — el entregable principal visual. Construye a
   partir de `assets/tablero.html` reemplazando el bloque `const DATOS = {...}`
   con los datos reales: herramientas, modelos, estrategia de loop, matriz de
   ruteo, presupuesto estimado y fuentes citadas.
2. **`AGENTS.md`** — redactado para este repo. Reglas duras extraídas del
   código real, comandos reales (Makefile/package.json/pyproject), arnés de
   pruebas y mapa de directorios. Cero placeholders inventados.
3. **`CLAUDE.md`** — solo si aplica Claude Code. Importa `@AGENTS.md` y agrega
   únicamente parámetros de Claude (ruteo, economía de contexto, plan mode).
   **Nunca dupliques contenido.**
4. **`plan-orquestacion.md`** — el plan en prosa: estrategia de bucle (Harness/Loop),
   fases del trabajo, contrato de handoff entre agentes, presupuesto mensual
   desglosado con precios oficiales y URLs citadas.

Si el usuario usa herramientas con distintos nombres de archivo:
```bash
ln -s AGENTS.md .cursorrules
```
Una sola fuente de verdad, múltiples herramientas.

## Cómo hablar de esto

Calíbrate por cómo escribe el usuario:
- Dev senior: directo al grano, comandos técnicos, métricas de tokens y latencia.
- Principiante: explica términos ("ventana rodante", "harness", "context rot")
  la primera vez que aparezcan.

Dos reglas estrictas:
- **No inventes números ni porcentajes de ahorro**: Di qué palanca mueve qué y
  deja que el usuario mida con sus tests y facturación.
- **No recomiendes parches no oficiales**: Mantente en APIs y canales oficiales.

## Archivos de referencia

Consulta cada archivo en su fase correspondiente:

- `references/herramientas.md` — registro de herramientas, URLs oficiales de
  docs y páginas de pricing, modelos locales y criterios de infraestructura. Fase 3.
- `references/estrategias.md` — estrategias decisivas de vibe coding: Test Harness
  Loop, Spec-Driven Loop, Evaluator-Optimizer, Context Reset Loop. Fase 4.
- `references/ruteo.md` — taxonomía de tareas, matriz riesgo vs volumen y
  escalera de modelos. Fase 4.
- `references/contexto.md` — `/clear` vs `/compact`, caché de prefijo, presupuesto
  de tokens y contratos de handoff. Fase 4.
- `assets/tablero.html` — plantilla interactiva del tablero HTML. Fase 5.
- `scripts/inventario.sh` — inventario mecánico del repo. Fase 1.
