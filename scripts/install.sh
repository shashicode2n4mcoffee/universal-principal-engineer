#!/usr/bin/env bash
# Install Universal Principal Engineer skills. Idempotent. See --help.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VER="6.1"
BEGIN="<!-- UPE:BEGIN v${VER} -->"
END="<!-- UPE:END -->"
TS="$(date +%Y%m%d-%H%M%S)"
DRY=0; USER_MODE=0; HANDOFFS=""; PROJECTS=()
TMPS=()
trap 'rm -f "${TMPS[@]:-}"' EXIT

usage() {
  cat <<USAGE
Usage:
  install.sh --user                          # ~/.claude/{skills,agents,upe}
  install.sh --project <dir> [<dir> ...]     # <dir>/.claude/... + AGENTS.md/CLAUDE.md
  install.sh --user --project ~/a ~/b        # both
Options:
  --dry-run               show what would change, write nothing
  --handoffs ignore|commit   git-ignore docs/handoff/ (default) or keep in git
  -h, --help
Existing AGENTS.md/CLAUDE.md are never overwritten; a delimited UPE block is added or replaced.
Changed files are backed up as <file>.bak-<timestamp>.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --user) USER_MODE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --handoffs) [ $# -ge 2 ] || { echo "--handoffs needs a value" >&2; exit 2; }; HANDOFFS="$2"; shift 2 ;;
    --project) shift; while [ $# -gt 0 ] && [[ "$1" != --* ]]; do PROJECTS+=("$1"); shift; done ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
case "$HANDOFFS" in ""|ignore|commit) ;; *) echo "--handoffs must be ignore or commit" >&2; exit 2 ;; esac
if [ "$USER_MODE" -eq 0 ] && [ "${#PROJECTS[@]}" -eq 0 ]; then usage >&2; exit 2; fi

log() { printf '  %s\n' "$*"; }
mktmp() { local t; t="$(mktemp)"; TMPS+=("$t"); printf '%s' "$t"; }

# commit_file <src> <dst>: copy if different, back up existing.
commit_file() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then log "unchanged  $dst"; return; fi
  if [ "$DRY" -eq 1 ]; then log "would write $dst"; return; fi
  mkdir -p "$(dirname "$dst")"
  [ -f "$dst" ] && cp -p "$dst" "$dst.bak-$TS"
  cp "$src" "$dst"; log "wrote      $dst"
}

# upsert_block <file> <body-file>: add or replace the UPE block, preserving the rest.
upsert_block() {
  local f="$1" body="$2" blk new
  blk="$(mktmp)"; new="$(mktmp)"
  { echo "$BEGIN"; cat "$body"; echo "$END"; } >"$blk"
  if [ -f "$f" ] && grep -q '<!-- UPE:BEGIN' "$f"; then
    awk -v bf="$blk" '/<!-- UPE:BEGIN/{while((getline l<bf)>0)print l; skip=1; next} /<!-- UPE:END -->/{skip=0; next} !skip{print}' "$f" >"$new"
  elif [ -f "$f" ]; then
    { cat "$f"; echo; cat "$blk"; } >"$new"
  else
    cat "$blk" >"$new"
  fi
  commit_file "$new" "$f"
  MAN+=("BLOCK $f")
}

install_tree() { # <root> <label> <mode: user|project>
  local root="$1" mode="$3" base="$1/.claude" f rel
  MAN=()
  echo "Target ($2): $root"
  for f in $(cd "$SRC/skills" && find . -type f | sort); do
    rel="${f#./}"; commit_file "$SRC/skills/$rel" "$base/skills/$rel"; MAN+=("FILE $base/skills/$rel")
  done
  for f in "$SRC"/agents/*.md; do
    [ -f "$f" ] || continue
    commit_file "$f" "$base/agents/$(basename "$f")"; MAN+=("FILE $base/agents/$(basename "$f")")
  done
  commit_file "$SRC/MODEL-POLICY.md" "$base/upe/MODEL-POLICY.md"; MAN+=("FILE $base/upe/MODEL-POLICY.md")
  commit_file "$SRC/templates/STAGE-HANDOFF.md" "$base/upe/STAGE-HANDOFF.md"; MAN+=("FILE $base/upe/STAGE-HANDOFF.md")

  if [ "$mode" = user ]; then
    upsert_block "$root/.claude/CLAUDE.md" "$SRC/AGENTS.md"
  else
    upsert_block "$root/AGENTS.md" "$SRC/AGENTS.md"
    local imp; imp="$(mktmp)"; echo "@AGENTS.md" >"$imp"
    upsert_block "$root/CLAUDE.md" "$imp"
    if [ "$HANDOFFS" != commit ]; then
      if [ -f "$root/.gitignore" ] && grep -qx 'docs/handoff/' "$root/.gitignore" && ! grep -q 'UPE:BEGIN' "$root/.gitignore"; then
        log "unchanged  $root/.gitignore (entry already present)"
      else
        local gi; gi="$(mktmp)"; echo "docs/handoff/" >"$gi"
        upsert_block "$root/.gitignore" "$gi"
      fi
    else
      log "handoff docs stay tracked in git"
    fi
  fi

  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$base"
    { [ -f "$base/.upe-manifest" ] && cat "$base/.upe-manifest"; printf '%s\n' "${MAN[@]}"; } | sort -u >"$base/.upe-manifest.new"
    mv "$base/.upe-manifest.new" "$base/.upe-manifest"
    log "manifest   $base/.upe-manifest"
  else
    log "would write manifest $base/.upe-manifest"
  fi
}

if [ "${#PROJECTS[@]}" -gt 0 ] && [ -z "$HANDOFFS" ]; then
  if [ -t 0 ] && [ "$DRY" -eq 0 ]; then
    read -r -p "Commit stage handoff docs (docs/handoff/) to git? [y/N] " ans || ans=""
    case "$ans" in y|Y|yes) HANDOFFS=commit ;; *) HANDOFFS=ignore ;; esac
  else
    HANDOFFS=ignore; echo "Handoff docs: defaulting to ignore (docs/handoff/ in .gitignore)."
  fi
fi

[ "$DRY" -eq 1 ] && echo "DRY RUN: nothing will be written."
command -v rtk >/dev/null 2>&1 || echo "WARNING: rtk not found; AGENTS.md requires it. Install rtk (rtk-ai/rtk) first." >&2
if [ "$USER_MODE" -eq 1 ]; then install_tree "$HOME" user user; fi
for p in "${PROJECTS[@]:-}"; do
  [ -n "$p" ] || continue
  if [ ! -d "$p" ]; then echo "WARNING: skipping missing directory: $p" >&2; continue; fi
  install_tree "$(cd "$p" && pwd)" project project
done

cat <<'NEXT'

▶ NEXT
Context: /clear — install finished
1. Reload VS Code / restart Claude Code
2. /do help
NEXT
