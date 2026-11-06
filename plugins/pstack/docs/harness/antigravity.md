# pstack in Google Antigravity (Gemini)

pstack skills use Cursor names. In Google Antigravity (`agy` CLI, Antigravity IDE, and Antigravity 2.0), read this adapter and map each Cursor name in a skill using the tables below. `<pstack>` means `/Users/daniss/.gemini/config/plugins/pstack`. If a Cursor field has no row, drop it and say so. Never pass a field or value the tool schema rejects.

## Always-On Default Mode

Antigravity runs `poteto-mode` (`pstack`) **always by default** on every task and turn via `/Users/daniss/.gemini/config/plugins/pstack/rules/AGENTS.md`, without requiring the user to type `/poteto-mode`.

## Tools

| Cursor | Antigravity (Gemini) |
| --- | --- |
| `Task` | `invoke_subagent` (plus `send_message`, `manage_subagents`, `define_subagent`) |
| `AskQuestion` | `ask_question`. In non-interactive `-p` mode or for trivial yes/no questions, ask in plain text. |
| Open a todolist | Maintain the todolist in your reply and/or in `<appDataDir>/brain/<conversation-id>/task.md`, updating it at each phase. |
| Run another pstack skill (`/name` or "the **name** skill") | `read_file` `/Users/daniss/.gemini/config/plugins/pstack/skills/<name>/SKILL.md` and follow it. |
| `Read` | `read_file` |
| `Write` | `write_file` |
| `StrReplace` / `Edit` | `edit_file` |
| `Shell` / `Bash` | `run_command` (and `manage_task` for background tasks) |
| `Grep`, `Glob` | `run_command` with `rg` / `fd` / `find`. |

## Subagent fields

| Cursor | Antigravity (`invoke_subagent`) |
| --- | --- |
| `subagent_type: "poteto-agent"` or `generalPurpose` (`readonly: false`) | `TypeName: "self"` (inherits full write, command, MCP, and subagent tools plus the always-on `pstack` rule in `rules/AGENTS.md`), or `TypeName: "poteto-agent"` for read-only analysis. Put `Role` as a 2-5 word role title and `Prompt` with the full brief and `/Users/daniss/.gemini/config/plugins/pstack/skills/poteto-mode/SKILL.md`. |
| `subagent_type: "comment-sicko"` | `TypeName: "comment-sicko"` |
| `readonly: true` | `TypeName: "research"` (runs in a read-only sandbox) or `TypeName: "poteto-agent"` |
| `environment: "cloud"` | `Workspace: "share"` (or `Workspace: "branch"` for an isolated branched workspace) |
| `environment: "local"` | `Workspace: "inherit"` (default) |
| `cloud_base_branch: <b>` | Tell the worker in `Prompt` to check out `<b>` first. |
| `run_in_background: true` | Default behavior of `invoke_subagent`. Subagents run in the background and wake you automatically when they send a message or complete; do not poll. |
| `resume` | Call `send_message` with `Recipient: "<conversationId>"`, or call `invoke_subagent` to spawn a fresh subagent with consolidated scope. |
| `file_attachments` | List the absolute file paths in `Prompt`. |

## Models

| Cursor | Antigravity (`invoke_subagent` `Model` field) |
| --- | --- |
| `claude-opus-*`, `hardest tasks`, `judgment and prose` | `Model: "inherit"` (or `Model: "pro"`). `Model` accepts only `"inherit"`, `"pro"`, `"flash"`, `"flash_lite"`. |
| `grok-*`, `gpt-*`, code delegates, `swarm workers` | `Model: "inherit"` (or `Model: "pro"` for complex work, `Model: "flash"` for simple/fast tasks). |
| `auto` or `inherit-parent` | `Model: "inherit"` |
| `~/.cursor/rules/pstack-models.mdc` | `/Users/daniss/.gemini/config/plugins/pstack/rules/AGENTS.md` (always loaded while the `pstack` plugin is enabled). |

## Paths

| Cursor | Antigravity (Gemini) |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.agents/skills/`, `/Users/daniss/.gemini/config/plugins/pstack/skills/` |
| `~/.cursor/plugins/`, `.cursor-plugin/plugin.json` | `/Users/daniss/.gemini/config/plugins/`, `/Users/daniss/.gemini/config/plugins/pstack/plugin.json` |
| `.cursor/rules/*.mdc`, always-applied rules | `GEMINI.md`, `AGENTS.md`, `.agents/rules/*.md`, and `/Users/daniss/.gemini/config/plugins/pstack/rules/AGENTS.md` |
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | `/Users/daniss/.gemini/config/plugins/pstack/<path>` when that file exists locally. Read the local copy and never fetch it over the network. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` (and `transcript_full.jsonl`). |

## Cursor-only features

Antigravity has no Cursor Automations (`api2.cursor.sh/automations`), Cursor cloud dashboard, or built-in PR tool. When a step needs one, put one line in your reply (`Skipped in Antigravity: <step>. <reason>.`) and continue to the next step. Use `gh` CLI via `run_command` for PR operations (`gh pr create`, `gh pr view`, etc.).
