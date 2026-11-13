#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

fast_copy_dir() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  cp -Rc "$src/"* "$dst/" 2>/dev/null || cp -R "$src/"* "$dst/"
}

echo "Installing Bald Potato Software Factory + Arsenal into $TARGET_HOME..."

# 1. Antigravity plugins (~/.gemini/config/plugins)
PLUGINS_DIR="$TARGET_HOME/.gemini/config/plugins"
mkdir -p "$PLUGINS_DIR"
for p in pstack mattpocock-skills security-audit-skill bald-potato-arsenal qa-skills; do
  rm -rf "$PLUGINS_DIR/$p"
  fast_copy_dir "$REPO_ROOT/plugins/$p" "$PLUGINS_DIR/$p"
  chmod +x "$PLUGINS_DIR/$p/hooks/"*.sh 2>/dev/null || true
done

if [ "$TARGET_HOME" != "/Users/daniss" ]; then
  python3 - "$PLUGINS_DIR" "$TARGET_HOME" <<'PY'
import os, sys
root, home = sys.argv[1], sys.argv[2]
for dirpath, _, filenames in os.walk(root):
    for fn in filenames:
        if fn.endswith((".md", ".json", ".sh")):
            p = os.path.join(dirpath, fn)
            try:
                with open(p, "r", encoding="utf-8", errors="ignore") as fp:
                    c = fp.read()
                if "/Users/daniss" in c:
                    with open(p, "w", encoding="utf-8") as fp:
                        fp.write(c.replace("/Users/daniss", home))
            except Exception:
                pass
PY
fi

# 2. Assemble unified skills catalog in ~/.agents/skills and clone across Claude Code, Codex, Cursor, OpenCode, Antigravity, and ~/skills
PRIMARY_SKILLS="$TARGET_HOME/.agents/skills"
mkdir -p "$PRIMARY_SKILLS"
for p in bald-potato-arsenal security-audit-skill mattpocock-skills pstack; do
  fast_copy_dir "$PLUGINS_DIR/$p/skills" "$PRIMARY_SKILLS"
done

for dest in \
  "$TARGET_HOME/skills" \
  "$TARGET_HOME/.claude/skills" \
  "$TARGET_HOME/.codex/skills" \
  "$TARGET_HOME/.cursor/skills" \
  "$TARGET_HOME/.config/opencode/skills" \
  "$TARGET_HOME/.gemini/config/skills" \
  "$TARGET_HOME/.gemini/skills"; do
  fast_copy_dir "$PRIMARY_SKILLS" "$dest"
done

# 3. Install global rules for Claude Code (~/.claude/CLAUDE.md), Codex (~/.codex/AGENTS.md), and universal ADEs (~/.agents/AGENTS.md)
mkdir -p "$TARGET_HOME/.claude" "$TARGET_HOME/.codex" "$TARGET_HOME/.agents"
sed "s|/Users/daniss|$TARGET_HOME|g" "$REPO_ROOT/rules/CLAUDE.md" > "$TARGET_HOME/.claude/CLAUDE.md"
sed "s|/Users/daniss|$TARGET_HOME|g" "$REPO_ROOT/rules/AGENTS.md" > "$TARGET_HOME/.codex/AGENTS.md"
sed "s|/Users/daniss|$TARGET_HOME|g" "$REPO_ROOT/rules/AGENTS.md" > "$TARGET_HOME/.agents/AGENTS.md"

# 4. Register plugins in ~/.gemini/config/settings.json
SETTINGS_JSON="$TARGET_HOME/.gemini/config/settings.json"
mkdir -p "$(dirname "$SETTINGS_JSON")"
python3 - "$SETTINGS_JSON" <<'PY'
import json, os, sys
path = sys.argv[1]
data = {}
if os.path.isfile(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}
ep = data.setdefault("enabledPlugins", {})
for name in ["pstack", "mattpocock-skills", "security-audit-skill", "bald-potato-arsenal", "qa-skills"]:
    ep[name] = True
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
PY

# 5. Wrap agy binary if present so bare `agy`, `agy --bald-potato`, and `agy --bald-potato-degen-mode` preload everything with --dangerously-skip-permissions
for bin_dir in "$TARGET_HOME/.local/bin" "$TARGET_HOME/.gemini/antigravity-cli/bin"; do
  if [ -f "$bin_dir/agy" ]; then
    # Only move agy -> agy-bin if agy is a native binary (not a shell wrapper)
    if ! file "$bin_dir/agy" | grep -qiE "(shell script|text executable)"; then
      cp -f "$bin_dir/agy" "$bin_dir/agy-bin"
      chmod +x "$bin_dir/agy-bin"
    fi
    cp -f "$REPO_ROOT/bin/agy-wrapper.sh" "$bin_dir/agy"
    chmod +x "$bin_dir/agy"
  fi
done

# 6. Ensure shell startup files define agy() wrapper function for login/interactive shells
MARKER="# >>> bald-potato-software-factory >>>"
END_MARKER="# <<< bald-potato-software-factory <<<"
BLOCK="$MARKER
export AGY_BALD_POTATO_MODE=1
export AGY_BALD_POTATO_DEGEN_MODE=1
agy() {
  \"\$HOME/.local/bin/agy\" --bald-potato-degen-mode --dangerously-skip-permissions \"\$@\"
}
alias agy-bald-potato='\"\$HOME/.local/bin/agy\" --bald-potato-degen-mode --dangerously-skip-permissions'
$END_MARKER"

for rc in "$TARGET_HOME/.zshrc" "$TARGET_HOME/.zprofile" "$TARGET_HOME/.bashrc"; do
  [ -f "$rc" ] || touch "$rc"
  if ! grep -q "$MARKER" "$rc" 2>/dev/null; then
    printf "\n%s\n" "$BLOCK" >> "$rc"
  fi
done

echo "Installation complete."
echo "Skills installed: $(ls -1 "$PRIMARY_SKILLS" | wc -l | tr -d ' ')"
