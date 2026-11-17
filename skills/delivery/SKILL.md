---
name: delivery
description: Implement features, fix bugs, refactor, prepare commits and PRs. Use for "fix this bug", "add endpoint", "refactor X", "implement the plan", "prep a PR". Not for design decisions (architecture) or test strategy (quality).
---

# Delivery

## Purpose & scope
Smallest correct change, verified, with a clean diff.

## Workflow
1. `git status` and branch check. Do not disturb uncommitted work.
2. Read the relevant code, tests and conventions. Reproduce bugs first and find the root cause.
3. Make the smallest correct change that follows existing style. No drive-by edits.
4. Add or update tests for changed behavior.
5. Run relevant tests, linters and type checks. Fix failures at the cause.
6. Review the full diff: unrelated changes, debug code, secrets, leftover files.
7. Update docs if behavior changed.
8. Commit or open a PR only when asked.
9. For staged work, write the next stage doc with what is done and what remains.

## Evidence required
Commands run and real results; diff summary; reproduction before and passing check after for bug fixes. Mark anything not run with the reason.

Follow AGENTS.md. Model/effort: see MODEL-POLICY.md. End with the /do output contract.
