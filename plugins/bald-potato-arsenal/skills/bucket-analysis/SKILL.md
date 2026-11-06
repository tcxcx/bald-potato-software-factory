---
name: bucket-analysis
description: "Analyze a product vision against a codebase by auto-generating feature/theme 'buckets' and scoring each bucket 0–100%. Use when the user asks to 'audit product vs vision', 'do bucket analysis', 'score progress against vision', 'map vision to code', 'find gaps to MVP', or wants a structured gap analysis. Requires a vision document (pasted text or file path). Auto-derives buckets per project — technical themes + UX/UI + visual identity + vision principles — and reports what's missing to reach 100% per theme."
metadata:
  author: tcxcx
  version: "1.0.0"
  argument-hint: <vision-file-or-pasted-vision>
---

# Bucket Analysis

Score how close the current codebase is to the vision's full-featured MVP.
Buckets are **auto-generated per project** from the vision — never hard-coded.
Output is a per-bucket scorecard + concrete closure work to reach 100%.

The skill never invents features that aren't in the vision. If the vision
doesn't mention a bucket, don't create one. If the vision mentions something
vague ("nice UX"), derive concrete criteria from adjacent vision text
(segments, principles, integrations).

---

## The Job

1. **Load the vision.** Read the pasted vision or the file the user points at.
2. **Derive buckets.** Cluster vision content into 8–15 cohesive themes.
3. **Define 100% per bucket.** For each bucket, write 6–12 concrete acceptance
   criteria drawn from the vision itself.
4. **Map evidence.** Search the codebase for each criterion. Mark each
   criterion ✓ done / ◐ partial / ✗ missing with a file:line citation when found.
5. **Score.** `% = (done + 0.5·partial) / total_criteria × 100`. Round to 5%.
6. **Report.** Table + per-bucket detail + prioritized closure plan.
7. **Stop before editing code.** This is an analysis skill, not an implementation skill.

---

## Step 1 — Load the vision

If the user pastes the vision into the prompt, use that.
If they point at a file, `Read` it.
If there's no vision, ask them to provide one — the skill cannot proceed without it.

**Hard requirement:** the vision must fit in 1–3 pages. If the vision is a
30-page manifesto, ask the user to pin the 3 most load-bearing sections. This
skill doesn't do unbounded synthesis.

---

## Step 2 — Auto-derive buckets

Read the vision and cluster its content. Natural seams to look for:

- **Segments / personas** — each segment named in the vision that needs a
  surface gets its own bucket (e.g., "consumer", "agency", "corporate",
  "agent-to-agent").
- **Architecture principles** — each principle with implementation weight
  (e.g., "channel abstraction", "policy-as-code", "stateful sessions",
  "nanopayment metering") gets a bucket.
- **Integrations / "tech stack"** — external services with non-trivial
  surface area (GDS, payments, KYC, channels) get a bucket per service or
  one consolidated integrations bucket.
- **Monetization model** — pricing tables, metering, settlement, payouts.
- **Domain state machine** — if the vision describes a lifecycle
  (searched → held → ticketed → reconciled), that's its own bucket.
- **UX / UI surfaces** — dashboards, channel UIs, onboarding flows.
- **Visual identity / design system** — brand colors, typography, component
  system, iconography, tone.
- **Foundations** — monorepo, runtime, DB, auth, env, CI/CD, deploy.
- **Observability / testing / security** — logs, metrics, traces, error
  tracking, test strategy, rate-limit, bot detection, compliance.

Target **8–15 buckets**. Merge buckets that share acceptance criteria.
Split buckets that collide on ownership boundaries.

**Never auto-generate buckets the vision doesn't justify.** If the vision
never says the word "analytics," do not invent an analytics bucket. If the
vision is silent on a topic that seems load-bearing, flag it in the
"Vision gaps" section of the report instead of smuggling it into a bucket.

### Highest-priority buckets (HP-prefix)

When the vision explicitly signals a "ship first" / "highest priority" /
"this comes before the rest" bucket — prefix it `HP1`, `HP2`, etc. (for
"highest priority") and place those above the standard `B1–B12` sequence.

This is rare. Most visions don't signal priority at this granularity. But
when they do — when a section of the vision says "this is the first
experimental bucket" or "this should ship before broader research tools"
or "this is the killer feature" — honor that signal in the scorecard
ordering.

HP-prefixed buckets get the same scoring discipline as standard buckets:
0–100% against actual codebase substrate, with file:line evidence. They
just sort to the top of the report and the closure plan.

When in doubt, don't add the HP prefix. A standard `B1` is fine.

Example from a real spec: `HP1 Hobby-Aware Concierge`, `HP2 Monocle-Level
Taste Engine` were added because the vision document explicitly framed
them as "first section of experimental backlog" and "new highest-priority
experimental bucket." Without that explicit signal, both would have been
standard buckets.

### Special buckets you should consider per project

- **Visual identity / color** — always a bucket when the vision mentions
  brand, aesthetic, or specific channel tone. Criteria: brand palette
  defined in tokens, semantic colors (success/warn/error), channel-matched
  accents (e.g., WhatsApp green, Slack purple), dark mode, contrast checks.
- **Starter-kit leverage** — if the project uses a known monorepo starter
  (next-forge, t3-turbo, Vercel Platforms, create-turbo), derive a bucket
  that scores "are we using what the starter gives us" vs "are we
  reinventing." This is often where the fastest closure wins live.

### Highest-priority (HP-prefix) buckets

Some buckets are so load-bearing that they should ship before the rest of
the standard sequence. Mark these with an **HP-prefix** (HP1, HP2, …) and
keep them ABOVE the numbered B1–BN buckets in the scorecard.

When to use HP-prefix:

- The bucket produces the strongest demo / "magic" moment for the product.
- It composes from already-shipped primitives (high score / low new construction).
- It unlocks a category of follow-on work that other buckets depend on.
- It carries the lowest external-API or consent risk in the whole scorecard.

If two or more buckets meet these, sequence them HP1, HP2, HP3 in priority
order. The standard B1–BN buckets stay numbered by score, not priority.

Phasing then becomes:
- **Phase 1** = HP1 + foundation (e.g. a feature flag) + 1 cross-cutting B-bucket
- **Phase 2** = HP1 feature-complete + HP2 starts
- **Phase 3** = remaining B-buckets in score order

This keeps the scorecard honest (everything is scored; nothing is hidden)
while making the rollout sequence reflect product judgment, not just
arithmetic.

---

## Step 3 — Define 100% per bucket

For each bucket, write **6–12 acceptance criteria** that are:

- Binary (passes or doesn't)
- Grep-able (nameable as a file, function, env var, route, or schema field)
- Drawn from vision language (use the vision's own nouns and verbs)
- Scoped to MVP (not aspirational post-MVP features)

Bad criteria (skip):
- "Great UX" — not binary
- "Scalable architecture" — not grep-able
- "Future-proof" — not MVP-scoped

Good criteria (keep):
- "`search_flights` MCP tool exposed with Zod schema at /.well-known/mcp"
- "Every agent action writes `session_id, traveler_id, action_type, cost_micro` to structured logs"
- "Brand palette defined as Tailwind tokens in `packages/design-system/tokens.ts`"
- "WhatsApp adapter implements `send(message)`, `receive(webhook)`, `signVerify()`"

### Don't reduce the bucket to mechanical checkboxes

A scorecard with 100% binary acceptance criteria misses product quality.
Some criteria *should* capture taste / judgment / "joie de vivre" — the
non-mechanical signal that distinguishes a directory from a concierge,
a CRUD app from a beloved product. These criteria still need to be
evaluable, just not by simple grep.

Where binary criteria break down:
- "Phoenix introspection strip exists" — grep'able ✓. But: is it readable
  by a non-technical operator at a glance? That needs a *judgment*
  criterion: "Strip uses tabular-nums + hairline borders + ≤3 KPIs at a
  glance" — still grep'able (CSS class names) but anchored on UX intent.
- "Recommendation tool returns top-N" — grep'able ✓. But: are the
  recommendations *good*? That needs a Plurai-eval-shape criterion:
  "Recommendation rubric scores ≥ 0.85 on `aesthetic_alignment` over 30
  golden turns" — anchors the judgment on a measurable rubric.
- "Anticipation message fires" — grep'able ✓. But: would a real human
  find this *useful* vs *annoying*? That needs an outcome criterion:
  "≥ 70% of fired anticipations get a positive reply within 24h, not
  `stop` / `no` / `snooze`" — anchors on observable signal.

Aim for ~80% mechanically grep'able criteria + ~20% judgment-anchored
criteria per bucket. The judgment criteria need an evaluable signal
(rubric, eval gate, outcome metric) — not vibes.

---

## Step 4 — Map evidence

Don't score from memory. Run concrete searches:

- `Glob` for expected file paths
- `Grep` for function/variable/env-var names
- `Read` to confirm implementation vs scaffolding

For large codebases, **dispatch parallel exploration agents** (one per
bucket or one per 2–3 related buckets) so you get clean per-bucket
evidence without polluting the main context.

Each criterion must end up as one of:

- **✓ done** — found + looks production-ready (has tests, wired, error-handled)
- **◐ partial** — found but one of: scaffolded only, missing tests,
  missing error handling, missing wiring into a caller, missing channel
  adapter, feature-flagged off
- **✗ missing** — no evidence found

Cite `file:line` for ✓ and ◐. Citing evidence is what separates this
skill from hand-waving.

---

## Step 5 — Score

`% = round_to_5((done + 0.5 × partial) / total × 100)`

Round *down* to nearest 5%. A bucket with 7/10 ✓, 1 ◐, 2 ✗ scores
`(7 + 0.5)/10 = 75%`.

Stop at 100% only when every criterion is ✓. "Nothing remaining" does not
mean ✓-on-partial; partial is 50% and must be finished.

---

## Step 6 — Report

Output in this exact shape:

```
## Bucket scorecard

| # | Bucket                          | Score | ✓ | ◐ | ✗ |
|---|---------------------------------|-------|---|---|---|
| 1 | Agent engine & session          |  65%  | 5 | 2 | 1 |
| 2 | Channel adapters                |  40%  | 2 | 2 | 4 |
| ...

## Per-bucket detail

### 1. Agent engine & session — 65%
**Criteria** (drawn from: "Architecture principles — stateful sessions"):
- ✓ Session resolves across channels — `packages/agent/session.ts:42`
- ✓ Conversation history persisted — `packages/database/prisma/schema.prisma:120`
- ◐ Preferences attached to session — scaffolded, no write path (`packages/agent/preferences.ts:8`)
- ✗ Session-id addressable via MCP — no mcp adapter lookup found

**To reach 100%:**
1. Wire preferences write path from Duffel booking confirmations.
2. Add `mcp.resolveSessionById(id)` in the MCP adapter.

### 2. Channel adapters — 40%
...

## Vision gaps

Things the vision doesn't cover that the code has or needs anyway
(flag but don't score):
- ...

## Starter leverage

Specific features from the starter that the project should adopt to
close buckets faster:
- ...

## Closure plan

Ordered by (value × ease). Top 5 items that move the most buckets:
1. ...

## External APIs / integrations needed

For each bucket relying on external services, list:
- API name + provider
- Recommended env-var name (project convention)
- Free tier vs paid; quota notes
- Auth shape (key, OAuth, service account)
- Restriction / regulatory notes (e.g., Meta deprecated Basic Display API 2024-12-04)

Example:
| Bucket | API | Env var | Tier | Notes |
|---|---|---|---|---|
| HP1 Hobby-Aware | Google Places API New | `GOOGLE_MAPS_API_KEY` | Paid; $17/1k Text Search | Single GCP project, multiple APIs enabled |
| HP1 Hobby-Aware | Luma Public API | `LUMA_API_KEY` | Free tier | Header: `x-luma-api-key` |
| HP2 Taste Engine | Vertex AI Vision | `GOOGLE_APPLICATION_CREDENTIALS` | Paid per image | Reuses existing Vertex auth; per-tenant cap mandatory |

This is what the user takes to ops/billing to provision keys. It is the
cheapest part of the report to produce and the highest leverage —
without it the user opens a new ticket every time they hit a missing
key. Always include this section when any bucket touches external
services.

## PR phasing (when to use)

Optional sub-section. Only generate when the user asks "how do I sequence
the closure" or when the closure plan has > 5 items and obvious
clustering. Format:

| PR | Buckets touched | Tools / surfaces | Demo hook |
|---|---|---|---|
| PR-1 | B4, B9 | one-liner | "user types X → sees Y" |
| ...

One bucket above 30% with multiple acceptance criteria typically maps to
one PR. A bucket above 50% with > 8 criteria can split into 2-3 PRs.
HP-prefixed buckets always get their own PR sequence (PR-H1, PR-H2…).
```

Keep the report tight. No marketing language. Every claim must have a
file:line or "no evidence found."

---

## Running iteratively

The user usually asks to "reach 100% on each theme." That's a multi-turn
loop:

- Round 1: deliver the scorecard + closure plan.
- Round 2 (only if asked): implement the top closure items, then re-score.
- Round 3+: repeat.

**Do not start implementing in round 1.** The analysis is the
deliverable. Only pick up a hammer when the user says "close the top
items" or similar.

---

## Anti-patterns — don't do these

- **Don't grade on a curve.** A bucket at 40% is 40%, not "promising."
- **Don't pad with aspiration.** If the vision doesn't say it, it's not a gap.
- **Don't ignore the design system / color bucket.** Most engineering
  audits skip these; the vision always has a brand, even if implicit.
- **Don't skip evidence.** A scorecard without file:line citations is
  fiction.
- **Don't auto-split buckets to inflate ✓ count.** 8–15 buckets total; if
  you're above 15 you're over-splitting.
- **Don't write buckets the codebase can't be grep'd for.** If a
  criterion can't be verified in a finite number of searches, rewrite it.
