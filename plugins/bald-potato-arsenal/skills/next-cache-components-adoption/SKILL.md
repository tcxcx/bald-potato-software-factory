---
name: next-cache-components-adoption
description: >
  Turn on Cache Components in a Next.js app and resolve the blocking routes it
  surfaces. Use when the user wants to enable, adopt, or migrate to Cache
  Components, flip the `cacheComponents` flag, work through a flood of
  blocking-prerender / instant validation errors, run the
  `cache-components-instant-false` codemod, or decide between opting routes out
  with `export const instant = false` and fixing them in place.
---

# next-cache-components-adoption

Enable Cache Components on an app and walk it to a passing build. This skill sequences the work; per-error recipes live in the dev overlay fix cards and the build's terminal output. The [migrating to Cache Components guide](https://nextjs.org/docs/app/guides/migrating-to-cache-components) is the canonical reference for the concepts and per-API recipes this skill applies — consult it whenever the skill steps reference a pattern (`"use cache"`, `cacheLife`, `<Suspense>` placement, etc.) and you want the full explanation.

## requires

- **App Router project.** Cache Components is an App Router feature; `cacheComponents: true` does nothing for `pages/` routes. If the project has a `pages/` or `src/pages/` tree but no `app/` or `src/app/` tree, stop and tell the user — Pages → App migration is its own project, not part of this skill. A hybrid app (both `pages/` and `app/`) is fine: the flag affects the `app/` routes; `pages/` routes are unaffected and don't need opt-outs.

- **A resolved app directory.** Locate `next.config.{js,ts,mjs,cjs}` first: that's the project root, and an agent invoked from a subdirectory would otherwise test for `app/` against the wrong `cwd` and find nothing. Look for `app/` and `src/app/` under it, and treat every command and glob in this skill as relative to whichever one exists. If both exist, Next.js builds `app/` and never looks at `src/app/`, so its routes are shadowed and unbuilt — tell the user that and ask which tree to migrate instead of picking one.

- **A runnable app.** The whole loop verifies against `next dev` and a browser, so the app has to boot. If it reads a database or required env at import (e.g. an `env.ts` that throws on a missing `DATABASE_URL`), confirm it actually starts — with the real environment, or local data you stand up — before step 1. Adoption can't be verified against an app that won't run.

- **Next.js 16.3 or later.** That release is where the pieces this skill relies on land: top-level `cacheComponents`, `export const instant`, the dev-overlay instant-navigation validation warnings, and the `cache-components-instant-false` codemod. If `next --version` reports below 16.3, upgrade first:
  - `npx @next/codemod@latest upgrade latest` to apply the version-to-version codemods.
  - Read the relevant [version upgrade guide](https://nextjs.org/docs/app/guides/upgrading) (e.g. [Version 16](https://nextjs.org/docs/app/guides/upgrading/version-16)) for what the codemod doesn't cover.

- **No incompatible config keys.** `cacheComponents: true` errors on any file that still exports `dynamic`, `revalidate`, or `fetchCache`. Inventory these exports before running the codemod, then follow the [migration guide's per-key sections](https://nextjs.org/docs/app/guides/migrating-to-cache-components). The guide is the source of truth for translating each value. The `cache-components-instant-false` codemod does not remove these configs.

- **`experimental.dynamicIO` is fatal.** It was renamed to top-level `cacheComponents` and the old key now aborts before any build can run — remove it (or replace with `cacheComponents: true`) first. `experimental.useCache` is still accepted as a deprecated alias; redundant once `cacheComponents: true` is set, so remove it for clarity.

### notes

- **No passing baseline before the flag.** If the app already uses `"use cache"`, the pre-flag build errors with `please enable the feature flag cacheComponents`. Enabling the flag is the first thing you do (in Incremental, before the codemod; in Direct, before fixing routes) — not a thing to do _after_ getting a passing build. Note this in your starting summary so it doesn't read as a regression.

- **Existing caches can stay.** Follow the migration guide's [`fetch` and `unstable_cache` sections](https://nextjs.org/docs/app/guides/migrating-to-cache-components#fetch-cache-options). Do not rewrite them solely to enable Cache Components.

- **Offline docs.** Guide links have offline copies under `node_modules/next/dist/docs/` (bundled since Next.js 16.2), with the directory layout numbered for ordering (e.g. `node_modules/next/dist/docs/01-app/02-guides/migrating-to-cache-components.md`). If you can't predict the numbered prefix, `find node_modules/next/dist/docs -name '<slug>.md'` resolves it. The `/docs/messages/*` error pages are not bundled.

- **Older versions without bundled docs.** Suggest `npx @next/codemod@latest agents-md` to the user before starting: it downloads a version-matched copy to `.next-docs/` and writes an index into `AGENTS.md`. It touches files in their repo, so ask first and run it only if they want it.

## the shape of the work

There's one loop: walk the route tree top-down, one feature at a time, adopting each route against `next dev` + a browser. The build is a final check for each feature, not the working surface.

The choice in step 1 is whether to opt every route out of validation first or fix routes as you go. Either way the loop is the same:

- **With a quiet pre-step (Incremental).** Run the codemod, fix what it can't, and fully migrate routes that previously required static rendering. Other routes keep their opt-outs for follow-up PRs.
- **Without (Direct).** Enable `cacheComponents` and start the loop on whatever the build flags first. Same loop, but every fix sits on one branch until adoption is complete.

In both, the per-route success bar is the same: **dev loop reports no errors AND `next build` passes**. Check in with the user after every feature, and suggest a commit but never make one without their confirmation. Expect to spend most of the time in the loop, not in the pre-step.

## background

`cacheComponents: true` requires every route to be prerenderable. A route that reads request-time data outside `<Suspense>` is "blocking" and fails the build. `export const instant = false` marks a route as allowed to block, which clears it in both dev and build; on a layout it covers the whole subtree during the build, but client navigations still validate each descendant segment on its own. Reads wrapped in a [`"use cache"`](https://nextjs.org/docs/app/api-reference/directives/use-cache) function count as cache boundaries, not blocking reads.

When a fix introduces `"use cache"`, follow the Caching guide for [choosing a data-level or UI-level boundary and setting its lifetime](https://nextjs.org/docs/app/getting-started/caching#usage) and [revalidating after mutations](https://nextjs.org/docs/app/getting-started/revalidating). Use the [`use cache` cache-key reference](https://nextjs.org/docs/app/api-reference/directives/use-cache#cache-keys) when the result varies by arguments or captured values.

Three classes of blocker come up, usually in this order:

Whenever a fix introduces `<Suspense>`, follow the Streaming guide's [granular streaming pattern](https://nextjs.org/docs/app/guides/streaming#granular-streaming-with-suspense) and [guidance for preventing CLS](https://nextjs.org/docs/app/guides/streaming#cls-cumulative-layout-shift).

1. **Request-time reads** (`cookies()`, `headers()`, `await params`, `await searchParams`). All four block when awaited at the top of a page or layout. `params` and `searchParams` often get missed because they're not framed as "request data" the way cookies and headers are. The fix is to push the read into a `<Suspense>`-wrapped child — and for `params`/`searchParams`, forward the promise into the child and await it there; don't `await` at the page top.
2. **Sync-IO at module/render time** (`new Date()`, `Date.now()`, `Math.random()`, `crypto.randomUUID()`). These fail the build even with `instant = false` — the opt-out doesn't suppress them. If they're in a shared layout, they block every route under it. The codemod can't fix them; after running it, use each build error and its linked documentation to identify which reported calls to translate by hand (see the [incremental pre-step](#incremental)).
3. **`"use cache"` files that read request data.** A file with a top-level `"use cache"` directive can't export `instant`; combining the two errors with `Only async functions are allowed to be exported in a "use cache" file.`, which means the directive was wrong for that route. Remove it before running the codemod.

## working surfaces

### finding blocking routes

Prefer `next dev` over `next build` while you work.

- **`next dev`** — the working surface. Visit a route; its blocking errors surface in the dev overlay with full stack traces and fix cards linking the per-error docs. Work one route at a time — errors don't accumulate in one place. The route itself still returns HTTP 200, so read the overlay (or `.next-dev.log`), not status codes. A cleared overlay is one half of calling a route clean — the other half is browser verification (see [step 2](#step-2-the-inner-loop-remove-opt-outs-one-feature-at-a-time)) and a passing build for that route.
- **`next build`** — detection only. The build is `next dev`'s authoritative check, not its replacement. Use it as the last gate on each feature in the loop (a passing build is part of the per-route success bar) and as the final verification across the whole app. In Incremental, the build also confirms the pre-step (codemod opted every route out, no shared layout still has a sync-IO blocker) before you ship that PR. Don't reach for the build instead of the dev loop while you're working a route — a passing compile doesn't tell you what ended up in the static shell and what streamed. By default the build stops at the first blocking route, so it's also poor for sizing the work. Two flags help when iterating: `--debug-build-paths` builds only the routes you name (comma-separated glob patterns of file paths relative to the project root, e.g. `--debug-build-paths="app/admin/**/page.tsx"` — not URL paths; `--debug-build-paths="app/(marketing)/about/page.tsx"` — not `/about`; `--debug-build-paths="app/admin"` matches nothing and silently builds zero routes), and `--debug-prerender` disables the early exit so the build continues past the first prerender failure, reports every blocking route, and prints a fuller stack trace that names the originating file and line.

Every blocking error has a docs page — open it. Both the dev overlay and the build terminal print a `https://nextjs.org/docs/messages/<slug>` link with each error. That page is the canonical recipe for the fix; the inline message is a summary. Fetch the link for every distinct error you encounter, even if you think you know the pattern — the recipes evolve, and the same error class can have different correct fixes depending on what the route reads. Don't improvise from the inline message alone. (`/docs/messages/*` pages aren't bundled offline; if you have no network, fall back to the per-API guides under `node_modules/next/dist/docs/` and note the limitation when you report back.)

### verifying each fix at runtime

A passing build or a cleared overlay isn't proof the route actually behaves — Cache Components is a runtime concern (a static shell with streamed data). Verify after every fix, not only at the end.

In preference order:

1. **[`next-dev-loop`](https://github.com/vercel/next.js/tree/canary/skills/next-dev-loop) — strongly preferred.** Cross-checks `/_next/mcp` against the live browser via `agent-browser` and surfaces both compile and runtime issues in one pass. The diagnostics (React tree, suspense boundaries, console + network) are richer than poking at `next dev` by hand.

   Install it before starting the loop. Don't wait until you hit something `next dev` alone can't explain. It ships alongside this skill, so check whether it is already available first, and install it only if it is not:

   ```bash
   npx skills add https://github.com/vercel/next.js/tree/canary/skills/next-dev-loop
   ```

   The skill states its required `agent-browser` version and walks you through it.

   **Requires Turbopack.** If `package.json`'s `dev` script passes `--webpack`, flag it to the user and ask whether there's a reason to stay on webpack. If not, switch to Turbopack (the Next.js 16.3+ default). If they want to keep webpack, skip this install and use the [build-only loop](#the-loop-build-only-fallback) instead.

   You don't need permission to install `next-dev-loop` itself. It's a tool, like installing a dev dependency. If a user is present, briefly tell them you're installing it for verification. In a non-interactive run (CI, dashboard, sandbox), install it without asking — "can't prompt the user" is not a reason to skip. The only legitimate skip is a real technical blocker: no network, no npm, read-only filesystem, a stated no-new-deps policy, or a webpack-only dev script. If you skip, name the specific blocker in your final report.

2. **A browser you can drive yourself.** Playwright, `agent-browser` directly, any browser-automation tool. Use only when `next-dev-loop` is genuinely blocked. You'll miss the framework-side checks (`/_next/mcp`), so DOM assertions alone don't catch every regression — be more cautious about what you call "verified."

3. **Build-only.** If you can't run a dev server at all, the build is your only signal. `○ (Static)` routes with no `<Suspense>` are fully verified by the build (nothing streamed to test). `◐ (Partial Prerender)` routes are only shell-verified — flag them when you report back.

4. **No tooling at all.** Ask the user to run the dev server (or build) and report what they see, or hand off the milestone you've reached.

## step 1: choose a strategy

Ask the user, in terms of the PRs they want, not the size of the job. Never use the internal labels (Incremental, Direct) when talking to the user — those are your own scaffolding. Ask in terms of PRs and features, e.g.: _"Do you want me to first open a PR that turns on Cache Components and opts every route out of validation, then handle the actual route adoptions feature-by-feature in follow-up PRs? Or do everything on one branch?"_ Even on a tiny app, the incremental path still has value (review-sized PR, revertible, the `// TODO: Cache Components adoption` markers double as your work queue for next session). Don't pick on their behalf.

If there's no user to ask, default to **Incremental** and document the choice.

Honor an explicit choice in the request. If the user asks to migrate incrementally and also asks you to complete the migration, establish and verify the incremental checkpoint before continuing to the remaining routes in the same task. “Complete” sets the stopping point; it does not change the chosen strategy.

- **Incremental** — quiet pre-step + the loop. Run the codemod to opt every page and layout out of validation, get the build passing, stop and check in with the user (see [end of the pre-step](#end-of-the-pre-step-check-in)), then enter [step 2's loop](#step-2-the-inner-loop-remove-opt-outs-one-feature-at-a-time) and ship each feature as a follow-up PR.
- **Direct** — skip the pre-step. Enable `cacheComponents` and go straight to [step 2's loop](#step-2-the-inner-loop-remove-opt-outs-one-feature-at-a-time); the build's blocking routes are the work queue.

### incremental

Before invoking the codemod, grep for `^export const (revalidate|dynamic|fetchCache)` across the app directory and follow the migration guide for every match. Mark routes that use `dynamic = 'force-static'` or `dynamic = 'error'` for full migration in this PR. The codemod does not remove incompatible configs.

The codemod refuses to run on a dirty working tree. Commit or stash unrelated work first, or pass `--force` to let its edits land alongside your WIP. Common false positive: if you recently upgraded Next.js, `package.json` and the lockfile will already be dirty — commit those first.

```bash
npx @next/codemod@latest cache-components-instant-false ./app
```

Pass the app directory you resolved in [requires](#requires). A wrong path is not an error: it reports `0 ok` and exits `0`, so read the file count and treat zero as a failed run, not an adopted app.

Inserts `export const instant = false` (with a `// TODO: Cache Components adoption` comment) into every `{page,layout,default}` file under that directory, skipping files that already declare `instant` and any module marked `"use client"` or `"use server"`. Then set `cacheComponents: true`. The TODO comments are the work queue for the loop.

If the codemod isn't available (older `@next/codemod`, sandboxed environment, offline run), reproduce it by hand: for every `{page,layout,default}.{js,jsx,ts,tsx}` in the app directory that isn't `"use client"` or `"use server"` and doesn't already declare `instant`, insert this after the imports:

```ts
// TODO: Cache Components adoption. Refactor this route so this opt-out can be removed.
// See: https://nextjs.org/docs/app/guides/migrating-to-cache-components
export const instant = false
```

The codemod opts every segment out, not only the root, on purpose. Resolution is top-down, first-explicit-config-wins: the highest `instant = false` decides the whole subtree. With an opt-out on every segment, removing one segment's opt-out validates only that segment; descendants keep their own opt-outs and stay passing. If only the root were opted out, removing it would re-arm validation for the entire app at once.

Because the highest opt-out wins, remove them top-down (root layout first, then descend). Removing a leaf's opt-out does nothing while an ancestor still holds one.

Remove the opt-outs from the previously static routes and any shared segments that mask their validation. Resolve their errors and confirm they still prerender. A cached data call alone does not prove the route remains static.

Next, run `next build` to surface blockers the codemod could not handle. The build is the proof, not the codemod run — a shared layout that calls `new Date()` / `Math.random()` directly still fails regardless of the opt-out (see [background](#background)). If the normal build reports a sync-IO error without locating the call, rerun that route with `next build --debug-prerender --debug-build-paths="app/path/to/page.tsx"`. For each sync-IO error it reports:

1. **Sync-IO at module/render time.** Use the route, originating file and line, and `/docs/messages/` link in the build output to locate the error. If needed, grep the whole repo for `new Date()`, `Date.now()`, `Math.random()`, and `crypto.randomUUID()` (not only `app/**/layout.{js,jsx,ts,tsx}` — the read might live in any component imported by a layout). Do not change unreported matches. Apply the appropriate option from the linked error page, then add this comment above a temporary boundary introduced only to unblock the build:

   ```tsx
   // TODO: Cache Components adoption. Added to unblock the build: remove this boundary to re-trigger the error and review the documented options.
   ```

   It shares the `TODO: Cache Components adoption` prefix with the comments the codemod writes, so the check-in grep finds both. Removing the boundary makes the error fire again with its fix cards — the same motion as removing an opt-out in the loop.

After each fix, rerun the scoped build when available, then run `next build` again to find the next blocker. Repeat until the normal build passes.

After the build passes, confirm every deferred route is still covered by an opt-out and no shared opt-out covers a previously static route. If the app has no previously static routes and the root layout remains deferred, confirm it got an opt-out (`grep -n "export const instant" <app dir>/layout.*`). The root layout renders every route, including framework routes like `/_not-found`, so if it was missed, add `export const instant = false` to it by hand.

Synthetic routes like `/_not-found` have no user file — when they block, fix the root layout's opt-out, not the synthetic route. Client Components (`"use client"`) get no opt-out (it's a build error to export `instant` from them), but they are not a rare blocker. The high-frequency case is a client component in the root layout's nav or header calling `usePathname()`/`useSearchParams()`: it blocks _every_ dynamic route with `blocking-prerender-client-hook`, and static routes pass (the pathname is known at prerender), which masks it until you reach a dynamic segment. It's not an ancestor-data fix — follow the [error's docs page](https://nextjs.org/docs/messages/blocking-prerender-client-hook) for the `<Suspense>` recipe. Only when a client route blocks on _server_ data do you fix that data in its ancestor.

### end of the pre-step: check in

Incremental only. The pre-step is the shippable PR. Record the passing checkpoint before starting step 2. Unless the user already asked you to continue through the full migration in the same task, stop and check in. Talk to the user in their language; don't say "Incremental" or other internal labels; talk about adoption, PRs, and what the app does now. Tell them:

- What you did: turned on Cache Components, ran the codemod, migrated the previously static routes, fixed the remaining blockers, and confirmed the build passes.
- What changed: the previously static routes still prerender. Other pages and layouts keep a `// TODO: Cache Components adoption` opt-out.
- What to sanity-check: the previously static routes stay fully prerendered and prefetchable, and request-specific data on the deferred routes remains request-specific.
- The question: "Want to open this as its own PR before we start adopting Cache Components route by route? Or keep going on this branch?" Wait for the answer.

If the user already asked you to complete the migration, continue after recording this checkpoint instead of asking the same question again.

### direct

Set `cacheComponents: true` and move to [step 2](#step-2-the-inner-loop-remove-opt-outs-one-feature-at-a-time). The build's blocking routes are the work queue.


---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
