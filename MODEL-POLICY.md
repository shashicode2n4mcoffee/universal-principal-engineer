# Model & Effort Policy

Aliases: `haiku`, `sonnet`, `opus`. Default is `sonnet`: usage limits are the real cost, and `opus` burns them faster. Use `opus` only for the stage that makes the key decision.

| Situation | Model | Effort |
|---|---|---|
| DO routing, simple answers, trivial edits, formatting | haiku or current | low |
| delivery, quality, research, platform-sre, ai-engineering | sonnet | medium |
| Security checklist review, dependency/scan triage | sonnet | medium |
| Architecture decision, threat model, security sign-off, AI/multi-agent system design | opus | high |
| Critical irreversible decision, or same problem failed twice | opus | xhigh / max |

## Rules
- Cheapest capable model. Escalate only for a stated reason: key decision, high risk, or two failed attempts. Drop back to `sonnet` the stage after.
- Put `/model <alias>` in NEXT only when the next stage needs a different model than the current one.
- Effort levels: low / medium / high / xhigh / max. If the client lacks a level, use the closest and say so in one line.
- The agent cannot switch models. It writes `/model <alias>` in NEXT and never claims a switch happened.
- Record the model/effort for the next stage in its stage doc.
