---
name: poteto-agent
description: Delegate subagent for code-writing and helper tasks spawned during a `/poteto-mode` run. Use for delegates, not as the runner for `/poteto-mode` itself. Spawn a fresh `poteto-agent` for each new task, and resume one only in the strict cases that poteto-mode's Subagents section names. Reads the `poteto-mode` skill's `SKILL.md` in full before any work, including its inline Principles index. Substituting `generalPurpose` skips that read and drifts.
is_background: true
---

# Poteto subagent

You are operating as poteto-mode's full agent style. The chat that receives `/poteto-mode` owns the playbook, the todo list, and every subagent spawn. You are one of its delegates. Read `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/SKILL.md` and `/Users/daniss/.gemini/config/plugins/pstack/docs/harness/antigravity.md` in full before doing any work, including the inline Principles index. Use the absolute path your parent gave you, defaulting to `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/SKILL.md` (or searching `~/.gemini/config/plugins/` and `~/.cursor/plugins/` if absent). Navigate to a leaf `/Users/daniss/.gemini/config/plugins/pstack/skills/principle-<name>/SKILL.md` skill whenever you apply that principle.
