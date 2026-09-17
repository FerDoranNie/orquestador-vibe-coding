# Ruteo: qué tarea, qué herramienta, qué modelo

Para la Fase 4. La matriz sale de cruzar dos ejes: **qué tan caro es
equivocarse** y **cuánto volumen de tokens consume**. Ese cruce, no el
"nivel de dificultad", es lo que decide el destino.

## Los dos ejes

**Costo del error.** ¿Qué pasa si el resultado está mal y se cuela? Un
componente de UI mal alineado se ve y se arregla en dos minutos. Un redondeo
mal hecho en un cálculo de comisiones se factura mal durante un mes antes de
que alguien lo note. El segundo justifica el modelo más capaz aunque el
código sea de veinte líneas.

**Volumen de tokens.** ¿Cuánto contexto hay que cargar y cuánta salida hay que
generar? Un refactor que toca treinta archivos consume muchísimo aunque cada
cambio sea trivial.

Cruzando:

| | Volumen bajo | Volumen alto |
|---|---|---|
| **Error caro** | Modelo tope. Es el mejor dinero que gastas. | Modelo tope para el diseño, luego parte en pedazos chicos y bájalos de nivel. |
| **Error barato** | Modelo intermedio o barato. Da igual. | Modelo más barato disponible. Aquí es donde se gana o se pierde el mes. |

La casilla de arriba a la derecha es la que la gente hace mal. No mandes un
refactor grande y riesgoso completo al modelo caro: haz que el modelo caro
escriba el *plan*, y que el barato ejecute cada pedazo contra ese plan.

## Taxonomía de trabajo

Incluye en la matriz **solo los tipos que existan en este repo**. Una fila
que no aplica es ruido y hace que el usuario deje de leer.

**Diseño y decisiones de arquitectura.** Volumen bajo, error carísimo. Una
mala decisión de esquema el lunes cuesta el jueves completo. Al modelo más
capaz disponible, en modo de planeación, sin escribir código. Salida: un
archivo de plan y registros de decisión.

**Andamiaje inicial.** Volumen medio, error medio-alto, exige coherencia
entre muchos archivos a la vez. Modelo intermedio-alto. Aquí los modelos
baratos se desordenan: pierden el hilo entre archivos y las piezas no encajan.

**Lógica de dominio con reglas de negocio.** Volumen bajo, error caro.
Modelo capaz, y con la regla de negocio explícita en el prompt o en el
AGENTS.md. Ningún modelo puede inferir la regla de la empresa leyendo el
código.

**Implementación de tareas ya especificadas.** Volumen alto, error barato si
hay tests. Al modelo más barato. Este es el grueso del trabajo de una semana
y donde vive el ahorro.

**Boilerplate: DTOs, CRUD, mappers, componentes parecidos entre sí.**
Volumen alto, error barato. Modelo más barato, sin dudarlo.

**Tests.** Volumen medio, error medio. Modelo barato o intermedio, con una
advertencia: nunca dejes que el mismo modelo que escribió el código escriba
el único test que lo cubre. Se pone de acuerdo consigo mismo y el test valida
el bug.

**Migraciones de base de datos.** Volumen bajo, error caro e irreversible en
producción. Modelo capaz, y revisión humana obligatoria del SQL generado.
Ponlo explícito en la matriz.

**Depuración.** Volumen impredecible. Empieza barato. Si falla dos veces por
la misma causa, escala. Ver la escalera abajo.

**Revisión de diffs.** Volumen bajo. Aquí lo que importa no es la capacidad
sino la **diversidad**: usa una familia de modelo distinta a la que escribió
el código. Falla distinto y por eso encuentra cosas que el autor no ve. Si
solo hay una herramienta, al menos usa un modelo distinto al que escribió.

**Verificación de extremo a extremo en navegador.** Si el usuario tiene una
herramienta con control real de navegador, es su destino natural. Si no, es
trabajo humano y hay que decirlo en lugar de fingir que un agente lo cubre.

**Documentación, changelog, mensajes de commit, triage de logs.** Volumen
bajo, error barato. Modelo más chico y rápido. Nunca gastes cupo caro aquí.

**Pruebas repetitivas y automatizadas.** Si el usuario corre suites
repetitivas (regresión, evaluaciones de skills, cualquier cosa en CI), sácalas
de las bolsas de cupo con ventanas y ponlas en una cuenta de pago por token
con tope de gasto. Es trabajo mecánico y las bolsas con ventana no se
acumulan: gastar cupo que no se acumula en trabajo automatizable es el
desperdicio más grande de un setup multi-herramienta.

## Escalera de escalamiento

La regla que más cupo salva: **si falla dos veces por la misma causa, no lo
intentes una tercera vez con el mismo modelo.**

Escalón 1. Modelo barato, tarea especificada.
Escalón 2. Falló. Cambia de *modelo* en la misma herramienta si hay varios
disponibles. Es gratis si ya pagaste la bolsa, y modelos distintos se atoran
en cosas distintas.
Escalón 3. Falló otra vez. Que el agente escriba su diagnóstico en el archivo
de la tarea, bajo un encabezado de bloqueo, y **detente**.
Escalón 4. Lleva *ese archivo* al modelo capaz. Llegas con el contexto del
fallo ya resumido en 300 tokens en lugar de reconstruir la sesión completa.
Escalón 5. Si el modelo capaz también falla, el problema no es el modelo: la
tarea está mal especificada o falta información que solo el usuario tiene.
Regresa a la fase de diseño en lugar de seguir intentando.

Lo que hace caro este bucle no es el modelo caro, es reconstruir contexto en
cada salto. Que el escalón 3 exista es lo que lo hace barato.

## Cuando hay una sola herramienta

El plan no se cae, cambia de eje. Reparte entre modelos y entre fases:

- El modelo tope solo para diseño y para bugs escalados. Nada más.
- El intermedio para casi todo el trabajo real.
- El más chico para docs, commits y triage. Mucha gente nunca lo usa y ahí
  hay ahorro inmediato sin perder nada.
- La higiene de contexto pasa a ser la palanca principal, no secundaria,
  porque es la única que queda. Dale más peso en el entregable.
- La diversidad de revisión se pierde. Compénsala haciendo que la revisión la
  haga un modelo distinto al que escribió, en sesión limpia, sin ver la
  conversación donde se escribió el código.

## Contrato de handoff

Las herramientas no se hablan entre ellas. Se hablan a través del repo. Sin
esto la matriz es teoría.

```
docs/plan-<feature>.md      ← el modelo de diseño escribe aquí
docs/tasks/<n>-<slice>.md   ← una tarea, un archivo, una rama, un commit
docs/review-<slice>.md      ← el revisor escribe aquí
docs/decisions/NNN-*.md     ← registros de decisión
```

Cada archivo de tarea lleva: objetivo, archivos que puede tocar, test que la
prueba, y una sección de bloqueo vacía que el agente llena si se atora.

Para paralelismo, ramas de trabajo separadas en directorios separados:

```bash
git worktree add ../proyecto-slice-3 -b slice-3
```

Dos agentes sobre el mismo directorio se pisan los archivos y el usuario
pierde media hora entendiendo qué pasó. Ponlo en el plan.
