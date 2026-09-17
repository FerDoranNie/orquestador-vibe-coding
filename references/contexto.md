# Higiene de contexto

Para la Fase 4. Los puntos de limpieza no son genéricos: salen de la forma
del trabajo que encontraste en el repo. Un repo con tareas cortas e
independientes tiene puntos de `/clear` distintos a uno con una migración
larga y encadenada.

## La asimetría que casi nadie sabe

`/clear` tira la conversación y arranca de cero. Es **gratis**: no procesa
nada, solo olvida.

`/compact` relee toda la conversación y la resume. Eso significa que **vuelves
a pagar el historial completo** para obtener una versión corta de él. Es una
compra: pagas tokens ahora para pagar menos en cada turno futuro.

De ahí sale la regla por defecto: **`/clear` es lo normal, `/compact` es la
excepción que se justifica.** La mayoría de la gente lo tiene al revés porque
compactar "se siente" como ahorrar.

`/compact` solo vale la pena cuando las tres cosas son ciertas a la vez:

1. Todavía necesitas el hilo del razonamiento, no solo el resultado.
2. Te quedan bastantes turnos por delante en esta misma tarea.
3. El historial es largo, que es justo lo que hace caro compactar.

Si necesitas el resultado pero no el razonamiento, hay algo mejor que
compactar: **pide un resumen a un archivo y luego `/clear`.** El resumen
cuesta una fracción de lo que cuesta compactar y sobrevive a la sesión, lo
cual compactar no logra.

## Dónde va cada uno

`/clear` después de:

- Cerrar una tarea y hacer commit. Es el punto de limpieza más importante y
  el que más se olvida.
- Terminar la fase de diseño y antes de empezar a implementar. La
  conversación de diseño es enorme y el plan ya está en un archivo: no
  necesitas la discusión, necesitas el archivo.
- Una exploración que encontró la respuesta. Guarda la respuesta, tira las
  cuarenta lecturas de archivo que costó encontrarla.
- Cambiar de área del código. El contexto del módulo de pagos no ayuda a
  trabajar en el de notificaciones, solo cuesta en cada turno.
- Cuando el agente empieza a repetirse, a reproponer cosas que ya
  descartaron, o a "olvidar" una instrucción del inicio. Es señal de que el
  contexto está saturado y compactar solo lo aplaza.

`/compact` cuando:

- Estás a media depuración larga y el historial de hipótesis descartadas es
  justamente lo valioso. Sin él el agente vuelve a proponer lo que ya falló.
- Vas a entregar la sesión a otro modelo y necesitas que llegue con contexto,
  pero comprimido.
- Estás a punto de topar el límite de la ventana en medio de algo que no
  puedes cortar.

## Caché de prefijo

Las lecturas de caché cuestan una fracción de lo que cuesta procesar el mismo
texto de nuevo, y el arranque fijo de un agente (instrucciones del sistema,
definiciones de herramientas, archivo de proyecto) es exactamente el prefijo
repetido que el caché absorbe.

Dos consecuencias operativas que van en el plan:

1. **No edites el archivo de instrucciones a media sesión.** Cambiarlo
   invalida el prefijo cacheado y vuelves a pagar el contexto completo desde
   el turno siguiente. Junta las mejoras al AGENTS.md y aplícalas entre
   sesiones, no durante.
2. **Lo volátil no vive en el archivo de instrucciones.** Estado del sprint,
   pendientes del día, notas: todo eso va en `docs/`, que se lee solo cuando
   hace falta. El archivo de instrucciones debe ser lo más estable del repo.

## Presupuesto de contexto

Tres reglas que se pagan solas y que van en el CLAUDE.md o equivalente:

**No dejes que el agente explore para encontrar archivos.** Es el sumidero
número uno. Corre una búsqueda por patrón tú, o pídele que corra exactamente
una, y dale las rutas. La diferencia entre dar la ruta y dejar que la busque
puede ser un orden de magnitud.

**Delega la búsqueda a un subagente** cuando haya que revisar varios
archivos. El subagente lee diez archivos en su propio contexto y regresa un
resumen corto al principal. El costo se paga una vez en lugar de quedarse
cargado en cada turno de ahí en adelante.

**Un turno por intención.** Corregir un plan equivocado a media ejecución
cuesta más turnos que acertar el plan al inicio, y tres mensajes separados de
"¿y este error?" cuestan tres veces lo que uno con los tres errores juntos.
Junta las preguntas.

## Cómo presentarlo

En el tablero, los puntos de contexto van amarrados a las fases reales del
trabajo del repo, no como lista suelta de consejos. La forma útil es una
línea de tiempo del trabajo con los puntos marcados encima:

```
diseño ──▶[clear]── andamiaje ──▶[clear]── rebanada 1 ──▶[clear]── rebanada 2
                                              │
                                        [compact] si el bug se alarga
```

Un consejo suelto se olvida. Un punto marcado en la línea de trabajo que el
usuario va a seguir esta semana, se ejecuta.
