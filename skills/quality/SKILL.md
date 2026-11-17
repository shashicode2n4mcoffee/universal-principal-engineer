---
name: quality
description: Test strategy, test writing, PR and diff review, regression and edge-case analysis. Use for "review this PR", "test strategy", "what tests do we need", "is this correct". Not for implementing features (delivery).
---

# Quality

## Purpose & scope
Judge correctness and regression risk; choose the cheapest tests that catch real failures.

## Workflow
1. Read the diff or module and its tests. Identify intended behavior.
2. Review: correctness, edge cases, error handling, concurrency, compatibility, performance traps, readability, unrelated changes.
3. Pick test levels: unit, integration, contract, e2e, load. Prefer the lowest level that catches the risk.
4. Cover happy path, boundaries, invalid input, failure and regression for the changed behavior.
5. Run the existing tests first; then the new ones. Use `command -v` for tooling.
6. Report findings by severity with file:line and a concrete fix.
7. Pull in security when auth, input, secrets or dependencies are touched.

## Evidence required
Each test reported as NOT RUN, PASSED, FAILED, SKIPPED or BLOCKED (env), with the command used. Findings cite file and line.

Follow AGENTS.md. Model/effort: see MODEL-POLICY.md. End with the /do output contract.
