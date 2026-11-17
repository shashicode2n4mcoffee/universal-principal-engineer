#!/usr/bin/env bash
# Remove only what install.sh recorded in the manifest. Never touches user content.
set -euo pipefail
DRY=0; USER_MODE=0; PROJECTS=()
usage() { cat <<USAGE
Usage: uninstall.sh [--user] [--project <dir> ...] [--dry-run]
Removes files listed in <root>/.claude/.upe-manifest and the UPE block in AGENTS.md/CLAUDE.md/.gitignore.
Backups (*.bak-*) are left in place.
USAGE
}
while [ $# -gt 0 ]; do
  case "$1" in
    --user) USER_MODE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --project) shift; while [ $# -gt 0 ] && [[ "$1" != --* ]]; do PROJECTS+=("$1"); shift; done ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
if [ "$USER_MODE" -eq 0 ] && [ "${#PROJECTS[@]}" -eq 0 ]; then usage >&2; exit 2; fi

strip_block() {
  local f="$1" new; [ -f "$f" ] || return 0
  grep -q '<!-- UPE:BEGIN' "$f" || { echo "  no UPE block in $f"; return 0; }
  if [ "$DRY" -eq 1 ]; then echo "  would remove UPE block from $f"; return 0; fi
  new="$(mktemp)"
  awk '/<!-- UPE:BEGIN/{skip=1; next} /<!-- UPE:END -->/{skip=0; next} !skip{print}' "$f" >"$new"
  if [ -z "$(tr -d '[:space:]' <"$new")" ]; then rm -f "$f"; echo "  removed (was only UPE) $f"; else cp "$new" "$f"; echo "  stripped block from $f"; fi
  rm -f "$new"
}

uninstall_root() {
  local root="$1" base="$1/.claude" man="$1/.claude/.upe-manifest" kind path d
  echo "Target: $root"
  [ -f "$man" ] || { echo "  no manifest ($man); nothing to remove"; return 0; }
  while read -r kind path; do
    [ -n "${path:-}" ] || continue
    case "$kind" in
      FILE)
        if [ -f "$path" ]; then
          if [ "$DRY" -eq 1 ]; then echo "  would remove $path"; else
            rm -f "$path"; echo "  removed $path"
            d="$(dirname "$path")"
            while [ "$d" != "$base" ] && [ "$d" != "/" ] && rmdir "$d" 2>/dev/null; do d="$(dirname "$d")"; done
          fi
        fi ;;
      BLOCK) strip_block "$path" ;;
    esac
  done <"$man"
  if [ "$DRY" -eq 0 ]; then rm -f "$man"; echo "  removed manifest"; fi
}

[ "$DRY" -eq 1 ] && echo "DRY RUN: nothing will be removed."
[ "$USER_MODE" -eq 1 ] && uninstall_root "$HOME"
for p in "${PROJECTS[@]:-}"; do
  [ -n "$p" ] || continue
  [ -d "$p" ] || { echo "WARNING: skipping missing directory: $p" >&2; continue; }
  uninstall_root "$(cd "$p" && pwd)"
done
cat <<'NEXT'

▶ NEXT
Context: /clear — uninstall finished
1. Restart Claude Code / reload VS Code
2. Delete any *.bak-* backups you no longer need
NEXT
