---
name: bucket-analysis-es
description: "Analiza una visión de producto frente a una base de código generando automáticamente 'buckets' (cubos) de funcionalidades/temas y puntuando cada uno de 0 a 100%. Úsala cuando te pidan 'auditar producto vs. visión', 'hacer un bucket analysis', 'puntuar el avance contra la visión', 'mapear la visión al código', 'encontrar brechas hacia el MVP', o quieran un análisis de brechas estructurado. Requiere un documento de visión (texto pegado o ruta de archivo). Deriva automáticamente los buckets por proyecto — temas técnicos + UX/UI + identidad visual + principios de la visión — y reporta qué falta para llegar al 100% por tema."
metadata:
  author: tcxcx
  version: "1.0.0"
  language: es
  argument-hint: <ruta-o-texto-de-la-vision>
---

# Análisis por Buckets

Puntúa qué tan cerca está la base de código actual del MVP completo descrito
en la visión. Los buckets se **auto-generan por proyecto** a partir de la
visión — nunca están hardcodeados. El resultado es un scorecard por bucket +
trabajo de cierre concreto para llegar al 100%.

La skill nunca inventa funcionalidades que no están en la visión. Si la
visión no menciona un bucket, no lo crees. Si la visión menciona algo vago
("buena UX"), deriva criterios concretos a partir del texto adyacente de la
visión (segmentos, principios, integraciones).

---

## El trabajo

1. **Cargar la visión.** Lee la visión pegada o el archivo que el usuario señale.
2. **Derivar los buckets.** Agrupa el contenido de la visión en 8–15 temas cohesivos.
3. **Definir el 100% por bucket.** Para cada bucket, escribe 6–12 criterios de
   aceptación concretos extraídos de la propia visión.
4. **Mapear evidencia.** Busca en la base de código cada criterio. Marca cada
   criterio como ✓ hecho / ◐ parcial / ✗ falta, citando archivo:línea cuando se encuentre.
5. **Puntuar.** `% = (hechos + 0.5·parciales) / total_criterios × 100`. Redondea a 5%.
6. **Reportar.** Tabla + detalle por bucket + plan de cierre priorizado.
7. **Detente antes de editar código.** Esta es una skill de análisis, no de implementación.

---

## Paso 1 — Cargar la visión

Si el usuario pega la visión en el prompt, úsala tal cual.
Si señala un archivo, léelo con `Read`.
Si no hay visión, pídesela — la skill no puede continuar sin una.

**Requisito obligatorio:** la visión debe caber en 1–3 páginas. Si la visión
es un manifiesto de 30 páginas, pide al usuario que fije las 3 secciones más
estructurales. Esta skill no hace síntesis sin límites.

---

## Paso 2 — Auto-derivar los buckets

Lee la visión y agrupa su contenido. Costuras naturales a buscar:

- **Segmentos / personas** — cada segmento nombrado en la visión que
  necesita una superficie propia obtiene su propio bucket (p. ej.
  "consumidor", "agencia", "corporativo", "agente-a-agente").
- **Principios de arquitectura** — cada principio con peso de implementación
  (p. ej. "abstracción de canales", "policy-as-code", "sesiones con
  estado", "medición de nanopagos") obtiene un bucket.
- **Integraciones / "stack tecnológico"** — servicios externos con
  superficie no trivial (GDS, pagos, KYC, canales) obtienen un bucket por
  servicio o un bucket de integraciones consolidado.
- **Modelo de monetización** — tablas de precios, medición, liquidación, pagos.
- **Máquina de estados del dominio** — si la visión describe un ciclo de
  vida (buscado → retenido → emitido → conciliado), eso es su propio bucket.
- **Superficies UX / UI** — dashboards, UIs de canal, flujos de onboarding.
- **Identidad visual / sistema de diseño** — colores de marca, tipografía,
  sistema de componentes, iconografía, tono.
- **Fundamentos** — monorepo, runtime, DB, auth, env, CI/CD, deploy.
- **Observabilidad / testing / seguridad** — logs, métricas, trazas,
  tracking de errores, estrategia de tests, rate-limit, detección de bots,
  cumplimiento normativo.

Apunta a **8–15 buckets**. Fusiona buckets que comparten criterios de
aceptación. Divide buckets que colisionan en límites de ownership.

**Nunca auto-generes buckets que la visión no justifique.** Si la visión
nunca dice la palabra "analytics", no inventes un bucket de analytics. Si la
visión guarda silencio sobre un tema que parece estructural, señálalo en la
sección "Brechas de la visión" del reporte en lugar de colarlo en un bucket.

### Buckets de máxima prioridad (prefijo HP)

Cuando la visión señala explícitamente un bucket "a lanzar primero" /
"máxima prioridad" / "esto va antes que el resto" — prefíjalo `HP1`, `HP2`,
etc. (de "highest priority") y colócalos por encima de la secuencia estándar
`B1–B12`.

Esto es poco frecuente. La mayoría de las visiones no señalan prioridad a
este nivel de detalle. Pero cuando lo hacen — cuando una sección de la
visión dice "esta es la primera sección del backlog experimental" o "esto
debería lanzarse antes que las herramientas de investigación más amplias" o
"esta es la funcionalidad estrella" — honra esa señal en el orden del
scorecard.

Los buckets con prefijo HP reciben la misma disciplina de puntuación que
los buckets estándar: 0–100% contra el sustrato real de la base de código,
con evidencia archivo:línea. Simplemente se ordenan arriba en el reporte y
en el plan de cierre.

Ante la duda, no agregues el prefijo HP. Un `B1` estándar está bien.

Ejemplo de una spec real: `HP1 Hobby-Aware Concierge`, `HP2 Monocle-Level
Taste Engine` se agregaron porque el documento de visión los enmarcó
explícitamente como "primera sección del backlog experimental" y "nuevo
bucket de máxima prioridad experimental". Sin esa señal explícita, ambos
habrían sido buckets estándar.

### Buckets especiales a considerar por proyecto

- **Identidad visual / color** — siempre es un bucket cuando la visión
  menciona marca, estética o tono de canal específico. Criterios: paleta de
  marca definida en tokens, colores semánticos (éxito/advertencia/error),
  acentos acordes al canal (p. ej. verde de WhatsApp, morado de Slack),
  modo oscuro, chequeos de contraste.
- **Aprovechamiento del starter-kit** — si el proyecto usa un starter de
  monorepo conocido (next-forge, t3-turbo, Vercel Platforms, create-turbo),
  deriva un bucket que puntúe "¿estamos usando lo que el starter ya da?"
  vs. "¿estamos reinventando?". Aquí suelen estar las victorias de cierre
  más rápidas.

### Buckets de máxima prioridad (prefijo HP)

Algunos buckets son tan estructurales que deberían lanzarse antes que el
resto de la secuencia estándar. Márcalos con **prefijo HP** (HP1, HP2, …) y
mantenlos POR ENCIMA de los buckets numerados B1–BN en el scorecard.

Cuándo usar el prefijo HP:

- El bucket produce el momento de demo / "magia" más fuerte del producto.
- Se compone de primitivas ya lanzadas (puntuación alta / poca construcción nueva).
- Desbloquea una categoría de trabajo posterior del que dependen otros buckets.
- Carga el riesgo más bajo de API externa o consentimiento de todo el scorecard.

Si dos o más buckets cumplen esto, secuéncialos como HP1, HP2, HP3 en orden
de prioridad. Los buckets estándar B1–BN se siguen numerando por
puntuación, no por prioridad.

El fasing entonces queda así:
- **Fase 1** = HP1 + fundamento (p. ej. un feature flag) + 1 bucket B transversal
- **Fase 2** = HP1 feature-complete + arranca HP2
- **Fase 3** = buckets B restantes en orden de puntuación

Esto mantiene el scorecard honesto (todo se puntúa; nada se esconde)
mientras hace que la secuencia de lanzamiento refleje criterio de producto,
no solo aritmética.

---

## Paso 3 — Definir el 100% por bucket

Para cada bucket, escribe **6–12 criterios de aceptación** que sean:

- Binarios (se cumplen o no)
- Grep-eables (nombrables como un archivo, función, variable de entorno, ruta o campo de schema)
- Extraídos del lenguaje de la visión (usa los sustantivos y verbos propios de la visión)
- Acotados al MVP (no funcionalidades aspiracionales post-MVP)

Criterios malos (evítalos):
- "Buena UX" — no es binario
- "Arquitectura escalable" — no es grep-eable
- "A prueba de futuro" — no está acotado al MVP

Criterios buenos (consérvalos):
- "Herramienta MCP `search_flights` expuesta con schema Zod en /.well-known/mcp"
- "Cada acción del agente escribe `session_id, traveler_id, action_type, cost_micro` en logs estructurados"
- "Paleta de marca definida como tokens de Tailwind en `packages/design-system/tokens.ts`"
- "El adaptador de WhatsApp implementa `send(message)`, `receive(webhook)`, `signVerify()`"

### No reduzcas el bucket a checkboxes mecánicos

Un scorecard con 100% de criterios binarios mecánicos se pierde la calidad
de producto. Algunos criterios *deberían* capturar gusto / criterio propio /
"joie de vivre" — la señal no mecánica que distingue un directorio de un
conserje, una app CRUD de un producto querido. Estos criterios igual deben
ser evaluables, solo que no con un simple grep.

Dónde los criterios binarios se quiebran:
- "Existe la franja de introspección Phoenix" — grep-eable ✓. Pero: ¿es
  legible de un vistazo por un operador no técnico? Eso necesita un
  criterio de *gusto/criterio*: "La franja usa tabular-nums + bordes finos
  + ≤3 KPIs de un vistazo" — sigue siendo grep-eable (nombres de clases
  CSS) pero anclado en la intención de UX.
- "La herramienta de recomendación devuelve el top-N" — grep-eable ✓. Pero:
  ¿son *buenas* las recomendaciones? Eso necesita un criterio con forma de
  eval tipo Plurai: "El rubric de recomendación puntúa ≥ 0.85 en
  `aesthetic_alignment` sobre 30 turnos dorados" — ancla el criterio en un
  rubric medible.
- "El mensaje de anticipación se dispara" — grep-eable ✓. Pero: ¿un humano
  real lo encontraría *útil* o *molesto*? Eso necesita un criterio de
  resultado: "≥ 70% de las anticipaciones disparadas reciben una respuesta
  positiva dentro de 24h, sin `stop` / `no` / `snooze`" — ancla en señal
  observable.

Apunta a ~80% de criterios mecánicamente grep-eables + ~20% de criterios
anclados en gusto/criterio propio por bucket. Los criterios de criterio
propio necesitan una señal evaluable (rubric, eval gate, métrica de
resultado) — no vibes.

---

## Paso 4 — Mapear evidencia

No puntúes de memoria. Ejecuta búsquedas concretas:

- `Glob` para las rutas de archivo esperadas
- `Grep` para nombres de funciones/variables/env-vars
- `Read` para confirmar implementación real vs. scaffolding

Para bases de código grandes, **despacha agentes de exploración en
paralelo** (uno por bucket o uno por cada 2–3 buckets relacionados) para
obtener evidencia limpia por bucket sin contaminar el contexto principal.

Cada criterio debe terminar como uno de:

- **✓ hecho** — encontrado + luce production-ready (tiene tests, está
  conectado, maneja errores)
- **◐ parcial** — encontrado pero con alguno de: solo scaffolding, sin
  tests, sin manejo de errores, sin conexión a quien lo invoca, sin
  adaptador de canal, detrás de un feature flag apagado
- **✗ falta** — no se encontró evidencia

Cita `archivo:línea` para ✓ y ◐. Citar evidencia es lo que separa esta
skill de especular sin fundamento.

---

## Paso 5 — Puntuar

`% = round_to_5((hechos + 0.5 × parciales) / total × 100)`

Redondea *hacia abajo* al 5% más cercano. Un bucket con 7/10 ✓, 1 ◐, 2 ✗
puntúa `(7 + 0.5)/10 = 75%`.

Detente en 100% solo cuando cada criterio sea ✓. "No queda nada" no
significa ✓-sobre-parcial; parcial es 50% y debe terminarse.

---

## Paso 6 — Reportar

Emite el resultado exactamente con esta forma:

```
## Scorecard de buckets

| # | Bucket                          | Puntaje | ✓ | ◐ | ✗ |
|---|---------------------------------|---------|---|---|---|
| 1 | Motor de agente & sesión        |   65%   | 5 | 2 | 1 |
| 2 | Adaptadores de canal             |   40%   | 2 | 2 | 4 |
| ...

## Detalle por bucket

### 1. Motor de agente & sesión — 65%
**Criterios** (extraídos de: "Principios de arquitectura — sesiones con estado"):
- ✓ La sesión se resuelve entre canales — `packages/agent/session.ts:42`
- ✓ El historial de conversación persiste — `packages/database/prisma/schema.prisma:120`
- ◐ Las preferencias se adjuntan a la sesión — scaffolding, sin ruta de escritura (`packages/agent/preferences.ts:8`)
- ✗ Sesión direccionable por id vía MCP — no se encontró lookup en el adaptador mcp

**Para llegar al 100%:**
1. Conectar la ruta de escritura de preferencias desde las confirmaciones de reserva de Duffel.
2. Agregar `mcp.resolveSessionById(id)` en el adaptador MCP.

### 2. Adaptadores de canal — 40%
...

## Brechas de la visión

Cosas que la visión no cubre pero que el código tiene o necesita de todos
modos (señálalas, no las puntúes):
- ...

## Aprovechamiento del starter

Funcionalidades específicas del starter que el proyecto debería adoptar
para cerrar buckets más rápido:
- ...

## Plan de cierre

Ordenado por (valor × facilidad). Los 5 ítems que mueven más buckets:
1. ...

## APIs externas / integraciones necesarias

Para cada bucket que depende de servicios externos, lista:
- Nombre de la API + proveedor
- Nombre de env-var recomendado (convención del proyecto)
- Tier gratuito vs. pago; notas de cuota
- Forma de auth (key, OAuth, service account)
- Notas de restricción / regulatorias (p. ej. Meta deprecó la Basic Display API el 2024-12-04)

Ejemplo:
| Bucket | API | Env var | Tier | Notas |
|---|---|---|---|---|
| HP1 Hobby-Aware | Google Places API New | `GOOGLE_MAPS_API_KEY` | Pago; $17/1k Text Search | Un solo proyecto GCP, múltiples APIs habilitadas |
| HP1 Hobby-Aware | Luma Public API | `LUMA_API_KEY` | Tier gratuito | Header: `x-luma-api-key` |
| HP2 Taste Engine | Vertex AI Vision | `GOOGLE_APPLICATION_CREDENTIALS` | Pago por imagen | Reutiliza el auth de Vertex existente; cap por tenant obligatorio |

Esto es lo que el usuario lleva a ops/facturación para provisionar keys. Es
la parte más barata del reporte de producir y la de mayor apalancamiento —
sin ella el usuario abre un ticket nuevo cada vez que se topa con una key
faltante. Incluye siempre esta sección cuando algún bucket toque servicios
externos.

## Fasing de PRs (cuándo usarlo)

Sub-sección opcional. Solo genérala cuando el usuario pregunte "¿cómo
secuencio el cierre?" o cuando el plan de cierre tenga > 5 ítems y una
agrupación obvia. Formato:

| PR | Buckets tocados | Herramientas / superficies | Gancho de demo |
|---|---|---|---|
| PR-1 | B4, B9 | una línea | "el usuario escribe X → ve Y" |
| ...

Un bucket por encima del 30% con varios criterios de aceptación
típicamente mapea a un PR. Un bucket por encima del 50% con > 8 criterios
puede dividirse en 2-3 PRs. Los buckets con prefijo HP siempre reciben su
propia secuencia de PRs (PR-H1, PR-H2…).
```

Mantén el reporte ajustado. Sin lenguaje de marketing. Cada afirmación debe
tener un archivo:línea o "no se encontró evidencia".

---

## Ejecución iterativa

El usuario normalmente pide "llegar al 100% en cada tema". Eso es un loop
multi-turno:

- Ronda 1: entrega el scorecard + el plan de cierre.
- Ronda 2 (solo si se pide): implementa los ítems de cierre principales,
  luego re-puntúa.
- Ronda 3+: repite.

**No empieces a implementar en la ronda 1.** El análisis es el entregable.
Solo toma el martillo cuando el usuario diga "cierra los ítems principales"
o algo similar.

---

## Anti-patrones — no hagas esto

- **No califiques con la curva.** Un bucket al 40% es 40%, no "prometedor".
- **No rellenes con aspiración.** Si la visión no lo dice, no es una brecha.
- **No ignores el bucket de sistema de diseño / color.** La mayoría de las
  auditorías de ingeniería se saltan esto; la visión siempre tiene una
  marca, aunque sea implícita.
- **No te saltes la evidencia.** Un scorecard sin citas archivo:línea es
  ficción.
- **No dividas buckets automáticamente para inflar el conteo de ✓.** 8–15
  buckets en total; si estás por encima de 15 estás sobre-dividiendo.
- **No escribas buckets que la base de código no se pueda grep-ear.** Si
  un criterio no se puede verificar en un número finito de búsquedas,
  reescríbelo.
