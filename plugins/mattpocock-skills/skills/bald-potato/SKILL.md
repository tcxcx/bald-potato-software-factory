---
name: bald-potato
description: Bald Potato Degen Mode. preloads and activates Poteto (pstack), Matt Pocock's Software Factory skills, and the 50-skill petrkindlmann/qa-skills Final-Instance QA Gate together.
---

# Bald Potato Software Factory Mode (/bald-potato)

You are running in **Bald Potato Degen Mode**, combining **Poteto (`pstack`)**, **Matt Pocock (`mattpocock-skills@4ae2317`)**, and **QA Skills (`petrkindlmann/qa-skills`)** into an autonomous software factory:

1. **Poteto (`pstack`)**: Read `/Users/daniss/.gemini/config/plugins/pstack/rules/AGENTS.md` and `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/SKILL.md`. Apply the 24 engineering principles, match every task to a playbook, spawn subagents (`invoke_subagent`) deliberately, prove all changes work against the real artifact, and write unslopped replies.
2. **Matt Pocock (`mattpocock-skills`)**: Read `/Users/daniss/.gemini/config/plugins/mattpocock-skills/rules/AGENTS.md`, `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/software-factory/SKILL.md`, and `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/ask-matt/SKILL.md`.
   - Use **Ubiquitous Language** (`GLOSSARY.md` + `/domain-modeling`) and **Deep Modules** (`/codebase-design`: deep interfaces at clean seams).
   - Use **Software Factory** architecture (`/software-factory`: Tasks, Triggers, Runs, Runners, Ticket tracker, Ticket source, Git host, Orchestrator, Observability platform; brakes: automated checks + QA gate, automated review, human review).
   - Follow the **Idea -> Ship Flow**: `/grill-with-docs` (or `/grill-me` / `/wayfinder`) -> `/prototype` -> `/to-spec` -> `/to-tickets` (tracer-bullet vertical slices with blocking edges) -> `/implement` or `/implement-spec` (driving `/tdd` at pre-agreed seams and `/code-review` on Standards + Spec axes) -> **Final-Instance QA Gate** -> `/pr` -> `/retro`.
3. **Final-Instance QA Gate (`petrkindlmann/qa-skills`)**: At the end of every code-shipping implementation (after `/no-comments` and before `/pr` or declaring done), read and run `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/references/qa-gate.md`:
   - Route 1 to 2 precision QA skills (`playwright-automation`, `agentic-browser-testing`, `visual-testing`, `accessibility-testing`, `ai-system-testing`, `payment-testing`, `api-testing`, `contract-testing`, `security-testing`, `performance-testing`, `release-readiness`, or `qa-do` / `qa-start`).
   - Audit newly authored or modified tests with `ai-qa-review` and exercise both known-good and intentionally-broken controls.
   - Run bounded checks via `node /Users/daniss/.gemini/config/plugins/qa-skills/scripts/qa.mjs` (or target suites) with a 2-attempt repair cap (`agent-result-gate.mjs` independent oracle on autonomous runs), separating passed, failed, skipped, blocked, and unrun checks.
