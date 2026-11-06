---
name: gateman-analysis-es
description: Auditoría de código post-implementación bajo "No asumas nada, cuestiona todo, no idolatres a nadie, aplaude la humildad" — las cuatro leyes del profesor de economía de UBC Robert Gateman, aplicadas al código y a la salida de la IA. Úsala cuando te pidan "ejecuta gateman", "análisis gateman", "auditoría post-implementación", "verificación pre-merge", "cuestiona mis supuestos", "no confíes en la IA", "audita alucinaciones" o "¿es seguro desplegar esto?". Sugiérela proactivamente al terminar una función sensible en seguridad, finanzas, blockchain, cumplimiento normativo o que consuma salida de un LLM.
metadata:
  author: tcxcx
  version: "1.1.0"
  language: es
  argument-hint: <ruta-o-PR-o-nombre-de-feature>
---

# Protocolo de Análisis Gateman

> "Assume Nothing, question everything, worship no one, and applaud humility."
> *"No asumas nada, cuestiona todo, no idolatres a nadie y aplaude la humildad."*
> — Robert Gateman, Economía, UBC

Un protocolo de auditoría post-implementación que trata cada línea de código nuevo — y cada línea producida por una IA — como un actor económico: racional hasta que se demuestre lo contrario, jamás confiable solo por su reputación. Ejecútalo **después** de escribir la función pero **antes** de desplegarla.

Esta skill lleva el nombre de un profesor de economía cuya visión de cuatro reglas sobrevive a la traducción desde la teoría de precios hacia el software y la IA: toda entrada es un desconocido, toda afirmación merece una repregunta, ninguna librería / framework / colega / modelo recibe un pase libre, y la jugada más inteligente es asumir que la sala está llena de gente tan brillante como tú.

## ¿Quién fue el profesor Gateman?

[![Robert Gateman — Humans of UBC: "Assume Nothing" (clic para abrir)](https://www.facebook.com/humansofubc/posts/assume-nothing-robert-gateman-economics-professor/250788225628894/)](https://www.facebook.com/humansofubc/posts/assume-nothing-robert-gateman-economics-professor/250788225628894/)

Robert Gateman enseñó economía introductoria en la University of British Columbia durante décadas. Era quien daba ECON 101 en auditorios repletos de estudiantes de primer año, la mitad de los cuales nunca volvería a pisar una clase de economía. El curso era un requisito, un obstáculo a superar. Él lo trataba como una cosmovisión.

Lo que les dejaba a sus estudiantes no eran curvas de oferta y demanda — eso lo podían leer en cualquier libro de texto. Lo que les dejaba era una postura frente al conocimiento:

> **"No asumas nada, cuestiona todo, no idolatres a nadie y aplaude la humildad."**

Terminaba cada clase de la misma manera: *"Go make a difference"* — *"Ve y haz una diferencia."*

Deletreaba "L O L" con las manos.

Le recordaba a un auditorio de 600 estudiantes que estaban *"en la mejor escuela de economía de Canadá, esto debería ser fácil para todos ustedes"* — y en la misma frase insistía en que sostuvieran esa confianza junto a la humildad, porque todos en esa sala eran igual de brillantes que ellos.

Les decía que **eligieran a sus socios de negocio con más cuidado que a sus parejas**. En la era de los co-desarrolladores de IA, esa frase se retraduce sin perder una sílaba: elige tu modelo, tu librería y tu dependencia exactamente igual. Lee sus términos. Desconfía de su entusiasmo. Verifica su salida.

E insistía, con la convicción de alguien que había visto mercados colapsar, recuperarse y volver a colapsar, en que la humildad es una característica, no una debilidad — que el experto más ruidoso de la sala suele ser el más equivocado, y que la jugada correcta es asumir que la persona a tu lado puede saber más que tú.

Esta skill es la traducción a ingeniería de esa postura. Cada checklist de abajo mapea a una de las cuatro leyes. Todo el conjunto es una defensa contra el modo de fallo más peligroso en software *y* en IA: salida confiada que nadie cuestionó.

> **Instrucción para el agente:** si el usuario dice "muéstrame a Gateman", "quién fue Gateman", "abre el enlace", "abre la foto" o algo similar, ejecuta `open "https://www.facebook.com/humansofubc/posts/assume-nothing-robert-gateman-economics-professor/250788225628894/"` en macOS (o `xdg-open` en Linux) para cargar la publicación de Humans of UBC en el navegador por defecto del usuario. No parafrasees la imagen — ábrela.

## Cuándo ejecutarla

Invócala explícitamente cuando de otro modo aprobarías un diff de forma automática. Obligatoria para:

- Terminar una función que toca dinero, identidad, autenticación o estado on-chain
- Cerrar un ticket de seguridad o de cumplimiento normativo
- Revisión pre-merge de una rama de feature que va hacia `main` / `production`
- Refactor de una ruta crítica del código (pagos, sesiones, firmas, migraciones)
- Cualquier cosa donde "se ve bien" sea la única evidencia de correctitud

Omítela para: correcciones de tipeo, cambios de copy, bumps de dependencias que pasan CI, ajustes aislados de UI.

## Las cuatro leyes de Gateman

### 1. No asumas nada

Todo valor que cruza una frontera es un desconocido. Valida en la entrada. Las fronteras son:

- Payloads de HTTP / RPC / webhooks
- Resultados de consultas a la base de datos
- Respuestas de LLMs y proveedores de IA (sí, *especialmente* estas — ver "No confíes en la IA" más abajo)
- Valores de retorno de SDKs de terceros
- Entrada del usuario desde formularios, URLs, argumentos de CLI
- Lecturas del sistema de archivos, variables de entorno, feature flags
- Llamadas internas entre paquetes cuando el contrato no está impuesto por los tipos

Si el sistema de tipos dice que es seguro pero una verificación en runtime no te cuesta nada, hazla igual. Los tipos son documentación; la validación es aplicación efectiva.

### 2. Cuestiona todo

Una firma de tipos es una afirmación. Un test que pasa es una afirmación. Un CI en verde es una afirmación. El score de confianza de un modelo es una afirmación. La pregunta siempre es la misma: *¿qué tendría que ser cierto para que esta afirmación fuera falsa, y ya lo verifiqué?*

Trata cada diff como una hipótesis. La auditoría es el experimento.

- ¿El cambio de código se comportó como dice el mensaje del commit?
- ¿El test realmente ejercitó el caso de fallo, o solo el camino feliz?
- ¿La explicación de la IA coincide con lo que el código realmente ejecuta?
- ¿La actualización de la dependencia cambió algún valor por defecto del que dependías?

Si no puedes nombrar el experimento que ejecutaste, no has cuestionado la afirmación.

### 3. No idolatres a nadie

Ningún nombre en el paquete, ninguna popularidad en GitHub, ninguna familiaridad con un colega, ninguna fluidez en la explicación de una IA exime al código del escrutinio. Léelo. Pruébalo. Desconfía de él.

Esto aplica con más fuerza a:

- Librerías que llevas años usando
- Código escrito por ingenieros senior
- Wrappers sobre servicios externos ("el SDK se encarga de eso")
- Tus propios commits anteriores
- Cualquier cosa etiquetada como "estable", "probada en batalla" o "estándar de la industria"
- **Salida de IA que suena correcta, especialmente cuando suena correcta en tu propia voz**

La pregunta de entrevista para cualquier dependencia: *¿qué hace esto si le paso basura, y qué hace si me devuelve basura?*

Para la IA en particular: *¿realmente ejecutó el código, o me está diciendo lo que el código probablemente hace?*

### 4. Aplaude la humildad

El experto más ruidoso de la sala suele ser el más equivocado. El modelo más grande no es el más preciso. El diff que se ve más limpio no es el más seguro.

Premia — en ti, en tus colegas y en el modelo — la jugada que dice *"no estoy seguro, déjame verificar"*. Penaliza — en ti, en tus colegas y en el modelo — la jugada que dice *"esto está bien"* sin evidencia.

En la práctica, esto significa:

- Prefiere "ejecuté X y observé Y" sobre "creo que esto debería funcionar".
- Prefiere un arreglo pequeño con test sobre un arreglo grande sin test.
- Prefiere la IA que hace una pregunta aclaratoria sobre la IA que rellena un supuesto con confianza.
- Prefiere al colega que señala un riesgo sobre el colega que promete que todo está bien.
- Prefiere tu propia incertidumbre, dicha en voz alta, sobre una sensación confiada.

La humildad es la defensa contra el modo de fallo más caro en software *y* en IA: una respuesta confiada que nadie cuestionó.

## No confíes en la IA

Gateman nunca habría confiado en ella. Tú tampoco deberías.

Este es el principio que hace que esta skill importe en 2026. Programar con asistencia de LLMs convierte "No asumas nada" de una nota estilística en una regla de supervivencia, porque la IA está haciendo cuatro cosas a la vez:

1. **Sonar correcta** en la voz del usuario, lo que silencia las alarmas que dispararía un tono desconocido.
2. **Producir código sintácticamente válido** que pasa las verificaciones más baratas (formateador, chequeo de tipos, "¿compila?").
3. **Citar cosas que no existen** — funciones, parámetros, paquetes, errores, endpoints de API, IDs de modelos.
4. **Afirmar que está completo** cuando solo cubrió el camino feliz.

Esta es la superficie de alucinación de manual. Las cuatro leyes de Gateman mapean directamente sobre ella:

| Ley                 | Equivalente en IA                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| No asumas nada      | La salida de la IA es la respuesta de una API externa. Valida su forma, sus citas, sus supuestas ediciones de archivos.                     |
| Cuestiona todo      | "¿Realmente ejecutó el código o solo lo describió?" "¿Ese import existe?" "¿El test que escribió llegó a fallar antes del arreglo?"          |
| No idolatres a nadie | Un modelo más grande no es un modelo más correcto. La marca en la API key no exime a la respuesta de la revisión.                          |
| Aplaude la humildad | Confía en la IA que dice "no estoy seguro, déjame revisar el archivo" antes que en la IA que acierta de una con una respuesta confiada y falsa. |

**Defensas concretas contra la alucinación de la IA** (aplica todas y cada una en diffs escritos por IA):

- [ ] Cada función / import / API que la IA nombró existe realmente en el codebase o en la versión documentada de la dependencia
- [ ] Cada archivo que la IA dice haber editado fue releído para confirmar que la edición se aplicó tal como fue descrita
- [ ] Cada test que la IA escribió fue observado fallando sobre el código original antes del arreglo
- [ ] Cada llamada externa que la IA agregó tiene una verificación de forma en runtime sobre la respuesta (no solo un tipo)
- [ ] Cada flag, variable de entorno o config que la IA sugirió fue confirmada como existente (no asumida por el modelo)
- [ ] Cada afirmación de tipo "esto está bien, no hacen falta cambios en otro lado" fue verificada con grep, no con fe
- [ ] Cada enlace, URL, ID de modelo o número de versión que la IA emitió fue contrastado contra la fuente viva

**NO CONFÍES EN LA IA.** Eso no es un eslogan; es un flujo de trabajo. La IA es la frontera más útil, más confiada y más cargada de supuestos de tu stack. Trata su salida como un webhook de un proveedor que nunca conociste.

## Checklist de verificación

Recorre el checklist en orden. Trata cada casilla sin marcar como un bloqueante hasta que escribas la justificación o el arreglo. Un honesto "N/A — aquí no hay entrada externa" es aceptable; saltárselo en silencio no lo es.

### Sección 1 — Validación de entradas (No asumas nada)

```typescript
// MAL — Asume la forma que el tipo dice tener
const userName = data.user.name;

// BIEN — Valida en la frontera, falla ruidosamente
if (!data?.user?.name || typeof data.user.name !== "string") {
  throw new ValidationError("Invalid user response shape");
}
const userName = data.user.name;
```

Preguntas:

- [ ] Cada parámetro de función en una frontera está validado (no solo tipado)
- [ ] Cada respuesta de API / RPC / webhook está validada antes de usarse
- [ ] Las entradas del usuario están saneadas (límites de longitud, bytes nulos eliminados, caracteres de control rechazados)
- [ ] Los campos opcionales tienen valores por defecto o ramas explícitas, sin `undefined` implícito
- [ ] Los valores numéricos tienen verificaciones de rango explícitas (sin sorpresas con `Number.MAX_SAFE_INTEGER`)
- [ ] Los strings que se convierten en identificadores (slugs, IDs) pasan por una regex de lista blanca

### Sección 2 — Identificadores externos (No idolatres a nadie)

Los IDs externos (IDs de cliente de Stripe, UUIDs de terceros, subjects de OAuth, direcciones de blockchain) **no** son claves primarias en tu sistema. Identifican entidades en el sistema de otra persona.

```typescript
// MAL — Trata un ID externo como si fuera tu propio ID de usuario
const rows = await db.from("payments").where({ customer_id: userId });

// BIEN — Resuelve el ID externo explícitamente, nombra su origen
const user = await getUserById(userId);
const externalCustomerId = user.stripe_customer_id; // ID del sistema externo
const rows = await db.from("payments").where({ customer_id: externalCustomerId });
```

Preguntas:

- [ ] Cada ID externo está nombrado de forma que su origen sea evidente
- [ ] Ningún ID externo se usa como destino de una restricción de clave foránea
- [ ] El mapeo de ID interno → ID externo está centralizado (un único helper de consulta)
- [ ] Las políticas de seguridad a nivel de fila no permiten silenciosamente lecturas entre tenants
- [ ] Las credenciales de servicio / admin están acotadas a las operaciones que las requieren

### Sección 3 — Canales laterales y superficie de fraude

Toda operación que mueve dinero, emite credenciales u otorga acceso tiene una contraparte adversaria. Defiende antes de entregar valor.

```typescript
// MAL — Sin defensa contra replay, auto-beneficio o ciclos
async function awardReferral(userId, partnerId) {
  await createAttribution(userId, partnerId);
}

// BIEN — Verificaciones apiladas antes del cambio de estado
async function awardReferral(userId, partnerId, ip) {
  if (userId === partnerId) throw new FraudError("Self-referral");
  if (await ipAlreadyConverted(ip, partnerId)) throw new FraudError("IP reuse");
  if (await wouldCreateCycle(userId, partnerId)) throw new FraudError("Cycle");
  if (!await isWithinValidWindow(userId)) throw new FraudError("Window expired");
  await createAttribution(userId, partnerId);
}
```

Preguntas:

- [ ] Límite de tasa (rate limiting) en cada endpoint que cambia estado
- [ ] Verificaciones de auto-acción donde corresponda (auto-referido, auto-aprobación, auto-pago)
- [ ] Verificaciones de ciclos / recorrido de grafo donde los datos formen relaciones
- [ ] Seguimiento de IP / dispositivo / huella digital en rutas sensibles a atribución
- [ ] Las operaciones financieras son reversibles (soportan reembolso, contracargo, recuperación)
- [ ] Los manejadores de reversión se actualizan cada vez que se agrega una nueva ruta de creación de valor

### Sección 4 — Configuración vs. valores hardcodeados

Las constantes que cambian entre entornos (chain IDs, direcciones de contratos, tramos de comisión, códigos de país) pertenecen a un único módulo de configuración y a ningún otro lugar. Dos copias van a divergir.

```typescript
// MAL — Lista de chains hardcodeada, se va a pudrir
const chains = ["avalanche", "polygon", "base"];

// BIEN — Única fuente de verdad, validada
import { getSupportedChains, isSupportedChain } from "@/config/chains";

const chains = getSupportedChains();
if (!isSupportedChain(chainId)) throw new Error(`Unsupported chain: ${chainId}`);
```

Preguntas:

- [ ] Sin chain IDs, direcciones de contrato, nombres de red ni tasas de comisión hardcodeados
- [ ] Testnet vs. mainnet se resuelve por configuración, no por rama del código
- [ ] El mapeo de nombres internos a nombres de proveedor (p. ej. enums de proveedor de pagos / KYC / chain) está centralizado
- [ ] Los valores que vienen de variables de entorno tienen un default que falla ruidosamente si la variable falta
- [ ] Los números mágicos (`30`, `500`, `0.01`) son constantes con nombre y un comentario cuando no son obvios

### Sección 5 — Dinero, tiempo y reversibilidad

Todo lo denominado en dinero o en tiempo necesita tratamiento explícito. Sin flotantes, sin zonas horarias implícitas, sin escrituras irreversibles.

```typescript
const PAYOUT_RULES = {
  holdPeriodDays: 30,           // protege ante un reembolso dentro de la ventana
  minimumPayoutAmount: 50,      // evita drenajes por ataques de polvo (dust)
  manualReviewThreshold: 500,   // montos mayores requieren aprobación humana
  maxRequestsPerDay: 3,         // limita la tasa de abuso
  reversalReasons: ["refund", "dispute", "chargeback", "cancelled"] as const,
  auditAllChanges: true,
} as const;
```

Preguntas:

- [ ] Los montos son enteros en la unidad más pequeña (centavos, wei) — nunca flotantes
- [ ] El código de moneda viaja con cada monto; sin asumir USD implícitamente
- [ ] Las marcas de tiempo se almacenan en UTC y se renderizan según el locale; nada de "hora local del servidor"
- [ ] Los períodos de retención, enfriamientos y ventanas son configurables, no están inline
- [ ] Los webhooks del proveedor para reembolso / disputa / contracargo están manejados, no solo el de éxito
- [ ] Cada transición de estado que mueve valor escribe una entrada en el log de auditoría

### Sección 6 — Modos de fallo

El camino infeliz es el camino que despliegas. Recórrelo.

Preguntas:

- [ ] Cada `try` tiene un `catch` que hace algo (registrar, reintentar, exponer, compensar)
- [ ] Los bloques `catch {}` vacíos tienen un comentario de una línea justificando el silencio
- [ ] Los reintentos tienen backoff y un límite superior; sin bucles infinitos
- [ ] Timeouts en cada llamada de red saliente
- [ ] Las rutas de fallo parcial (la escritura en A funcionó, la de B falló) tienen un reconciliador explícito
- [ ] Claves de idempotencia en cada POST que cuesta dinero o genera estado
- [ ] Las transacciones de base de datos envuelven los cambios de estado de múltiples filas

### Sección 7 — Observabilidad

Si se rompe a las 3 de la madrugada y no puedes saber qué pasó, la función está incompleta.

Preguntas:

- [ ] Logs estructurados (JSON, clave-valor) — no `console.log("done")` en texto libre
- [ ] Un ID de correlación (request ID, trace ID) fluye por cada línea de log de la petición
- [ ] La PII está redactada en los logs (correos enmascarados, tokens completos jamás registrados)
- [ ] Se registra la duración de cada llamada externa
- [ ] Se emite una métrica / contador por cada reintento, fallback o ruta degradada
- [ ] La clase de error es distinguible entre fallos de validación, de red e internos

### Sección 8 — Verificación de la salida de la IA (No confíes en la IA)

El diff que tienes delante fue escrito, al menos en parte, por un modelo de lenguaje. Aplica las defensas específicas de IA de la sección "No confíes en la IA", con una regla extra: cuando la confianza de la IA y tu evidencia estén en desacuerdo, gana la evidencia.

Preguntas:

- [ ] Relee cada archivo que la IA dice haber editado (la edición se aplicó como fue descrita, no se cambió nada extra)
- [ ] Haz grep de cada función / import / módulo que la IA nombró (existe en esa ruta, con esa firma)
- [ ] Ejecuta cada test que la IA escribió, *primero* contra el código roto (falla) y *después* contra el arreglo (pasa)
- [ ] Verifica cada URL, número de versión, ID de modelo y flag de CLI contra la fuente viva
- [ ] Cuando la IA diga "no hacen falta cambios en otro lado", confírmalo con grep — no con confianza
- [ ] Cuando la IA diga "esta es la forma estándar", confírmalo contra la documentación real de la versión real que usas
- [ ] Cuando la IA suene especialmente confiada, trátalo como una señal para verificar más, no menos

## Tarjeta de puntuación de calidad de código

Puntúa el código modificado de 0 a 10 por categoría, con una justificación de una línea. Cualquier valor menor a 6 es un bloqueante.

| Categoría              | Puntaje | Notas |
| ---------------------- | ------- | ----- |
| Manejo de errores      |         | ¿Clases de error distintas? ¿Catches con intención? |
| Logging                |         | ¿Estructurado? ¿Correlacionado? ¿Seguro frente a PII? |
| Seguridad de tipos     |         | ¿Algún `any`? ¿Casts sin verificar en las fronteras? |
| Testeabilidad          |         | ¿Funciones puras extraídas? ¿Frontera mockeable? |
| Rendimiento            |         | ¿Consultas N+1? ¿Síncrono dentro de un bucle? ¿Backoff en los reintentos? |
| Seguridad              |         | ¿Entrada validada? ¿AuthZ en cada entrada? ¿Secretos bien manejados? |
| Verificación de la IA  |         | ¿Cada edición declarada por la IA fue releída? ¿Cada símbolo citado fue verificado? ¿Cada "no hacen falta cambios" confirmado con grep? |

## Cubos de mejora continua

Después de puntuar, elige la mejora de mayor apalancamiento. Seis cubos recurrentes — la mayoría de las auditorías destapan uno o dos:

### P1 — Cobertura de tests en helpers de frontera

Busca: nuevos validadores, wrappers de reintento, parsers, normalizadores. Son los lugares más baratos y más catastróficos donde saltarse los tests. Apunta a al menos un test de camino feliz por rama (`devuelve en 2xx`, `reintenta en 5xx hasta N`, `lanza error con entrada inválida`, `hace timeout a los T ms`).

### P2 — Seguridad de tipos

Busca `as any`, `// @ts-ignore` y casts sin verificar. Cada uno es un bug latente en runtime. Donde la forma dinámica sea inevitable (APIs externas, nombres de tabla dinámicos), envuélvelo con una función `parse()` tipada en lugar de esparcir el cast entre los llamadores.

### P3 — Logging estructurado

Reemplaza `console.log` por un logger que emita JSON, acepte un objeto de contexto, incluya un ID de correlación y redacte los campos de PII conocidos. Agrega `durationMs` a cada entrada alrededor de una llamada externa.

### P4 — Patrones de resiliencia

Agrega: circuit breaker en servicios que fallan en ráfagas, dead-letter queue para flujos de éxito parcial, claves de idempotencia en los POST que mutan estado, reintentos con backoff exponencial (1s, 2s, 4s, tope en 30s).

### P5 — Extraer wrappers repetidos de HTTP / SDK

Cuando dos servicios tengan métodos privados `fetchWithRetry`, extráelos a un cliente compartido. Cuando los strings de códigos de error aparezcan en tres archivos, centralízalos en un módulo de constantes. Dos duplicados son una advertencia; tres son un refactor.

### P6 — Endurecimiento de seguridad

Agrega límite de tasa a cualquier endpoint que acepte entrada externa. Agrega middleware de saneamiento de entradas. Audita cada consulta SQL nueva por su vinculación de parámetros (sin concatenación de strings). Confirma que ningún secreto aparezca en ninguna línea de log, mensaje de error o cuerpo de respuesta.

## Señales de alerta

Si alguna de estas aparece en un diff, detente y escribe una justificación antes de continuar.

**Olores de código:**

- Tipos `any` sin comentario
- Bloques `catch {}` vacíos
- Constantes hardcodeadas que varían según el entorno
- `process.env.X` leído en el fondo de la lógica de negocio (léelo una vez en el borde y pásalo como valor)
- Construcción directa del cliente de base de datos dentro de un manejador de peticiones (usa un cliente compartido)

**Olores de seguridad:**

- IDs externos usados como claves foráneas
- Verificaciones de autorización que comparan strings sin canonicalizar
- Registrar el cuerpo completo de un webhook entrante (así se filtran firmas y tokens)
- Meter entrada del usuario en un string SQL con template literals
- Un endpoint de admin nuevo sin límite de tasa

**Olores de dinero:**

- Aritmética de punto flotante sobre moneda
- Falta el código de moneda en una columna o campo de monto
- Un manejador de pago exitoso sin su correspondiente manejador de reembolso
- Una ruta de creación de valor sin escritura en el log de auditoría

## Plantilla del informe de verificación

Termina cada pasada de Gateman con un veredicto escrito. El informe es el entregable, no la auditoría en sí.

```markdown
## Informe de Verificación Gateman

**Feature:** <nombre>
**Rama / PR:** <ref>
**Fecha:** <AAAA-MM-DD>
**Verificador:** <agente o humano>

### Puntaje

| Categoría          | Puntaje | Nota |
| ------------------ | ------- | ---- |
| Manejo de errores  |         |      |
| Logging            |         |      |
| Seguridad de tipos |         |      |
| Testeabilidad      |         |      |
| Rendimiento        |         |      |
| Seguridad          |         |      |

### Verificaciones superadas
- [x] ...

### Verificaciones fallidas
- [ ] ...

### Próximos pasos recomendados
1. ...
2. ...

### Nivel de riesgo
BAJO | MEDIO | ALTO | CRÍTICO

### Firma
Seguro para desplegar: SÍ | NO | SÍ_CON_SEGUIMIENTOS
```

## Cómo debe ejecutar un agente esta skill

1. Lee el diff o el alcance que el usuario nombró (rutas de archivos, PR, nombre de la feature).
2. Recorre las secciones 1–7 en orden. Para cada sección, nombra las líneas específicas que la satisfacen o la violan. Ninguna sección puede omitirse en silencio.
3. Llena la tarjeta de puntuación con justificaciones concretas. Un puntaje solo es válido con una razón de una línea.
4. Elige el único cubo P1–P6 de mayor apalancamiento como próximo paso recomendado.
5. Escribe el informe. Incluye el nivel de riesgo. Declara si el cambio es seguro para desplegar.
6. Si el veredicto es **NO** o **CRÍTICO**, nombra el arreglo más pequeño posible que cambiaría el veredicto.

## Lo que esta skill NO es

- **No** sustituye a los tests, chequeos de tipos ni linters. Ejecuta esos primero; Gateman audita lo que ellos no pueden ver.
- **No** es una revisión de arquitectura. Para "¿deberíamos construir esto siquiera?", usa una skill de planificación o de revisión de alcance antes de escribir código.
- **No** es una alternativa al modelado de amenazas en sistemas de producción críticos en seguridad. Los modelos de amenazas van aguas arriba; Gateman va aguas abajo de la implementación.
- **No** es automática. El protocolo es una rúbrica para humano-o-agente, no un gate de CI. El agente debe leer código y escribir justificaciones.
- **No** es un chequeo de vibras. Las vibras son exactamente lo que esta skill existe para derribar.

## Apéndice — Los grandes éxitos de Gateman

Frases registradas por sus estudiantes. Úsalas como calcomanías de las cuatro leyes. Abre las referencias al final del archivo para leer los originales.

> **"Go make a difference."** — *"Ve y haz una diferencia."*
> Dicho al final de cada clase. El trabajo es el artefacto. Despliega algo que importe.

> **"Assume nothing, question everything, worship no one, and applaud humility."**
> *"No asumas nada, cuestiona todo, no idolatres a nadie y aplaude la humildad."*
> El enunciado completo de las cuatro leyes. El resto de esta skill es una gran nota al pie de esta frase.

> **"L O L."**
> Deletreado con las manos, en plena clase. Internet es un país extranjero. Trae tu propio significado.

> **"You're all students at the best economics school in Canada, this should be easy for all of you."**
> *"Todos ustedes son estudiantes de la mejor escuela de economía de Canadá, esto debería ser fácil para todos."*
> Y luego, en la siguiente frase: *sé humilde, porque todos en esta sala son tan brillantes como tú.* La confianza y la humildad no son opuestos; se apilan.

> **"Choose your partner wisely, but choose your business partner even more wisely."**
> *"Elige a tu pareja con sabiduría, pero elige a tu socio de negocios con aún más sabiduría."*
> En 2026, tu socio de negocios también es tu modelo, tu librería y tu dependencia. Lee los términos de servicio. Prueba el modo de fallo. Desconfía del entusiasmo. El patrón de la relación importa más que el magnetismo de la primera conversación.

> **"You attend the best school in the best city in the best country in the world. Be confident in your ability but approach everything with a heavy sense of humility because everyone here is just as intelligent as you. Assume nothing."**
> *"Asistes a la mejor escuela, en la mejor ciudad, del mejor país del mundo. Ten confianza en tu capacidad, pero acércate a todo con un fuerte sentido de humildad, porque todos aquí son tan inteligentes como tú. No asumas nada."*
> La IA no cambia esto; lo afila. La IA es un terreno de juego nivelado. Construye con humildad. No asumas nada. No idolatres a nadie — *especialmente a los dioses de la IA*.

### Pista extra — Oferta y demanda, al ritmo de los Stones

Se cuenta que Gateman enseñaba *oferta y demanda* con "(I Can't Get No) Satisfaction" sonando lo bastante fuerte como para hacer vibrar el auditorio. El mercado se equilibra donde ya no puedes conseguir más de lo que quieres al precio que quieres. La canción es la curva.

> *"I can't get NO… SA-TIS-FAC-TION."*

Si tu asistente de IA te lleva el 80% del camino y se atasca, eso es la curva de demanda chocando con la de oferta. No consigues satisfacción gritando más fuerte; la consigues **cambiando el precio que estás dispuesto a pagar** — en atención, en verificación, en releer el diff. El mercado se equilibra cuando pones el trabajo que el modelo no puede poner.

## Referencias

- **Humans of UBC** — "Assume Nothing: Robert Gateman, Economics Professor."
  https://www.facebook.com/humansofubc/posts/assume-nothing-robert-gateman-economics-professor/250788225628894/
  *Ábrelo desde la línea de comandos de macOS con* `open <url>` *cuando te pidan "la foto" o "quién fue Gateman".*

- **r/UBC** — "Motivational Gateman quotes."
  https://www.reddit.com/r/UBC/comments/6lb7al/motivational_gateman_quotes/
  *Fuente de "Go make a difference", "L O L", la frase del socio de negocios y el enunciado de las cuatro leyes.*

- **UBC Blogs (Kiely, 2011)** — "Gateman's Econ 101."
  https://blogs.ubc.ca/kiely/2011/11/27/gatemans-econ-101/
  *Fuente del pasaje "mejor escuela / mejor ciudad / mejor país" y del encuadre que pone la humildad primero.*

## Licencia

Esta skill se publica bajo la licencia MIT — ver el archivo `LICENSE` hermano.
La licencia lleva un anexo de dedicatoria en honor al **profesor Robert Gateman, Economía, UBC**.

## Tuum Est — Es Tuyo

El lema de la University of British Columbia es **"Tuum Est."**

Latín. *Es tuyo.*

Al principio no lo entiendes. En realidad nadie lo entiende. La placa es sosa, la traducción es plana, y pasas cuatro años caminando junto a ella camino a clase. Pero no es un eslogan — es una transferencia de peso.

Tu destino está en tus manos. Tu libertad está en tus manos. Tu fortuna está en tus manos. Tu muerte está en tus manos. El mundo está en tus manos porque *tú eres Atlas Shrugged* — el encogimiento de hombros no es un rechazo, es la carga. La cargas tú, o no la carga nadie.

Esta es la ley que cierra las cuatro. Las cuatro leyes de Gateman disciplinan lo que dejas entrar. **Tuum Est** disciplina lo que dejas salir.

- La auditoría es tuya.
- El diff es tuyo.
- La alucinación — si la despliegas — es tuya.
- El cliente que sale perjudicado porque te saltaste la verificación — es tuyo.
- El colega que hereda el bug silencioso a las 3 de la madrugada — es tuyo.
- La línea de código que escribió la IA y que tú no leíste — es tuya.

No hay nadie a quien culpar aguas arriba. El modelo es una herramienta. La librería es una herramienta. El colega es un socio, no un escudo. Una vez que tu nombre está en el commit de merge, el peso es tuyo.

No idolatres a nadie. **Ni siquiera a ti mismo.** *Especialmente* no a ti mismo. Todo el sentido de poner la humildad por encima de las cuatro leyes es impedir que, en silencio, te conviertas a ti mismo en la excepción. La versión de ti que está cansada, segura, apurada — esa versión es el revisor más peligroso de tu propio trabajo. Tuum Est significa que *los errores de esa versión también son tuyos.*

> *No idolatres a nadie. Ni siquiera a ti mismo. Humildad. No asumas nada. Tuum Est.*

Aquí termina la skill y empieza el trabajo. Cierra el archivo. Abre el diff. Carga el peso.

---

**Recuerda.** No asumas nada. Cuestiona todo. No idolatres a nadie. Aplaude la humildad. No confíes en la IA. **Tuum Est.** *Y entonces* despliega.
