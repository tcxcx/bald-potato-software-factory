# Cloudflare Security Audit Skill — Always-On Rule for Antigravity

Cloudflare's `security-audit` skill (`/Users/daniss/.gemini/config/plugins/security-audit-skill/skills/security-audit/SKILL.md` and `/Users/daniss/skills/security-audit/SKILL.md`) is preloaded as part of the Bald Potato Software Factory (`--bald-potato-degen-mode`) and available via `/security-audit`.

- **Guidance mode (default)**: For security questions, focused code reviews, or vulnerability triage, apply the boundary-first principles in `/Users/daniss/.gemini/config/plugins/security-audit-skill/skills/security-audit/SKILL.md` (require a concrete lower-trust principal, crossed boundary, affected resource, and bounded local evidence; never elevate missing defense-in-depth or checklist deviations into vulnerabilities).
- **Full audit mode**: When asked to security-audit or pen-test a codebase or produce audit report artifacts, run all 6 phases (`RECONNAISSANCE.md` -> `HUNTING.md` + `ATTACK-CLASSES.md` -> `VALIDATION-AND-REPORTING.md` -> `validate-findings.cjs` & `validate-coverage-ledger.cjs`).
