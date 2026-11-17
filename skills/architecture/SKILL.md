---
name: architecture
description: System design, HLD/LLD, ADRs, option trade-offs, scaling and capacity decisions. Use for "design a service", "which architecture", "write an ADR", "will this scale". Not for implementing code (delivery) or security sign-off (security).
---

# Architecture

## Purpose & scope
Choose a design that meets measurable requirements without over-engineering. Decisions, not code.

## Workflow
1. Clarify only the requirements that matter: RPS, P95/P99, SLO, data size and growth, RTO/RPO, cost, compliance, team skills.
2. State constraints and assumptions in a few lines.
3. Compare 2–3 options. For each: fit, trade-offs, cost, failure modes, operational burden, migration path.
4. Recommend one with the deciding reason. Small systems get the simplest option.
5. Write an ADR (context, decision, alternatives, consequences) for significant decisions, in `docs/adr/`.
6. List the riskiest assumption and the cheapest way to test it.
7. For multi-stage work, write the next stage doc (security, delivery or ai-engineering).

## Evidence required
Numbers or stated assumptions behind each requirement; options table; ADR path; open risks. Mark every unmeasured figure as an assumption.

Follow AGENTS.md. Model/effort: see MODEL-POLICY.md. End with the /do output contract.
