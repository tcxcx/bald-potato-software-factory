---
name: migrating-world-v4-to-v5
description: >-
  Upgrades a custom Workflow SDK World implementation from the v4 spec, or from a 5.0.0 beta, to the current v5 spec (spec version 8). Use when a package implements the `World` interface from `@workflow/world` and is moving to 5.x, or is on a 5.0.0 beta and the runtime reports `This Workflow runtime supports Worlds with spec version 6 through 8, but the configured World declares spec version N`; or when it shows event IDs that are ULIDs rather than slot positions, `Event id is not slot-numbered` at replay time, a `specVersion` the runtime refuses, `writeToStream` / `closeStream` / `readFromStream` as top-level World methods, `steps.get` or `events.listByCorrelationId` without a `runId`, a `'step'` queue kind or `__wkf_step_*` topics, a `preconditionGuard` capability, or a `createLocalWorld` / `createVercelWorld` factory.
metadata:
  author: Vercel Inc.
  version: '0.4.0'
---

# Migrating a World from the v4 spec to v5

This skill is for a package that implements `World` from `@workflow/world`: a storage, queue and stream backend the Workflow runtime talks to. It is not for application code. If the task is bumping an app's `workflow` dependency, use the `migrating-workflow-v4-to-v5` skill instead; if the app both uses Workflow and ships its own World, run that skill first and this one second.

An app on the Vercel, Local or Postgres World needs nothing from this skill. Those ship with the SDK and are already on the v5 spec.

One change dominates the work. **Event ID allocation is required, is not visible from the type signatures, and a World that skips it type-checks, starts runs, and fails on the first replay.** Do that part first, then the mechanical rewrites. Do not begin with the type errors: they are the small half, and finishing them produces a World that looks migrated and is not.

### Which spec version a pin produces

What a World declares follows the `@workflow/world` version it resolves, and the runtime admits a range. Check both before deciding how much work this is.

| `@workflow/world` | `SPEC_VERSION_CURRENT` / `mintedSpecVersion()` | Admitted by `workflow` 5.2.x (range 6 to 8)? |
| --- | --- | --- |
| any 4.x | 5 or below | No |
| `5.0.0-beta.25` and earlier | 5 or below (no slot identity) | No |
| `5.0.0-beta.35` to `beta.37` | 7 | Yes, but not spec 8 |
| `5.0.0-beta.39` and later, all 5.0.x stable | 8 | Yes |

The range is printed by the startup error, and lives in the bundled `@workflow/core` as `assertWorldSupportsRuntimeProtocol`. A host that bundles its own copy of the runtime has its own ceiling: grep the bundle for `supports Worlds with spec version` to read it. Declaring above a host's ceiling makes that host refuse the World at startup, so a World that must also run under older hosts states which host versions each of its releases supports.

**A World already on a 5.0.0 beta** with slot-numbered IDs does not redo step 1. Bump `@workflow/world` and `@workflow/errors` to the stable line, confirm the declaration is `mintedSpecVersion()` (step 2), read the spec 8 notes in step 2, then audit the step 5 contract items and the fail checklist: several of them landed late in the beta line and a beta-era World commonly misses lazy `step_started`, the `runs.list` status array and `resolveData: 'skip-step-inputs'`. Run the conformance suite at the new version before calling it done.

**A World that predates event sourcing** (it exposes `runs.create`, `steps.update` and the like, and has no `events.create` that drives entity state) has no v4 event log to port. The whole `events.create` state machine is written from scratch. Use `packages/world-postgres/src/storage.ts` as the reference and keep its event-by-event structure.

## Intake

Before editing, establish and report each of these:

1. **Where the World is.** Grep for `implements World`, `: World`, `World>` and `from '@workflow/world'`. Read the factory it exports.
2. **How event IDs are minted today.** Grep for `eventId`, `ulid`, `uuid`, `nanoid`, `nextval`, `AUTO_INCREMENT`, `IDENTITY`. Find the exact line that produces the ID written to storage. Note any place an ID is chosen before the write that stores it, for example an ID planned in advance and saved in a claim record so redeliveries reuse it. That design hands out a position before the commit and needs reworking, not porting.
3. **What settles a write race.** Read the `events.create` implementation. Note whether the ID or ordering is decided in process (read-then-write, an in-memory counter, a `Math.max` over loaded events) or in the store (unique constraint, conditional write, `INSERT ... ON CONFLICT`, a transaction).
4. **Which `specVersion` it declares.** Grep for `specVersion`. Note whether it is a literal or an imported constant.
5. **Which optional members exist.** Grep for `capabilities`, `analytics`, `getRuntimeDeadline`, `getEnvironment`, `createRunId`, `describeRun`, `getEncryptionKeyForRun`, `resolveLatestDeploymentId`, `cancelMany`, `experimentalSetAttributes`.
6. **Whether it provisions step topics.** Grep for `'step'`, `__wkf_step`, `stepQueue`.
7. **Whether it rejects stale writes.** Grep for `PreconditionFailedError`, `preconditionGuard`, `stateUpdatedAt`, `stateEventCount`, `stateCursor`, `412`.
8. **Where its process-wide state lives.** Grep the World's modules for top-level `const`/`let` holding a pool, client, socket, registry, cache, ULID factory, or a log-once boolean. Note every one: these are correct in a `require()`d package and wrong in a bundled one.
9. **How it is tested.** Grep for `@workflow/world-testing` and `createTestSuite`. A World without the conformance suite wired up gets it in this migration.
10. **What its store can make atomic.** A transaction, a conditional write or unique constraint, a server-side script (Redis Lua, a Durable Object or actor that is single-threaded per run), or none (a CRDT or eventually consistent store). Step 1 depends on the answer.
11. **Whether bytes survive its storage and queue.** v5 entity data, event data and queue payloads carry `Uint8Array` values (`SerializedData`, `stepInput.input`). Grep for `JSON.stringify`, `JSON.parse`, `Buffer`, `Binary`. A store or transport that round-trips through plain JSON, or hands back a Node `Buffer`, corrupts them silently.
12. **Whether it forwards runtime parameters across a process boundary.** A World whose storage sits behind HTTP, RPC or an actor call serializes `events.create()` params and errors. Note where.
13. **Which host it runs in.** Node, a Worker, a browser, or a host app that bundles its own runtime (step 2 and step 7 depend on this).
14. **Where its runs live.** Ask, or determine from the deployment model, whether a single deployment serves every run or a run is pinned to the deployment that created it. This decides the rollout in step 7 and cannot be read out of the code.

Also record the `@workflow/world` version it pins today and look it up in the table above.

Report anything not applicable rather than skipping it silently.

## Step 1 — event ID allocation

In v4 an event ID was a ULID the World minted however it liked. In v5 an event ID is the event's **position in its run's log**: `evnt_` followed by a 1-based slot, zero-padded to 26 characters, so a run's first event is `evnt_00000000000000000000000001`.

```ts
import { slotToEventId, eventIdToSlot, FIRST_EVENT_SLOT } from '@workflow/world';

slotToEventId(1); // 'evnt_00000000000000000000000001'
eventIdToSlot('evnt_00000000000000000000000042'); // 42
eventIdToSlot('evnt_01JQ...'); // null
```

Every stored ID must equal `slotToEventId(slot)` exactly. Format with `slotToEventId()` wherever the slot is known in process. Where the slot is only known inside the store's atomic operation (the SQL below, a Redis Lua script), formatting there is correct, provided the prefix and width are derived from `slotToEventId()` (for example from `slotToEventId(1)`) rather than retyped, and the World decodes the returned ID with `eventIdToSlot()` before trusting it. When a script injects the ID into JSON the client already serialized, put `eventId` first as a fixed placeholder and replace only its first occurrence; a later field such as a hook token is user-chosen and can contain the same text. The fixed width is what makes lexicographic order the same as positional order, so a World padding to a different width sorts its own log wrongly past ten events.

There is no capability to declare and no fallback path. The runtime calls `requireEventSlot()` on IDs it loads, which throws `Event id is not slot-numbered: <id>. This World allocates event positions the runtime cannot read.`

Four rules bind the implementation. Check each against the code found in intake items 2 and 3:

- **Uniqueness.** Two concurrent appends must not both take a slot. Settle it where the store settles it: a unique constraint on `(runId, eventId)`, a conditional write, or a serializable transaction. Reading the maximum slot and adding one in process is the failure mode this rule exists for, and it survives light testing because it only breaks under concurrency.
- **Density.** Slots run from 1 with no holes. A writer that loses a race re-derives its slot from the store and takes the next free one. Incrementing a local number after a loss leaves a permanent hole, and the runtime fails the run with `CORRUPTED_EVENT_LOG` rather than replay across one.
- **Bump and report.** `events.create()` params carry `eventCount`: how many events the writer held in the log it replayed from, so the slot it expects is `eventCount + 1`. When that slot is taken, **do not reject the write.** Commit at the next free slot, and return the events occupying the slots you skipped on the success response, in `events` with a matching `cursor` and `hasMore`. A stale count is the normal case for a parallel fan-out; rejecting it would serialize writes the runtime deliberately issues concurrently. A create that arrives with no `eventCount` came from a caller with no loaded log (a queued step body, an out-of-band writer) and is always accepted.
- **Allocate at the commit.** Take the slot in the same operation that appends the event, never earlier. This is what makes a reader's log a *prefix* of the run's log rather than a prefix with a hole in it: nothing can land behind a slot a reader has already passed. A World that hands out a slot in a request handler and commits later breaks the property every replay depends on.

The shape that satisfies all four, for a SQL store with a unique key on `(run_id, event_id)`, is to compute the ID *inside* the insert and let the constraint arbitrate:

```sql
INSERT INTO events (run_id, event_id, event_type, data)
SELECT $1,
       'evnt_' || lpad((coalesce(
         (SELECT cast(substring(prev.event_id from 6) AS bigint)
            FROM events prev WHERE prev.run_id = $1
           ORDER BY prev.event_id DESC LIMIT 1), 0) + 1)::text, 26, '0'),
       $2, $3
ON CONFLICT (run_id, event_id) DO NOTHING
RETURNING event_id;
```

No row returned means another writer took that slot. Retry the same statement: it re-reads the maximum from a store that has already advanced, which is the bump. `@workflow/world-postgres` does exactly this, with a bounded retry count and jittered backoff after the first few immediate attempts, and absorbs the conflict with `DO NOTHING` rather than raising, because these inserts run inside a transaction an error would poison.

The exact statement matters less than the property: the slot is computed and the row is inserted in one atomic operation against the rows the constraint protects, so a loser retries against the store rather than against a number it remembered. A store without conditional writes needs a serializable transaction instead, not an in-process lock, which only orders the writers inside one process.

Read the log head **before** the entity state the event validates against, inside the same transaction or retry loop. The slot then fences the validation too: a writer that validated against a stale step or run row loses the slot and re-validates on the retry.

How this maps onto other stores:

- **A store that serializes per run** (a Cloudflare Durable Object, a Rivet actor, any single-threaded owner per run) allocates inside the owner's commit. Nothing else is needed for the event log. Hook tokens are a different matter: they are unique across runs, so they cannot be arbitrated in per-run storage and need a store-wide owner or constraint.
- **A server-side script** (Redis Lua, `WATCH`/`MULTI`) reads the head and appends in the one script or transaction.
- **A conditional write without multi-key transactions** (MongoDB standalone, NATS KV, Cosmos) uses a unique index on `(runId, eventId)` or a put-if-absent on the slot key, and retries on the duplicate. If the entity update and the event cannot commit together, use the store's transactions where its topology allows, and otherwise document the crash window between them.
- **An embedded or synchronous driver** (libSQL `file:`, `better-sqlite3`) also needs an in-process write mutex. A second in-process writer blocks on the database lock synchronously, which blocks the event loop the lock holder needs to finish; busy timeouts do not help. The mutex orders writers inside the process, and the constraint still settles writers across processes.
- **A store with no conditional write at all** (a CRDT, an eventually consistent KV) cannot give uniqueness across writers. Either serialize all appends for a run through one writer and document that single-writer deployment as a requirement, or claim slots with whatever put-if-absent exists and read back only the dense prefix from slot 1. In both cases, make a log that two writers merged fail loudly on load rather than replay out of order. State the guarantee in the World's README.

**Existing keys and rows.** A v4 schema often has a unique index or primary key on `eventId` alone. Two runs now both have `evnt_00000000000000000000000001`, so the second run's first event is rejected. Re-key to `(runId, eventId)`. If old ULID rows (`wevt_...`, `evnt_<ULID>`) stay in the same table, filter slot allocation and range reads to slot IDs: a ULID sorts after every slot ID and does not decode to a slot, so "the highest ID" becomes garbage. Keep pre-slot runs readable and cancellable, and refuse to append to them.

Then return the skipped span whenever the committed slot exceeds `eventCount + 1`. Understating `eventCount` is safe and overstating is not: a count below the writer's true position only widens the reported span, which the writer discards where its log already holds the events; a count above it makes the World report less than the writer is missing, which is a hole the writer never learns about.

## Step 2 — declare the spec version

`specVersion` is the protocol version the World implements, and the number stamped on every run it creates. Call the helper rather than importing a constant:

```ts
import { mintedSpecVersion } from '@workflow/world';

export function createWorld(): World {
  return {
    specVersion: mintedSpecVersion(),
    // ...
  };
}
```

The runtime checks the declaration against a supported range before it creates or replays anything, and refuses a World outside it, naming both the range and what the World declared. The floor is the version that introduced slot-numbered IDs, because a World below it allocates IDs the runtime cannot read positions out of. The ceiling is the highest version the runtime can read.

`mintedSpecVersion()` is a function because the version a World stamps is a deployment choice: it answers with the current version (8) by default, and with the slot-identity version (6) when `WORKFLOW_SEALED_LOG=0` opts new runs out. Both are inside the accepted range. Call it inside `createWorld()` rather than caching it at module load, so one process can create Worlds in both modes.

Its parameter defaults to `process.env`. Where `process` does not exist (a browser, a Worker without `nodejs_compat`) the bare call throws a `ReferenceError`. Pass the environment explicitly: `mintedSpecVersion(config.env ?? globalThis.process?.env ?? {})`.

When an event or run arrives without a `specVersion` and the World fills one in, use the version the World declared, not `SPEC_VERSION_CURRENT`, which ignores `WORKFLOW_SEALED_LOG`.

If `@workflow/world` is only a type-level or peer dependency and the World reimplements `mintedSpecVersion()` locally to avoid a runtime import, the local copy pins a number by another route and falls behind on the next bump. Report it as a finding.

Report any of these as findings rather than leaving them:

- A hard-coded number. It leaves the World a version behind the next bump and gets it rejected by the runtime it ships alongside.
- `SPEC_VERSION_CURRENT` or `SPEC_VERSION_SUPPORTS_SLOT_IDENTITY` used as the declaration. Both are literals by another name here, since neither follows the sealed-log setting.
- Code that assumes every run matches what the World declares today. A run's version is persisted at creation and kept for life, so read it off the run.

### The sealed log and `noop`

The sealed-log version permits one alternative to allocating a position at the commit (step 1): hand positions out from a per-run counter *before* the commit, so concurrent writers never race for one, then restore density at read time by writing a `noop` event into any position provably abandoned. A `noop` occupies its position and means nothing — replay steps over it without delivering it and without advancing the deterministic clock.

For most migrations this is a no-op, and say so rather than skipping it: **a World that allocates at the commit is already compliant** and will never emit a `noop`, because no write can leave a position empty. Only build the sealing half if the World pre-assigns positions, and then it must also never return a page with an interior hole — return the dense prefix below the hole and let the next page pick up once the position resolves.

The half that always applies is the reader's: `noop` is not user-creatable, never sent to `events.create()`, and only the World's own read path may write one. If the World validates event types on read, make sure `noop` parses.

### Spec 8 and hook token takeover

Spec 8 is also a reader contract. A run stamped 8 is one whose runtime understands an *involuntary* hook disposal: a `hook_disposed` carrying `forceClaimedBy`, written into its log by another run's `createHook({ token, experimental_force: true })`. Its awaiters reject with `HookForceClaimedError` instead of hanging.

**Declaring 8 costs a World nothing it has to build.** Takeover itself is behind `capabilities.hookForceClaim`, which fails closed: a World that does not advertise it never writes `forceClaimedBy`, and the runtime fails a forced `createHook()` at registration. Say so in the report rather than leaving the capability unmentioned.

A World that does implement takeover takes on these obligations, and only advertises the flag once all of them hold:

- On a forced `hook_created` for a token a live run holds, append `hook_disposed` with `forceClaimedBy: { runId, hookId }` to the holder's log, refuse later `hook_received` writes to the holder's hook, re-point the token to the claimer, and record `Hook.claimedFrom`.
- Refuse the takeover with an ordinary `hook_conflict` carrying `forceRefusedReason: 'victim-spec-version'` when the holder run was stamped below 8. A reader below 8 would treat the disposal as its own `dispose()` and strand every `await hook`.
- A finished holder has no reader to strand, so a retained token is taken over at any version.
- Answer a `hook_received` refused by a takeover with `HookForceClaimedError`, so `resumeHook()` can follow the token.

## Step 3 — apply the mechanical rewrites

These are signature and module-shape changes. Apply each only where the pattern appears.

### Streams moved to a `streams` namespace, with `runId` first

| v4 | v5 |
| --- | --- |
| `writeToStream(name, runId, chunk)` | `streams.write(runId, name, chunk)` |
| `writeToStreamMulti(name, runId, chunks)` | `streams.writeMulti(runId, name, chunks)` |
| `closeStream(name, runId)` | `streams.close(runId, name)` |
| `readFromStream(name, startIndex?)` | `streams.get(runId, name, startIndex?)` |
| `getStreamChunks(name, runId, options?)` | `streams.getChunks(runId, name, options?)` |
| `listStreamsByRunId(runId)` | `streams.list(runId)` |
| `getStreamInfo(name, runId)` | `streams.getInfo(runId, name)` |

The argument order flipped, so moving the methods without swapping arguments passes a stream name where a run ID is expected and type-checks whenever both are `string`. `readFromStream` had no `runId` at all; `streams.get` requires one, so thread the owning run through.

`streams.get` returns a live stream: it keeps delivering chunks as they are written and ends only when the stream is closed. Returning a snapshot of the chunks present at call time is the common v4 shortcut and breaks any reader that attaches before the writer finishes. `streams.getChunks` is the snapshot method.

`streams.streamFlushIntervalMs` sets the flush window. The v5 default is `0`, so the first chunk flushes immediately. Set a value only to deliberately coalesce writes.

### `events.get(runId, eventId)` is required

Storage exposes `events.get` for a single event by its position. Implement it as a keyed read on `(runId, eventId)`.

### `steps.get()` requires a `runId`

The first parameter was `string | undefined` and is now `string`. A World that looked a step up by ID alone needs the run in its key or its index.

### `events.listByCorrelationId()` requires a `runId`

A correlation ID identifies a step, hook or wait within its run, not across runs. Scope the lookup to one run. A World that paginates by event ID needs the run in its cursor comparison too, since two runs can now hold the same correlation ID.

`analytics.events.listByCorrelationId()` took the same `runId`, and is now deprecated on top of it: it is a special case of `analytics.events.list({ runId, correlationId })` and goes away in the next major. Port it for now, and do not build anything new on it. The **storage** `events.listByCorrelationId()` above is not deprecated and keeps its own endpoint.

### `resolveData: 'skip-step-inputs'`

Event reads take `EventsResolveData`, which adds `'skip-step-inputs'` to `'all'` and `'none'`. Treat any value other than `'none'` as `'all'` unless the World implements the input skip, and use `entityResolveData()` from `@workflow/world` to map it for run, step and hook payloads. The conformance suite exercises it.

### Queue names carry no kind


---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
