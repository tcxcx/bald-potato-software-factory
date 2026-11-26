---
name: tiger-mode
description: "Apply TigerBeetle's TigerStyle to systems design, implementation, and review. Use for /tiger-mode or requests for TigerStyle."
---

# Tiger Mode

Prioritize safety, then performance, then developer experience. Apply these checks within the current Poteto Mode playbook and the requested scope.

## Safety

- Name the state owner and the invariant each transition preserves. Keep branching and mutation in that owner. Use pure helpers for calculations and keep state close to where it is used.
- For finite work, use iterative control flow with a visible upper bound. Derive limits on batches, queues, input sizes, retries, and waits from the operation's capacity or requirements. Specify what happens at the limit, such as backpressure, a continuation, or a returned error. For an event loop, bound the work it admits per turn.
- Validate external data at the boundary and handle expected errors explicitly. Use assertions for internal invariants. If an invariant fails, stop the operation before making further state changes. Where a property can break between two boundaries, check it at both, such as before writing a record and after reading it back. Check constant relationships at build time where possible.
- Give indexes, counts, and byte sizes distinct roles. Put units in names or types. Use checked conversions and make rounding explicit. Exercise the last valid value, the first invalid value, and the state left behind by a failure.

## Performance

- Estimate operation frequency, bytes moved, and latency across network, storage, memory, and CPU before choosing a design. Investigate the resource that dominates total cost at the expected load.
- Batch expensive operations within the stated limits. Make allocation and copying visible on hot paths. Measure the behavior before claiming a performance improvement.

## Developer experience

- Use the domain's nouns and verbs. Keep policy-bearing options, such as timeouts and retry limits, visible at the call site. Explain the reason for a surprising invariant or limit.
- Follow the repository's conventions. Weigh each new dependency or abstraction against its safety and maintenance cost. In a review, point to the affected code, the condition that breaks, and the observable result.

Follow the full upstream guide for TigerBeetle changes and requests for strict TigerStyle. For other codebases, apply these checks using the project's language and runtime. [TigerStyle](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md)
