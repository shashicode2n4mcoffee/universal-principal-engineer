#!/usr/bin/env bash
# Package consistency checks. Exit non-zero on any FAIL.
set -uo pipefail
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then echo "Usage: validate.sh [--dry-run]  (read-only; prints PASS/FAIL table)"; exit 0; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
FAILS=0
res() { printf '%-5s %s\n' "$1" "$2"; [ "$1" = FAIL ] && FAILS=$((FAILS+1)); return 0; }
tok() { echo $(( $(wc -w <"$1") * 133 / 100 )); }   # estimate: words x 1.33
budget() { local n; n="$(tok "$1")"; if [ "$n" -le "$2" ]; then res PASS "$1 ~${n} tokens (estimate) <= $2"; else res FAIL "$1 ~${n} tokens (estimate) > $2"; fi; }

SKILLS="do architecture ai-engineering security platform-sre quality research delivery"
FILES="AGENTS.md CLAUDE.md MODEL-POLICY.md CHANGELOG.md README.md templates/STAGE-HANDOFF.md scripts/install.sh scripts/install.ps1 scripts/validate.sh scripts/uninstall.sh evals/routing.md"
for s in $SKILLS; do FILES="$FILES skills/$s/SKILL.md"; done
for f in $FILES; do [ -f "$f" ] && res PASS "exists $f" || res FAIL "missing $f"; done

for s in $SKILLS; do
  f="skills/$s/SKILL.md"; [ -f "$f" ] || continue
  fm="$(awk '/^---$/{c++; next} c==1{print}' "$f")"
  echo "$fm" | grep -q "^name: $s$" && res PASS "$s name" || res FAIL "$s name frontmatter"
  d="$(echo "$fm" | sed -n 's/^description: *//p')"
  if [ -z "$d" ]; then res FAIL "$s description missing"; else
    w="$(echo "$d" | wc -w)"; [ "$w" -le 60 ] && res PASS "$s description $w words" || res FAIL "$s description $w words > 60"; fi
  for h in "Purpose & scope" "Workflow" "Evidence required"; do
    grep -q "^## .*$h" "$f" || { [ "$h" = "Evidence required" ] && [ "$s" = do ] && grep -q "Evidence required" "$f"; } && continue
    res FAIL "$s missing section: $h"
  done
  if [ "$s" = do ]; then budget "$f" 500; else budget "$f" 900; fi
done
budget AGENTS.md 400
budget MODEL-POLICY.md 400
grep -Eq '[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]+\.[0-9]+\.[0-9]+|\bv[0-9]' AGENTS.md && res FAIL "AGENTS.md contains date/version" || res PASS "AGENTS.md has no date/version"

dup=0
while IFS= read -r rule; do
  [ -n "$rule" ] || continue
  if grep -rqF -- "$rule" skills/; then res FAIL "rule duplicated in a skill: $rule"; dup=1; fi
done < <(sed -n 's/^[0-9]\{1,2\}\. //p' AGENTS.md)
[ "$dup" -eq 0 ] && res PASS "no global rule duplicated in skills"

bad=0
for f in $(find . -name '*.md' -not -path './.git/*'); do
  while IFS= read -r l; do
    case "$l" in http*|'#'*|mailto:*|'') continue ;; esac
    t="${l%%#*}"; [ -e "$(dirname "$f")/$t" ] || { res FAIL "broken link in $f: $l"; bad=1; }
  done < <(grep -o ']([^)]*)' "$f" 2>/dev/null | sed 's/^](//; s/)$//')
done
[ "$bad" -eq 0 ] && res PASS "relative links resolve"

n="$(grep -c '^| *\(1[0-2]\|[1-9]\) *|' evals/routing.md 2>/dev/null || echo 0)"
[ "$n" -eq 12 ] && res PASS "evals/routing.md lists 12 scenarios" || res FAIL "evals/routing.md has $n scenarios"

d=skills/do/SKILL.md
if grep -q 'Context:' "$d" && grep -q 'KEEP' "$d" && grep -q '/compact' "$d" && grep -q '/clear' "$d"; then res PASS "do requires Context: line (KEEP, /compact, /clear)"; else res FAIL "do missing Context: rule"; fi
for sec in "Run with:" "Model / effort:" "Plan:" "Task status:" "## Goal of the whole task" "## Your job in this stage" "## Done when" "## Carried-forward" "## Read these files" "## Validation so far" "## Open risks" "## After this stage"; do
  grep -q -- "$sec" templates/STAGE-HANDOFF.md && res PASS "template: $sec" || res FAIL "template missing: $sec"
done
for sh in scripts/*.sh; do bash -n "$sh" && res PASS "syntax $sh" || res FAIL "syntax $sh"; done

echo; echo "FAILS: $FAILS"
cat <<'NEXT'

▶ NEXT
Context: KEEP — validation only
1. bash scripts/install.sh --dry-run --user
NEXT
[ "$FAILS" -eq 0 ]
