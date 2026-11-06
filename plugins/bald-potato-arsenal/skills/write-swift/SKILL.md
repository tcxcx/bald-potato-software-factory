---
name: write-swift
description: How to write modern Swift well — modeling with value types, Swift 6 data-race safety and approachable concurrency (@concurrent, main-actor-by-default, actors, task groups), protocols and generics (some vs any), API design, performance and ARC, Swift Testing, macros, and the modern language features agents don't know about yet. Use when writing, reviewing, or migrating Swift, or when a concurrency error, a hang, a data race, a retain cycle, or a performance problem needs fixing.
---

# Write Swift

## Initial Response

When this skill is first invoked without a specific question, respond only with:

> I'm ready to help you write modern Swift, the way the language wants to be written.

Do not provide any other information until the user asks a question.

How to write Swift the way the language wants to be written, current through Swift 6.4.

**Toolchain baseline: Swift 6.3** (current release as of August 2026). Everything here compiles on 6.3 unless marked ⚠, which flags unreleased Swift 6.4 features. Concurrency guidance assumes the Swift 6.2 model — if the project is on 6.1 or earlier, §3's rules about `async` and `@concurrent` do not apply.

The through-line: **Swift is a progressive-disclosure language. Start with the simplest, most static, most single-threaded thing that works, and buy dynamism — concurrency, reference semantics, existentials, unsafe pointers — only where you can point at the reason.** Every rule below is an application of that.

Model this hierarchy of defaults. Move down a level only with a reason you can state:

| Need         | Reach for               | Move down only when                                        |
| ------------ | ----------------------- | ---------------------------------------------------------- |
| Data         | `struct` / `enum`       | you need identity, sharing, or inheritance                 |
| Abstraction  | concrete type           | you have repeated code across types                        |
| Polymorphism | `some P` (generic)      | you need heterogeneous storage → `any P`                   |
| Execution    | main actor, synchronous | profiling shows a hang → `async` → `@concurrent` → `actor` |
| Memory       | `Array`, `String`       | profiling shows the cost → `InlineArray`, `Span`           |
| Safety       | safe API                | C interop or a measured hot path → `Unsafe*`               |

---

## 1. Model data with value types

Value types are the default in Swift, not a special case.

- **Default to `struct` and `enum`. Use `class` only for identity, shared mutable state, inheritance, or resource lifetime.** A window, a database connection, an entity stored in a rendering engine — those have identity. A `Point`, a `Drink`, a `Material` does not.
- **`let` by default; `var` only when you mutate.** This is the same discipline as `some` before `any` and value before reference: start narrow, widen with cause.
- **A struct with a mutable reference-type property is neither a value nor a reference.** Copies share the object; mutations leak across copies. Either keep the referenced type immutable, expose only computed properties that forward to it, or make it a `private` stored property behind copy-on-write.
- **Copy-on-write is how you get out-of-line storage _and_ value semantics.** Wrap a final class in a struct and check `isKnownUniquelyReferenced(&storage)` before mutating; copy first if it isn't. This is exactly how `Array`, `String`, and `Dictionary` work.
- **Enums are the tool for "a fixed set of things" and for mutually exclusive state.** Replacing a pile of optional stored properties (`isSharing`, `selectedRows`, `shareTarget`) with one `enum State` makes invalid combinations unrepresentable and makes state change atomic instead of a sequence of property writes you can forget to finish.
- **Composing values yields a value.** A struct whose stored properties are all value types has value semantics for free — which is what makes undo, diffing, and state restoration a single code path instead of one per property.

```swift
struct Material {                       // value semantics preserved
  var roughness: Double
  private var _texture: Texture         // a class

  var color: Color {
    get { _texture.color }
    set {
      if !isKnownUniquelyReferenced(&_texture) { _texture = Texture(copying: _texture) }
      _texture.color = newValue
    }
  }
}
```

**Noncopyable types** (`~Copyable`) express unique ownership: a file descriptor, a bank transfer, an open resource. Suppressing the copy turns "you must not run this twice" from an assertion into a compile error, and makes `deinit` on a struct meaningful. Mark the finishing method `consuming` so the compiler proves it's the last use. Parameter ownership becomes explicit: `borrowing` (read-only, the default), `consuming` (takes it away), `inout`/`mutating` (temporary write access).

---

## 2. Errors and optionals — make the failure paths visible

Swift error handling rests on three points: sources of error are marked so they can't surprise you; errors carry enough context to act on; and **recoverable errors are different from programmer mistakes**.

- **Recoverable → `throw`. Programmer mistake → `precondition`/`fatalError`.** A failed network call keeps the program running. An out-of-bounds index means the code is wrong and must halt before the bug becomes a security issue.
- **Enums with associated values make the best error types.** `case duplicateFriend(String)` beats `case duplicateFriend` — the context is the whole point.
- **`guard` for error conditions**, because it forces the exit path. `if let` for the ordinary unwrap.
- **Typed throws (`throws(MyError)`) are for internal functions, error-forwarding generic code, and constrained environments** where boxing `any Error` is too costly. For public API, untyped `throws` preserves your freedom to change the error type later. Note the unification: `throws` is `throws(any Error)`, and non-throwing is `throws(Never)` — which is what lets `map` abstract over both.
- **Force-unwrap only where you can state the invariant**, and prefer a failing `#require`/`precondition` with a message over a bare `!`.

---

## 3. Concurrency: stay single-threaded until profiling says otherwise

This is the section agents get wrong most often, because the model changed in Swift 6.2.

Start every app entirely on the main thread. Single-threaded code goes a long way, and most apps never need to leave it.

**The progression, in order. Do not skip steps.**

1. **Single-threaded on the main actor.** No concurrency at all. Fine for most apps.
2. **`async`/`await`** to hide latency (network, disk). Still no concurrency of your own — SDK APIs like `URLSession.data(from:)` offload on your behalf.
3. **`@concurrent`** to move _your_ expensive work off the main thread — only after Instruments shows a hang.
4. **`actor`** to move _state_ off the main actor — only when too much main-actor state is forcing tasks to hop back constantly.

**Turn on the right build settings first.** Enable **Approachable Concurrency** in every project. For app modules and UI-facing modules, also set **Default Actor Isolation** to **MainActor** — it's the default for new app projects in Xcode 26, and it deletes most of your `@MainActor` annotations. In a package: `swiftSettings: [.defaultIsolation(MainActor.self)]`. **Do not set main-actor-by-default for a general-purpose library** — libraries should ship `nonisolated` APIs and let clients decide where work runs.

### The rule that changed

**In Swift 6.2, marking a function `async` does _not_ move it off the current actor.** It runs where it was called from. This is what makes "the most natural code to write" data-race free by default.

- **`@concurrent`** — always switches to the concurrent thread pool. Use it on _your_ CPU-heavy work.
- **`nonisolated`** — runs wherever it's called from. **This is the right default for library APIs**, because the caller decides. `nonisolated` on a type makes all its members nonisolated (Swift 6.1+).
- Neither one — stays on the caller's actor.

```swift
nonisolated struct PhotoProcessor {          // decoupled from the main actor
  @concurrent                                // guaranteed to run in the background
  func process(_ data: Data) async -> ProcessedPhoto {
    async let sticker = extractSticker(data)  // two independent jobs, in parallel
    async let colors  = extractColors(data)
    return await ProcessedPhoto(sticker: sticker, colors: colors)
  }
}
```

- **Profile before you offload.** Use Instruments (Time Profiler, hangs). If the code can be made faster without concurrency, always do that first. Concurrency has real cost — task allocation, scheduling, and reasoning.
- **Don't spawn a task for trivial work.** A child task to read a `UserDefaults` value costs more than it saves.
- **One task per end-to-end operation.** Work that must happen in order goes in _one_ task; independent operations get separate tasks so the runtime can interleave them.
- **`await` is a suspension point, and it breaks atomicity.** State can change while you're suspended, and you may resume on a different thread. Re-check assumptions after every `await`. Never hold a lock across one. Never rely on thread-local storage across one.

### Actor reentrancy

Actors guarantee mutual exclusion, not transactions. Between two `await`s on the same actor, other work runs.

- **Mutate actor state in synchronous methods.** Synchronous code on an actor runs to completion uninterrupted — that's your transaction boundary.
- **Keep async actor methods thin**, composed of synchronous transactional operations, and leave the actor in a consistent state at every `await`.
- The classic bug: check cache → `await` download → write cache. Two tasks both miss, both download, the second clobbers the first. Re-check after the `await`, or dedupe the in-flight work.
- **Actors are not FIFO.** They run highest-priority work first, precisely to avoid priority inversion. If you need ordering, use a task (which runs start to finish) or an `AsyncStream`, not an actor.

---

## 4. Sendable and sharing data

`Sendable` marks a type safe to share across isolation domains. The compiler checks it at every task and actor boundary.

- **Value types are `Sendable` when their storage is** — inferred automatically for non-public types. **Public types never get inferred sendability**: marking a public type `Sendable` is a promise to your clients, so Swift makes you write it.
- **Actors and `@MainActor` classes are implicitly `Sendable`**, because their state is isolated.
- **Most model classes should be neither `@MainActor` nor `Sendable`.** Keep them non-`Sendable` on purpose — it prevents half the model being mutated on the main thread while the other half is mutated in the background. If they need to leave the main actor, make them `nonisolated`, not `Sendable`.
- **You can still _send_ a non-`Sendable` object between domains** as long as the sender stops using it. Make all your mutations _before_ handing it off; touching it afterward is the error.
- Closures capture state too. Only mark a function type `@Sendable` if it genuinely crosses domains.
- **`@unchecked Sendable` is a promise the compiler can't check.** Reserve it for types with real internal synchronization (a `Mutex`, a lock). Same for `nonisolated(unsafe)` on a global — last resort, not a warning silencer.

**When you hit a data-race error, work down this list:**

1. **Don't share it.** Move the shared object into a local so each concurrent job gets its own instance. (This is the fix for the overwhelming majority of real errors.)
2. **Make it a `Sendable` value type**, so "sharing" is really copying.
3. **Isolate it to an actor** — the main actor, or your own.
4. Only then reach for `Mutex`/`Atomic` from the `Synchronization` module (store them in `let` properties), or `@unchecked Sendable`.

**Global and static variables are the most common source of errors.** In order of preference: make it a `let`; put it on `@MainActor`; wrap it in a `Mutex`; `nonisolated(unsafe)`. Note globals in Swift are initialized lazily _and_ atomically — unlike C.

**Bridging old callback APIs:** annotate delegate protocols with `@MainActor` if you own them. If you don't, mark the method `nonisolated` and use `MainActor.assumeIsolated { }` — it asserts rather than hopping, so it traps loudly instead of racing silently. `@preconcurrency` on the conformance is the shorthand for the same thing. Use `@preconcurrency import` to temporarily silence sendability warnings from a module that hasn't migrated; the warnings come back — correctly — once it does.

---

## 5. Structured concurrency

Always prefer structured tasks.

Structured tasks (`async let`, task groups) are scoped like local variables: they can't outlive the block, they're awaited automatically, and they inherit cancellation, priority, and task-local values through the task tree. Unstructured tasks (`Task { }`, `Task.detached`) give you none of that automatically.

- **`async let`** for a fixed, statically known number of concurrent children.
- **`withTaskGroup`** when the number is dynamic. Task groups conform to `AsyncSequence` — iterate results as they land. Use **`withDiscardingTaskGroup`** when children return nothing: it frees each child's resources immediately and cancels siblings on the first error.
- **`Task { }`** only when the work's lifetime doesn't fit a scope — reacting to a delegate callback, a button tap, a view appearing. It inherits actor isolation and priority; you must manage cancellation yourself.
- **`Task.detached`** almost never. It inherits nothing — not isolation, not priority, not task-locals. If you need a detached root, put a task group _inside_ it rather than detaching repeatedly.

**Cancellation is cooperative.** Cancelling sets a flag; it stops nothing. Check `Task.isCancelled` or `try Task.checkCancellation()` **before starting expensive work**, and in synchronous helpers too. For work that's suspended rather than running (an `AsyncSequence`'s `next()`), use `withTaskCancellationHandler` — and remember the handler runs immediately and concurrently with the body, so the state it touches needs real synchronization (an atomic or a lock, not an actor — you can't guarantee ordering on an actor).

**Bound your concurrency.** Don't fan out one child per item over an unbounded list. Start N children, then add a new one each time one finishes.

**Task-local values** (`@TaskLocal`) propagate context — a request ID, a trace span — down the task tree without threading a parameter through every signature. Make them optional so unbound reads have a sensible default.

**Bridging callbacks:** `withCheckedContinuation` / `withCheckedThrowingContinuation`. The contract is **resume exactly once on every path** — never resuming hangs the caller forever; resuming twice is a fatal error. For delegate APIs that fire later, store the continuation and nil it out when you resume. (Swift 6.4 — unreleased — adds a `Continuation` type that checks single-resumption at compile time.)

**`AsyncSequence`:** iterate with `for await` / `for try await`. Adapt an existing handler- or delegate-based API with `AsyncStream` / `AsyncThrowingStream` — construct the source inside the closure, `yield` from the handler, and clean up in `onTermination`.

---

## 6. Concurrency in SwiftUI

- **`View` is `@MainActor`-isolated**, and so is everything it contains, including your `@State`. You almost never need to write `@MainActor` on a view or a view model — and with main-actor-by-default you can delete the ones you have.
- **SwiftUI deliberately runs some of your code off the main thread** to keep frames cheap. The signal is `@Sendable` in the API's signature: `visualEffect`, `Shape.path(in:)`, `Layout` requirements, `onGeometryChange`. When you hit an isolation error inside one of those closures, **don't send `self` — copy the one value you need into the closure's capture list.**

```swift
.visualEffect { [pulse] effect, proxy in    // copy the Bool, don't capture self
  effect.blur(radius: pulse ? 2 : 0)
}
```

- **SwiftUI's action callbacks are synchronous on purpose.** Time-sensitive UI updates — starting an animation in response to a gesture or a scroll event — must happen on the same frame as the event. Put the `withAnimation` state change in the synchronous callback; open a `Task` only for the long-running work that follows.
- **Put a piece of state on the seam between UI and async work.** The view kicks off a task; the async layer does a synchronous mutation when it finishes; the UI reacts. That keeps view logic synchronous and makes the async logic testable without importing SwiftUI.

---

## 7. Protocols and generics

Don't start with a class. **Don't start with a protocol either.**

The workflow: **write concrete types → notice repeated code across them → factor the shared capability into a protocol → write generic code against it.** Overloads with near-identical bodies are the signal that it's time to generalize.

- **A protocol with no per-type customization is a wasted protocol.** If every conformance would use the same default implementation, write a constrained extension on an existing protocol instead. Elaborate protocol hierarchies ("type zoology") cost compile time and binary size and buy nothing.
- **Prefer has-a to is-a.** If only some of a protocol's operations make sense for your type, don't refine it — wrap it in a generic struct and expose exactly the API you mean. (`GeometricVector<Storage: SIMD>` rather than `GeometricVector: SIMD`.)
- **A protocol requirement is a customization point** — it's dynamically dispatched, and a conforming type's implementation wins everywhere. **A method only in an extension is statically dispatched**, so a conformer's version _shadows_ rather than overrides it, and code that only knows `any P` calls the extension's. If a type should be able to customize something, make it a requirement.
- **Composition over inheritance.** Class inheritance is monolithic (one superclass), intrusive (you inherit stored properties and initializer complexity), and leaves unwritten contracts about what may be overridden and when to call super. Compose small values instead.
- **A forced downcast is a code smell** — it usually means a type relationship was lost to a class hierarchy or an existential.

### `some` vs `any`

- **Write `some P` by default. Change to `any P` when you need to store arbitrary types.** Same discipline as `let` before `var`.
- `some P` — one fixed underlying type per scope. You keep every type relationship, including associated types, and the compiler can specialize.
- `any P` — type-erased box, dynamic type varies at runtime. Needed for heterogeneous collections, for optionality of the underlying type, and to hide the abstraction entirely. You pay for it: associated-type relationships are erased to their upper bounds, and calls are opaque to the optimizer.
- **You cannot call a method that takes an associated type on an `any P`.** Erasure works in producing position (the result is erased to its upper bound) but not consuming position. The fix is to pass the existential into a function taking `some P` — the compiler unboxes it, and inside that scope the type is fixed again.
- **Constrained existentials and opaque types** — `some Collection<Element>`, `any Collection<any Animal>` — let you hide `LazyFilterSequence<[Animal]>` while still exposing the element type. Declare primary associated types on your own protocols (`protocol Container<Item>`) for the type callers actually supply, not for implementation details like `Iterator`.
- **Same-type requirements in `where` clauses** are how you pin down relationships across protocols (`where Self.CropType.FeedType == Self`). Without them, "grow then harvest" doesn't typecheck, and wrong conformances compile.

---

## 8. API design — clarity at the point of use

Clarity at the point of use is the goal that outranks every other one here.

- **No type prefixes in Swift-only APIs.** Modules disambiguate. Keep prefixes only where the API mirrors an Objective-C one. But avoid very general names from specific frameworks — they read badly out of context and force manual disambiguation.
- **Drop leading `get`** from async alternatives and from anything that returns its result directly. `persistentPosts`, not `getPersistentPosts`.
- **Access control is documentation.** `private` (file), `internal` (module, and the default), `package`, `public`. Being explicit at the boundary is what forces the sendability and API-evolution decisions above.
- **Design the model so illegal states can't be spelled.** Private setters plus a validating mutating method; enums for closed sets; a strongly typed `UUID` instead of a `String`.
- **Property wrappers** factor out an _access policy_ (`@Argument`, `@Published`, defensive copying, lazy, thread-local) so the declaration site states the policy in one word. Combine with `@dynamicMemberLookup` on a key path to project through a wrapper (that's how `$binding.title` works).
- **Result builders** for declarative DSLs. **Macros** when the boilerplate is code the compiler could have written (§12).

---

## 9. Performance — measure, then choose

Low-level Swift performance is dominated by four costs. Know which one you're paying.

1. **Function calls** — argument copies, static vs dynamic dispatch, call-frame allocation, and blocked optimization.
2. **Memory layout** — inline vs out-of-line storage; dynamically sized types.
3. **Allocation** — global (free), stack (cheap: one subtraction), heap (expensive: search plus locking).
4. **Copies** — retains/releases and recursive struct copies.

**But do the algorithmic work first.** Every time you write a loop, try replacing it with a call to an algorithm. The largest wins are almost never micro-optimizations:

- **Know the complexity of what you call.** `Array.remove(at:)` is O(n); calling it in a loop is O(n²). `removeAll(where:)` is O(n) total. Building a `Data` by re-slicing per byte is O(n²); `popFirst()` is O(1). Both of these were 100×+ regressions hiding behind clean-looking code.

---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
