# Final-instance QA gate (`petrkindlmann/qa-skills`)

Run this gate at the end of implementation on every code-shipping task in `poteto-mode` and `bald-potato` (`Feature`, `Bug fix`, `Refactoring`, `Perf issue`, `Autonomous run`, `Autopilot-full`, `Autopilot-stack`, `Multi-phase plan`, and `Shipping`), after `/no-comments` and before `Opening a PR` or declaring done.

## Paths across harnesses

- **Skill files (50 skills).** `~/.agents/skills/<skill>/SKILL.md`, `~/.gemini/config/plugins/bald-potato-arsenal/skills/<skill>/SKILL.md`, `~/.claude/skills/<skill>/SKILL.md`, and `~/.cursor/skills/<skill>/SKILL.md`.
- **Executable QA runner and oracle gate.** `~/.gemini/config/plugins/qa-skills` (Antigravity / Gemini), `~/.claude/bald-potato/plugins/qa-skills` (Claude Code), or `~/.cursor/bald-potato-software-factory/plugins/qa-skills` (Cursor). Resolve `<qa-skills>` to whichever checkout exists on disk.

## Step 1. Load project QA context and route 1 to 2 precision skills

1. Check `.agents/qa-project-context.md` in the target repository. Read it if populated. Ignore unpopulated template placeholders and infer stack, runners, and targets from `package.json`, lockfiles, CI configs, and existing tests.
2. On a repository with zero tests and no QA setup, run `qa-start` (`qa-project-context` then `test-strategy` then `test-planning`). When onboarding onto an existing suite, use `qa-project-bootstrap`.
3. Preview routing and discovered checks without mutating files:
   `node <qa-skills>/scripts/qa.mjs plan --project <repo-or-app-path> --goal "<user goal>"`
4. Pick **1 to 2 precision skills** matching the exact artifact changed, read their `SKILL.md`, and execute their domain checklist. Never stack 3 or more skills. Use `qa-do` only when no direct row below matches:

| Changed artifact or risk | Primary skill (1st) | Companion skill (2nd, only if needed) |
| --- | --- | --- |
| Browser UI, sheets, forms, multi-step flows | `playwright-automation` (scripted E2E) or `agentic-browser-testing` (goal-driven accessibility-tree E2E) | `accessibility-testing` (WCAG 2.2 AA, keyboard, ARIA) or `visual-testing` (screenshot diff) |
| UI redesign breaking existing locators | `selector-drift-recovery` | `test-reliability` (single runtime flake) |
| AI, LLM, agentic tools, prompts, RAG, stream healing | `ai-system-testing` (tool-call validation, prompt regression, grounding, indirect injection detector) | `contract-testing` or `api-testing` |
| Payments, checkout, billing, 3DS, webhooks, ledgers | `payment-testing` (PSP sandbox, idempotency, webhook replay, partial failure) | `database-testing` (migrations, constraints, ACID invariants) |
| HTTP APIs, GraphQL, RPC, webhooks, outbound channels | `api-testing` | `contract-testing`, `email-testing`, or `analytics-tracking-testing` |
| Auth, permissions, untrusted input, compliance | `security-testing` (pair with `/security-audit`) | `compliance-testing` (GDPR, EAA, AI Act, consent) |
| Native mobile or multi-engine browser matrices | `mobile-testing` (iOS/Android simulators, Maestro/Detox) | `cross-browser-testing` |
| Latency, bundle size, worker throughput, regressions | `performance-testing` (pair with `/benchmark-checklist`) | `observability-driven-testing` |
| Defect report or CI failure batch | `bug-reproduction` (single minimal repro + failing test) or `ai-bug-triage` (batch CI log clustering) | `quality-postmortem` |
| Infra, flaky external APIs, test fixtures, CI wiring | `test-data-management`, `service-virtualization`, or `test-environments` | `ci-cd-integration` or `chaos-engineering` |
| Pre-merge stack, canary rollout, post-deploy SLA | `risk-based-testing` | `release-readiness`, `testing-in-production`, or `synthetic-monitoring` |

## Step 2. Audit authored and touched tests (`ai-qa-review`)

1. Run `ai-qa-review` across every test file created or edited in the task. Eliminate tautological assertions, implementation-coupled mocks, arbitrary sleeps, shared mutable fixture state, and weak error checks (`unit-testing` and `coverage-analysis` for gaps, `test-suite-curation` when pruning redundant suites).
2. Whenever the diff adds or changes a parser, validator, detector, middleware, or gate, execute both a **known-good** input and an **intentionally broken** input so vacuous passes cannot slip through.

## Step 3. Execute bounded checks and enforce the two-attempt repair cap

1. Run the bounded QA runner alongside the repository's targeted test, typecheck, and lint gates:
   - Suite run: `node <qa-skills>/scripts/qa.mjs run --project <repo-or-app-path> --goal "<user goal>"`
   - Live URL + WCAG 2.2 AA browser check (when a local or preview server runs):
     `node <qa-skills>/scripts/qa.mjs run --project <repo-or-app-path> --url <http-url> --ready-selector '<app-owned-ready-selector>' --goal "<user goal>"`
     Set `QA_BROWSER_EXECUTABLE` when pointing at an installed system Chrome binary. An HTTP 200 shell, login redirect, or blank body is not passing evidence.
2. Inspect `report.html` and `result.json` when `qa.mjs run` executes, or record exact command, candidate SHA, environment, and counts when running workspace test runners directly (such as `bun test` or `vitest`).
3. **Bounded repair loop.** If an executed check fails:
   - Reproduce the failure and keep the failing assertion intact.
   - Repair application code within authorized task scope.
   - Re-run both the failing check and its healthy control.
   - **Stop after 2 unsuccessful repair attempts** and report the exact blocker. Never delete an assertion, widen an allowlist, or add retries to turn a red check green.

## Step 4. Enforce verdict accounting and autonomous oracle gates

1. **Verdict separation.** Every final report and PR `## Verification` block must distinguish **authored**, **executed**, **passed**, **failed**, **skipped**, **blocked**, and **unrun** checks. Zero tests, skipped tests, mocked-only external boundaries, or pass-on-retry flakes stay `incomplete` or `blocked`, never `PASS`.
2. **Independent oracle gate for autonomous runs.** In `Autonomous run`, `Autopilot-full`, `Autopilot-stack`, `Orchestrate`, and `Shipping`, model self-reports never establish `passed: true`. When an oracle config is present, run:
   `node <qa-skills>/scripts/agent-result-gate.mjs --config <oracle-config.json> --agent-result <agent-result.json> --output <gate-verdict.json>`
3. **Human-readable QA reporting.** Format QA summaries with `qa-report-humanizer` and `/unslop` so evidence reads as concrete commands, counts, and user-observable outcomes (`qa-metrics` and `qa-dashboard` when tracking suite health over time).

## Completion criterion

The gate is complete only when:
- The 1 to 2 selected `qa-skills` and `ai-qa-review` have been applied to the diff and its tests.
- All runnable checks have executed at the current head SHA (exit `0` with observed assertions, or a bounded 2-attempt blocker recorded).
- Passed, failed, skipped, blocked, and unrun checks are explicitly separated in the verification record.
