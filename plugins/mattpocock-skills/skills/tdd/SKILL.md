---
name: tdd
description: Unified Bald Potato TDD (Matt Pocock red-green-refactor vertical slices at pre-agreed seams + Poteto executable regression check first).
---

# Unified TDD (Matt Pocock + Poteto)

This skill combines Matt Pocock's red-green-refactor loop (`matt-tdd`) with Poteto's executable bug-fix TDD workflow (`poteto-tdd`).

1. **Read both references in full when running `/tdd`**:
   - Matt Pocock TDD (vertical slices, pre-agreed public seams, anti-patterns, plus [tests.md](tests.md) and [mocking.md](mocking.md)): `/Users/daniss/.gemini/config/plugins/mattpocock-skills/skills/matt-tdd/SKILL.md`
   - Poteto TDD (executable failing regression check before fixing bugs, reporting failing-before and passing-after evidence): `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-tdd/SKILL.md`
2. **Core contract**:
   - Read `GLOSSARY.md` (if present) so test and interface names use the project's ubiquitous language.
   - Test behavior through public interfaces (**seams**), never internal implementation details.
   - Work in **vertical tracer-bullet slices**: one failing test (Red) -> minimal implementation to pass (Green) -> repeat.
   - For bug fixes, run the failing test before editing production code, confirm it fails for the expected reason, apply the minimal fix, and report both failing-before and passing-after evidence.
