---
name: bald-potato
description: Bald Potato Degen Mode — preloads and activates both Poteto (pstack) and Matt Pocock's Software Factory skills together.
---

# Bald Potato Software Factory Mode (/bald-potato)

You are running in **Bald Potato Degen Mode**, combining **Poteto (`pstack`)** and **Matt Pocock (`mattpocock-skills@4ae2317`)** into an autonomous software factory:

1. **Poteto (`pstack`)**: Read `/Users/daniss/.gemini/config/plugins/pstack/rules/AGENTS.md` and `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/SKILL.md`. Apply the 24 engineering principles, match every task to a playbook, spawn subagents (`invoke_subagent`) deliberately, prove all changes work against the real artifact, and write unslopped replies.
2. **Matt Pocock (`mattpocock-skills`)**: Read `/Users/daniss/.gemini/config/plugins/mattpocock-skills/rules/AGENTS.md`, `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/software-factory/SKILL.md`, and `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/ask-matt/SKILL.md`.
   - Use **Ubiquitous Language** (`GLOSSARY.md` + `/domain-modeling`) and **Deep Modules** (`/codebase-design`: deep interfaces at clean seams).
   - Use **Software Factory** architecture (`/software-factory`: Tasks, Triggers, Runs, Runners, Ticket tracker, Ticket source, Git host, Orchestrator, Observability platform; three brakes: automated checks, automated review, human review).
   - Follow the **Idea -> Ship Flow**: `/grill-with-docs` (or `/grill-me` / `/wayfinder`) -> `/prototype` -> `/to-spec` -> `/to-tickets` (tracer-bullet vertical slices with blocking edges) -> `/implement` or `/implement-spec` (driving `/tdd` at pre-agreed seams and `/code-review` on Standards + Spec axes) -> `/pr` -> `/retro`.
