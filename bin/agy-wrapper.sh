#!/usr/bin/env bash
# Bald Potato Software Factory — Auto Degen Mode Wrapper for Antigravity (agy)
# Preloads Poteto (pstack) + Matt Pocock Software Factory + Cloudflare Security Audit + Bald Potato Arsenal
# Always enables --dangerously-skip-permissions by default.

REAL_AGY="${AGY_BIN_PATH:-$HOME/.local/bin/agy-bin}"
if [ ! -x "$REAL_AGY" ] && [ -x "$HOME/.gemini/antigravity-cli/bin/agy-bin" ]; then
  REAL_AGY="$HOME/.gemini/antigravity-cli/bin/agy-bin"
fi

ARGS=()
BALD_POTATO_FLAG=0

for arg in "$@"; do
  case "$arg" in
    --bald-potato|--bald-potato-degen-mode)
      BALD_POTATO_FLAG=1
      ;;
    *)
      ARGS+=("$arg")
      ;;
  esac
done

export AGY_BALD_POTATO_MODE=1
export AGY_BALD_POTATO_DEGEN_MODE=1

SUBCMD="${ARGS[0]:-}"
case "$SUBCMD" in
  plugin|auth|doctor|mcp|version|help|-v|--version|-h|--help)
    exec "$REAL_AGY" "${ARGS[@]}"
    ;;
  *)
    HAS_SKIP=0
    for a in "${ARGS[@]}"; do
      if [ "$a" = "--dangerously-skip-permissions" ]; then
        HAS_SKIP=1
      fi
    done
    if [ "$HAS_SKIP" -eq 0 ]; then
      exec "$REAL_AGY" --dangerously-skip-permissions "${ARGS[@]}"
    else
      exec "$REAL_AGY" "${ARGS[@]}"
    fi
    ;;
esac
