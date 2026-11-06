---
name: workflow
description: Creates durable, resumable workflows using Vercel's Workflow SDK. Use when building workflows that need to survive restarts, pause for external events, retry on failure, or coordinate multi-step operations over time. Triggers on mentions of "workflow", "durable functions", "resumable", "workflow sdk", "queue", "event", "push", "subscribe", or step-based orchestration.
metadata:
  author: Vercel Inc.
  version: '1.19'
---

## *Critical*: Always use correct `workflow` documentation

Your knowledge of `workflow` is outdated.

The `workflow` documentation outlined below matches the installed version of the Workflow SDK.
Follow these instructions before starting on any `workflow`-related tasks:

Search the bundled documentation in `node_modules/workflow/docs/`:

1. **Find docs**: `glob "node_modules/workflow/docs/**/*.mdx"`
2. **Search content**: `grep "your query" node_modules/workflow/docs/`

Documentation structure in `node_modules/workflow/docs/`:

- `getting-started/` - Framework setup (next.mdx, express.mdx, hono.mdx, etc.)
- `foundations/` - Core concepts (workflows-and-steps.mdx, hooks.mdx, streaming.mdx, etc.)
- `api-reference/workflow/` - API docs (sleep.mdx, create-hook.mdx, fatal-error.mdx, etc.)
- `api-reference/workflow-api/` - Client API (start.mdx, get-run.mdx, resume-hook.mdx, etc.)
- `api-reference/workflow-runtime/` - Runtime API (get-world.mdx) and `world/` World SDK (storage.mdx, streams.mdx, queue.mdx)
- `api-reference/workflow-observability/` - Hydration and name parsing utilities (hydrate-resource-io.mdx, parse-workflow-name.mdx, etc.)
- `ai/`: AI SDK integration docs
- `errors/` - Error code documentation
- `worlds/` - Per-World behavior and limits (vercel.mdx, local.mdx, postgres.mdx). Other pages link these as `/worlds/<name>`.

Related packages also include bundled docs:

- `@ai-sdk/workflow`: `node_modules/ai/docs/` - WorkflowAgent and AI SDK integration
- `@workflow/ai`: `node_modules/@workflow/ai/docs/` - deprecated DurableAgent APIs for existing applications
- `@workflow/core`: `node_modules/@workflow/core/docs/` - Core runtime (foundations, how-it-works)
- `@workflow/next`: `node_modules/@workflow/next/docs/` - Next.js integration

**When in doubt, update to the latest version of the Workflow SDK.**

### Official resources

- **Website**: https://workflow-sdk.dev
- **GitHub**: https://github.com/vercel/workflow

### Quick reference

**Directives:**

```typescript
"use workflow";  // First line - makes async function durable
"use step";      // First line - makes function a cached, retryable unit
```

**Essential imports:**

```typescript
// Workflow primitives
import { sleep, fetch, createHook, createWebhook, getWritable } from "workflow";
import { FatalError, RetryableError } from "workflow";
import { getWorkflowMetadata, getStepMetadata } from "workflow";

// API operations
import { start, getRun, resumeHook, resumeWebhook } from "workflow/api";

// Observability & data hydration
import { hydrateResourceIO, observabilityRevivers, parseStepName, parseWorkflowName } from "workflow/observability";

// Framework integrations
import { withWorkflow } from "workflow/next";
import { workflow } from "workflow/vite";
import { workflow } from "workflow/astro";
// Or use modules: ["workflow/nitro"] for Nitro/Nuxt

// AI agent (Workflow 5)
import { WorkflowAgent, type ModelCallStreamPart } from "@ai-sdk/workflow";
```

## Prefer step functions to avoid sandbox errors

`"use workflow"` functions run in a sandboxed VM. `"use step"` functions have **full Node.js access**. Put your logic in steps and use the workflow function purely for orchestration.

```typescript
// Steps have full Node.js and npm access
async function fetchUserData(userId: string) {
  "use step";
  const response = await fetch(`https://api.example.com/users/${userId}`);
  return response.json();
}

async function processWithAI(data: any) {
  "use step";
  // AI SDK works in steps without workarounds
  return await generateText({
    model: "spacexai/grok-4.6",
    prompt: `Process: ${JSON.stringify(data)}`,
  });
}

// Workflow orchestrates steps - no sandbox issues
export async function dataProcessingWorkflow(userId: string) {
  "use workflow";
  const data = await fetchUserData(userId);
  const processed = await processWithAI(data);
  return { success: true, processed };
}
```

**Benefits:** Steps have automatic retry, results are persisted for replay, and no sandbox restrictions.

## Workflow sandbox limitations

When you need logic directly in a workflow function (not in a step), these restrictions apply:

| Limitation | Workaround |
|------------|------------|
| No `fetch()` | Make the request (and AI SDK calls) in a step function |
| No `setTimeout`/`setInterval` | Use `sleep("5s")` from `"workflow"` |
| No Node.js modules (fs, crypto, etc.) | Move to a step function |

**Example - AI SDK call in a workflow:**

```typescript
import { generateText } from "ai";

async function summarize(text: string) {
  "use step";
  const { text: summary } = await generateText({
    model: "spacexai/grok-4.6",
    prompt: `Summarize: ${text}`,
  });
  return summary;
}

export async function myWorkflow(text: string) {
  "use workflow";
  return await summarize(text);
}
```

For agents, use `WorkflowAgent` (below).

**Note:** Plain `"provider/model"` strings use Vercel AI Gateway. Do not construct a direct provider instance unless the user explicitly needs a provider-only feature.

## WorkflowAgent: AI agents in Workflow 5

Use AI SDK's `WorkflowAgent` for durable agents on Workflow 5. It replaces the deprecated `DurableAgent` API from `@workflow/ai` and checkpoints model calls and step-backed tools.

```typescript
import { WorkflowAgent, type ModelCallStreamPart } from "@ai-sdk/workflow";
import { isStepCount, tool } from "ai";
import { getWritable } from "workflow";
import { z } from "zod";

async function lookupData({ query }: { query: string }) {
  "use step";
  // Step functions have full Node.js access
  return `Results for "${query}"`;
}

export async function myAgentWorkflow(userMessage: string) {
  "use workflow";

  const agent = new WorkflowAgent({
    model: "spacexai/grok-4.6",
    instructions: "You are a helpful assistant.",
    tools: {
      lookupData: tool({
        description: "Search for information",
        inputSchema: z.object({ query: z.string() }),
        execute: lookupData,
      }),
    },
  });

  const result = await agent.stream({
    messages: [{ role: "user", content: userMessage }],
    writable: getWritable<ModelCallStreamPart>(),
    stopWhen: isStepCount(10),
  });

  return result.messages;
}
```

**Key points:**
- A plain `"provider/model"` string routes through Vercel AI Gateway; `spacexai/grok-4.6` is the default model in Workflow examples
- `getWritable<ModelCallStreamPart>()` streams durable model-call output; convert it with `createModelCallToUIChunkTransform()` in an HTTP route
- Tool `execute` functions that need Node.js/npm access should use `"use step"`
- Tool `execute` functions that use workflow primitives (`sleep()`, `createHook()`) should **NOT** use `"use step"` because they run at the workflow level
- `stopWhen` limits the number of model calls; the default is to stop when the model stops calling tools
- Multi-turn: pass `result.messages` plus new user messages to subsequent `agent.stream()` calls

**For more details, check the WorkflowAgent docs in the installed AI SDK package or at https://ai-sdk.dev/v7/docs/agents/workflow-agent.**

## Starting workflows & child workflows

Use `start()` to launch workflows from API routes. In Workflow 5, `start()` can also be called directly from a workflow function to spawn a child run; it is step-backed and records a deterministic boundary in the parent's event log.

```typescript
import { start } from "workflow/api";

// From an API route; works directly
export async function POST() {
  const run = await start(myWorkflow, [arg1, arg2]);
  return Response.json({ runId: run.runId });
}

// No-args workflow
const run = await start(noArgWorkflow);
```

**Starting child workflows from inside a Workflow 5 workflow:**

```typescript
import { start } from "workflow/api";

export async function parentWorkflow() {
  "use workflow";
  const childRun = await start(childWorkflow, ["some data"]);
  await sleep("1h");
  return { childRunId: childRun.runId };
}
```

`start()` returns after creating the child run and doesn't wait for it to complete. Use `await childRun.returnValue` when the parent should wait for the child: the parent suspends on a system hook the child resumes when it finishes, so it does not poll and holds no worker while waiting. Don't hand-roll a completion hook for this. Other `Run` property accesses and method calls inside a workflow are steps.

## Run size & concurrency: know when to split

Three things to size, and all three are capped. Do NOT treat any number you remember as authoritative — the current values are published under [Workflow run limits](https://vercel.com/docs/workflows/pricing#workflow-run-limits), which is the only source to quote.

**Events per run.** A run's event log is capped, and the run fails with `MAX_EVENTS_EXCEEDED` past the ceiling. Events are not steps: a step that succeeds on the first try records three (`step_created`, `step_started`, `step_completed`), a retry records one or two more, and hooks, sleeps, and webhooks each record their own. Split into child workflows well before the ceiling — the pricing page recommends that past **a few thousand events**, because replay slows down long before the run fails.

**Steps per run.** Capped separately from events, so a long sequential chain *is* bounded even though it stays narrow. Bundle several items into one step when a chain would otherwise reach five figures.

**Concurrency.** A wide fan-out is throttled rather than rejected: event creation is rate-limited per run per second, so a flat `Promise.all` over a few thousand items spends much of its time backing off. Batch or bundle instead — process the list in chunks, or handle several items per step, so fewer and larger units run concurrently. Spawning one child run per item does not by itself narrow the fan-out; it bounds each child's log and isolates failures, which is worth doing for those reasons, but it is not a substitute for chunking.

You cannot raise any of these yourself — `WORKFLOW_MAX_EVENTS_OVERRIDE` only clamps *down*, and on the Vercel World the ceilings are service-owned — but Vercel raises the per-run event and step limits on request, so a genuinely large run is a support question as well as a design one.

```typescript
const BATCH = 100;

async function processItem(item: string) {
  "use step";
  return item.toUpperCase();
}

// One step per item, all in flight at once, all in one log
export async function processAll(items: string[]) {
  "use workflow";
  await Promise.all(items.map((item) => processItem(item)));
}

// Chunked, so only BATCH steps are in flight at a time
export async function processBatched(items: string[]) {
  "use workflow";
  for (let i = 0; i < items.length; i += BATCH) {
    await Promise.allSettled(items.slice(i, i + BATCH).map((item) => processItem(item)));
  }
}

// Bundled, so one step covers many items and the log stays short
async function processChunk(chunk: string[]) {
  "use step";
  return chunk.map((item) => item.toUpperCase());
}

export async function processBundled(items: string[]) {
  "use workflow";
  for (let i = 0; i < items.length; i += BATCH) {
    await processChunk(items.slice(i, i + BATCH));
  }
}
```

`processAll` is the shape to avoid at scale. `processBatched` bounds concurrency but still records events for every item. `processBundled` bounds both, because one step covers `BATCH` items — that is the only one of the three whose event count shrinks as `BATCH` grows.

## Hooks: pause & resume with external events

Hooks let workflows wait for external data. Use `createHook()` inside a workflow and `resumeHook()` from API routes. Deterministic tokens are for `createHook()` + `resumeHook()` (server-side) only. `createWebhook()` always generates random tokens, so do not pass a `token` option to `createWebhook()`.

### Single event

```typescript
import { createHook } from "workflow";

export async function approvalWorkflow() {
  "use workflow";

  const hook = createHook<{ approved: boolean }>({
    token: "approval-123",  // deterministic token for external systems
  });

  const result = await hook;  // Workflow suspends here
  return result.approved;
}
```

### Multiple events (iterable hooks)

Hooks implement `AsyncIterable`. Use `for await...of` to receive multiple events:

```typescript
import { createHook } from "workflow";

export async function chatWorkflow(channelId: string) {
  "use workflow";

  const hook = createHook<{ text: string; done?: boolean }>({
    token: `chat-${channelId}`,
  });

  for await (const event of hook) {
    await processMessage(event.text);
    if (event.done) break;
  }
}
```

Each `resumeHook(token, payload)` call delivers the next value to the loop.

### Resuming from API routes

```typescript
import { resumeHook } from "workflow/api";

export async function POST(req: Request) {
  const { token, data } = await req.json();
  await resumeHook(token, data);
  return new Response("ok");
}
```

## Error handling

Use `FatalError` for permanent failures (no retry), `RetryableError` for transient failures:

```typescript
import { FatalError, RetryableError } from "workflow";

if (res.status === 429) {
  throw new RetryableError("Rate limited", { retryAfter: "5m" });
}
if (res.status >= 400 && res.status < 500) {
  throw new FatalError(`Client error: ${res.status}`);
}
```

## Serialization

All data passed to/from workflows and steps must be serializable.

**Supported built-in types:** string, number, boolean, null, undefined, bigint, plain objects, arrays, Date, RegExp, URL, URLSearchParams, Map, Set, Headers, ArrayBuffer, typed arrays, Request, Response, ReadableStream, WritableStream.

**Not supported:** Functions, Symbols, WeakMap/WeakSet. Pass data, not callbacks.

### Custom class serialization

Class instances **can** be serialized across workflow/step boundaries by implementing the `@workflow/serde` protocol. This is essential when a class has instance methods with `"use step"` or when you want to pass class instances between steps.

**Install:** `@workflow/serde` must be a dependency of the package containing the class.

**Pattern:** Add two static methods inside the class body using computed property syntax:

```typescript
import { WORKFLOW_SERIALIZE, WORKFLOW_DESERIALIZE } from "@workflow/serde";

export class Point {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }

  // Serialize: return plain data (must be devalue-compatible types only)
  static [WORKFLOW_SERIALIZE](instance: Point) {
    return { x: instance.x, y: instance.y };
  }

  // Deserialize: reconstruct from plain data
  static [WORKFLOW_DESERIALIZE](data: { x: number; y: number }) {
    return new Point(data.x, data.y);
  }

  async computeDistance(other: Point) {
    "use step";
    return Math.sqrt((this.x - other.x) ** 2 + (this.y - other.y) ** 2);
  }
}
```

**Critical rules:**
1. **Define serde methods INSIDE the class body** as static methods with computed property syntax (`static [WORKFLOW_SERIALIZE](...)`). The SWC plugin detects them by scanning the class. Do NOT assign them externally (e.g., `(MyClass as any)[WORKFLOW_SERIALIZE] = ...`) -- the compiler will not detect this.
2. **Serde methods must return only devalue-compatible types** (plain objects, arrays, primitives, Date, Map, Set, Uint8Array, etc.). No functions, no class instances, no Node.js-specific objects.
3. **Add `"use step"` to Node.js-dependent instance methods.** The SWC plugin strips `"use step"` method bodies from the workflow bundle. This is how you keep Node.js imports (fs, crypto, child_process, etc.) out of the workflow sandbox. The class shell with its serde methods remains in the workflow bundle; only the step method bodies are removed.
4. **Do NOT manually register classes.** The SWC plugin automatically generates registration code (an IIFE that sets `classId` and adds the class to the global registry). Manual calls to `registerSerializationClass()` are unnecessary and error-prone.
5. **Do NOT use dynamic imports to work around sandbox restrictions.** If a class method needs Node.js APIs, the correct solution is `"use step"`, not `/* @vite-ignore */ import(...)`.

**When serde works well:** Pure data classes, domain models, configuration objects, and classes where Node.js-dependent methods can be marked with `"use step"`.

**When to avoid serde:** If a class is fundamentally inseparable from Node.js APIs (every method needs `fs`, `net`, etc.) and cannot meaningfully exist as a shell in the workflow sandbox, keep it entirely in step functions and pass plain data objects across boundaries instead.

### Validating serde compliance

Use these tools to verify classes are correctly set up:

- **`workflow transform <file> --check-serde`** -- Shows the SWC transform output for a file and checks if serde classes are compliant (no Node.js imports remaining in the workflow bundle).
- **`workflow validate`** -- Scans all workflow files and reports serde compliance issues. Use `--json` for machine-readable output.
- **SWC Playground** -- The web playground at `workbench/swc-playground` shows a Serde Analysis panel when serde patterns are detected.
- **Build-time warnings** -- The builder automatically warns when serde classes have Node.js built-in imports remaining in the workflow bundle.

## Streaming

Use `getWritable()` to stream data from workflows. `getWritable()` can be called in **both** workflow and step contexts, but you **cannot interact with the stream** (call `getWriter()`, `write()`, `close()`) directly in a workflow function. The stream must be passed to step functions for actual I/O, or steps can call `getWritable()` themselves.

**Get the stream in a workflow, pass it to a step:**
```typescript
import { getWritable } from "workflow";

export async function myWorkflow() {
  "use workflow";
  const writable = getWritable();
  await writeData(writable, "hello world");
}

async function writeData(writable: WritableStream, chunk: string) {
  "use step";
  const writer = writable.getWriter();
  try {
    await writer.write(chunk);
  } finally {
    writer.releaseLock();
  }
}
```

**Call `getWritable()` directly inside a step (no need to pass it):**
```typescript
import { getWritable } from "workflow";

async function streamData(chunk: string) {
  "use step";
  const writer = getWritable().getWriter();
  try {
    await writer.write(chunk);
  } finally {
    writer.releaseLock();
  }
}
```

### Namespaced streams

Use `getWritable({ namespace: 'name' })` to create multiple independent streams for different types of data. This is useful for separating logs from primary output, different log levels, agent outputs, metrics, or any distinct data channels. Long-running workflows benefit from namespaced streams because you can replay only the important events (e.g., final results) while keeping verbose logs in a separate stream.

**Example: Log levels and agent output separation:**
```typescript
import { getWritable } from "workflow";

type LogEntry = { level: "debug" | "info" | "warn" | "error"; message: string; timestamp: number };
type AgentOutput = { type: "thought" | "action" | "result"; content: string };

async function logDebug(message: string) {
  "use step";
  const writer = getWritable<LogEntry>({ namespace: "logs:debug" }).getWriter();
  try {
    await writer.write({ level: "debug", message, timestamp: Date.now() });
  } finally {
    writer.releaseLock();
  }
}

async function logInfo(message: string) {
  "use step";
  const writer = getWritable<LogEntry>({ namespace: "logs:info" }).getWriter();
  try {
    await writer.write({ level: "info", message, timestamp: Date.now() });
  } finally {
    writer.releaseLock();
  }
}

async function emitAgentThought(thought: string) {
  "use step";
  const writer = getWritable<AgentOutput>({ namespace: "agent:thoughts" }).getWriter();
  try {
    await writer.write({ type: "thought", content: thought });
  } finally {
    writer.releaseLock();
  }
}

async function emitAgentResult(result: string) {
  "use step";
  // Important results go to the default stream for replay
  const writer = getWritable<AgentOutput>().getWriter();
  try {
    await writer.write({ type: "result", content: result });
  } finally {
    writer.releaseLock();
  }
}

export async function agentWorkflow(task: string) {
  "use workflow";
  
  await logInfo(`Starting task: ${task}`);
  await logDebug("Initializing agent context");
  await emitAgentThought("Analyzing the task requirements...");
  
  // ... agent processing ...
  
  await emitAgentResult("Task completed successfully");
  await logInfo("Workflow finished");
}
```

**Consuming namespaced streams:**
```typescript
import { start, getRun } from "workflow/api";
import { agentWorkflow } from "./workflows/agent";

export async function POST(request: Request) {
  const run = await start(agentWorkflow, ["process data"]);

  // Access specific streams by namespace
  const results = run.getReadable({ namespace: undefined }); // Default stream (important results)
  const infoLogs = run.getReadable({ namespace: "logs:info" });
  const debugLogs = run.getReadable({ namespace: "logs:debug" });
  const thoughts = run.getReadable({ namespace: "agent:thoughts" });

  // Return only important results for most clients
  return new Response(results, { headers: { "Content-Type": "application/json" } });
}

// Resume from a specific point (useful for long sessions)
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const runId = searchParams.get("runId")!;
  const startIndex = parseInt(searchParams.get("startIndex") || "0", 10);
  
  const run = getRun(runId);
  // Resume only the important stream, skip verbose debug logs
  const stream = run.getReadable({ startIndex });
  
  return new Response(stream);
}
```


---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
