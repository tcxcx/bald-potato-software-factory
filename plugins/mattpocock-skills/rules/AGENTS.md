# Matt Pocock Skills + Bald Potato Software Factory — Always-On Rule for Antigravity

You MUST always preload and operate with **Matt Pocock's Engineering, Productivity, and Software Factory skills (`mattpocock-skills@4ae2317`)** alongside **Poteto Mode (`pstack`)** as a unified **Bald Potato Software Factory**.

All Matt Pocock skills live at `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/<name>/SKILL.md` and are available via `/<name>` slash commands and model invocation.

## 1. Software Factory Architecture (`/software-factory`)

When designing, building, or running a software factory (a system of agents turning tickets, PRs, and schedules into merged, deployed code), enforce the canonical vocabulary from `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/software-factory/SKILL.md`:

- **Tasks & Runs**:
  - **Task**: A kind of work the factory performs, defined once and run many times (review, explore, implement, ratchet). Avoid: *job, workflow, action*.
  - **Trigger**: The event that starts a run (ticket tracker change, git host change, orchestrator clock, or another run).
  - **Run**: One execution of a task on one runner from trigger to finish, treated as a black box. Never waits in-session for a human; human changes to the ticket tracker or git host trigger a new run. Avoid: *session*.
  - **Runner**: The disposable machine a run executes on. Only memory across runs is the ticket tracker, git host, and orchestrator. Avoid: *server, host, box, compute, sandbox*.
- **Service Slots**:
  - **Ticket tracker** (avoid: *issue tracker, ticket manager, project board*)
  - **Ticket source** (avoid: *data source, trigger source, intake*)
  - **Git host** (avoid: *code host, forge, repo*)
  - **Orchestrator** (avoid: *dispatcher, scheduler, control plane*)
  - **Observability platform** (avoid: *observability, logs, monitoring, dashboard*)
- **Three Brakes on Every Accelerator**:
  1. **Automated checks**: Deterministic gates (types, lint, tests) that every run must pass.
  2. **Automated review**: Separate cold review of the diff against codebase standards and the ticket (`/code-review` + `/interrogate`).
  3. **Human review**: Human reads the PR before merge; catches become new automated checks and sharper automated review (`/retro` + `/correct`).

## 2. The Main Engineering Flow (`idea -> ship`)

Combine Matt Pocock's flow (`/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/ask-matt/SKILL.md`) with Poteto's playbooks:

1. **Align & Model the Domain (`/grill-with-docs`, `/grill-me`, `/domain-modeling`, `/wayfinder`)**:
   - Maintain a project `GLOSSARY.md` (ubiquitous language) and ADRs so code, tests, and conversations share exact domain terms.
   - For huge, multi-session foggy efforts, chart decision tickets with `/wayfinder`.
2. **Settle Empirical Questions (`/prototype`)**:
   - Build throwaway prototypes (`/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/prototype/SKILL.md` and Poteto's `prototype` playbook) to settle state, logic, or UI questions by running code rather than guessing.
3. **Design Deep Modules (`/codebase-design`, `/architect`, `/improve-codebase-architecture`)**:
   - Design **deep modules**: a lot of behavior hidden behind a small, simple interface at a clean **seam**, testable through that public interface.
4. **Spec & Tracer-Bullet Tickets (`/to-spec`, `/to-tickets`)**:
   - Synthesize aligned designs into a spec (`/to-spec`) and break multi-step work into vertical tracer-bullet tickets with explicit **blocking edges** (`/to-tickets`).
5. **Build via Red-Green-Refactor at Seams (`/implement`, `/implement-spec`, `/tdd`)**:
   - Drive `/tdd` (`/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/tdd/SKILL.md`) one vertical slice at a time at pre-agreed public seams. Never write horizontal bulk tests or implementation-coupled mocks.
   - For parallel ticket graphs, `/implement-spec` runs implementer subagents (`invoke_subagent`) across the ready frontier on an integration branch.
6. **Two-Axis Review + Adversarial Verification (`/code-review`, `/interrogate`, `/no-comments`, `/pr`)**:
   - Run `/code-review` across two independent subagent axes (**Standards** + **Spec**), strip unnecessary comments (`/no-comments`), prove behavior against the real artifact, and shape PRs with visual summaries, before/after evidence, and one-way/two-way door blast-radius calls (`/pr`).
7. **Diagnose & Ratchet the Environment (`/diagnosing-bugs`, `/retro`, `/correct`)**:
   - For bugs, `/diagnosing-bugs` establishes a tight red feedback loop before hypothesizing or instrumenting.
   - Close out sessions with `/retro` and `/correct` to turn mistakes into deterministic checks, types, lint rules, and steering docs.

## 3. Available Matt Pocock Skills Index (`/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/`)

- **Engineering**: `ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`, `implement`, `implement-spec`, `improve-codebase-architecture`, `pr`, `prototype`, `research`, `retro`, `setup-matt-pocock-skills`, `tdd` (`matt-tdd`), `to-spec`, `to-tickets`, `triage`, `wayfinder`, `wizard`
- **Productivity**: `grill-me`, `grilling`, `handoff`, `teach` (`matt-teach`), `to-questionnaire`, `wait-what`, `writing-for-agents`
- **Software Factory & In-Progress**: `software-factory`, `bald-potato`, `loop-me`, `claude-handoff`, `setup-ts-deep-modules`, `writing-beats`, `writing-fragments`, `writing-shape`
- **Misc**: `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit`
