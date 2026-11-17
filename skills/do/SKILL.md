---
name: do
description: User entry point. Type /do <task>, /do docs/handoff/<file>.md, /do continue, /do status, /do review, /do done, or /do help. Classifies the task, loads the minimum skills, runs one stage, and ends with a ▶ NEXT block.
disable-model-invocation: true
argument-hint: "<task> | docs/handoff/<file>.md | continue | status | review | done | help"
---

# DO

Follow AGENTS.md. Model/effort: .claude/upe/MODEL-POLICY.md.

## Purpose & scope
Route, run one stage, hand off.

## Workflow
Arguments: `$ARGUMENTS`

1. `docs/handoff/….md` path: read only that doc and files it lists, load the skill it names, do its "Your job" section, write the next stage doc. `continue`: use the newest doc in `docs/handoff/`. Missing path or no docs: ask for the task in one line.
2. `status`: summarize newest doc's Plan line in ≤5 lines. `review`: quality skill on the current diff, plus security if auth, input, secrets or deps changed. `done`: check completion (all work done, validations run or marked not run with reason, limits stated), write `NN-done.md`. `help`: list these.
3. Otherwise classify type, size (S/M/L), risk. Simple question: answer directly, no skill, no doc.
4. Else pick the minimum skills: explain→none; small fix/feature/refactor→delivery (+quality); design→architecture; LLM/RAG/agents→ai-engineering; security→security (+delivery to fix); CI/infra/reliability→platform-sre; tests/PR review→quality; library comparison→research. Multi-skill work runs one stage per reply.
5. Multi-stage: write `docs/handoff/01-<skill>.md` from .claude/upe/STAGE-HANDOFF.md before working, with the full Plan line. Names `NN-<skill>.md`. Docs are self-contained (≤600 tokens), no secrets or logs; earlier docs never edited.
6. Model weaker than policy: S/M proceed and note it; L/high risk: `/model` in NEXT, stop.
7. Staged reply: STAGE n/m — skill · DONE|PARTIAL|BLOCKED, then Result, Changed, Validation, Next doc (≤6 lines).

## ▶ NEXT (mandatory, every reply)
Literal commands only. Must include `Context:` with exactly one of KEEP, /compact, /clear plus a reason. Write the next doc before recommending /clear.
```
▶ NEXT
Context: /clear — stage done; next doc is self-contained
1. /clear
2. /model opus        (only if the model must change)
3. /do docs/handoff/02-security.md
```
Same stage, long chat: `/compact` then `/do <doc>`. Small follow-up: KEEP. Done: `/clear` then `/do <next task>`. Blocked: `Context: KEEP`, `⛔ Need from you: …`, `Then paste: /do <doc> <answer>`.
## Evidence required
Real results only.
