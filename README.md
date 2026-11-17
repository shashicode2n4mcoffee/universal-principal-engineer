# Universal Principal Engineer 6.0

Skill package for Claude Code (VS Code, Cowork). Also works with agents that read `AGENTS.md`. No API key needed.

## Install
```bash
bash scripts/install.sh --user                  # all projects
bash scripts/install.sh --project ~/my-repo     # one or more projects
bash scripts/install.sh --dry-run --user        # preview
```
Windows: `scripts/install.ps1 -User` or `-Project <dir>`. Restart Claude Code, then `/do help`.

## Use
Just type `/do <task>`. Every reply ends with a **▶ NEXT** block with the exact commands to type next (`/clear`, `/model`, `/do docs/handoff/NN-<skill>.md`).

Stage docs live in `docs/handoff/` of your project (git-ignored by default; `--handoffs commit` to keep).

## Verified support
- Claude Code: skills (`.claude/skills/<name>/SKILL.md`), `disable-model-invocation`, subagents with `model` frontmatter. Syntax used from memory of the docs; re-check if your version rejects a field.
- Codex, Cursor, others: read `AGENTS.md` only. No slash skills, model switching or subagents claimed.
- No slash-command support: type `Follow skills/do/SKILL.md: <task>`.
- Subagents (`agents/*.md` → `.claude/agents/`) are optional; skip if your client lacks them.

## Tune it
Run the 12 prompts in `evals/routing.md`, check context with `/context` if available, and trim whichever file is over budget. Trim skills, not AGENTS.md rules. `bash scripts/validate.sh` checks budgets.

## Uninstall
`bash scripts/uninstall.sh --dry-run`, then without the flag.

## Sync (GitHub)
After cloning on a new device: `git config core.hooksPath .githooks` (enables auto-push on every commit), then `bash scripts/install.sh --user`.
Edit skills in this repo, commit, and the hook pushes. Re-run `install.sh` to refresh installed copies.
