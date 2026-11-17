# Routing evals

Run by hand after install. Type each prompt after `/do`. Do not mark a row passed without running it.

| # | Prompt | Expected skills | Handoff doc | Expected ▶ NEXT |
|---|---|---|---|---|
| 1 | Explain CAP theorem | DO only | no | Context: /clear if unrelated, else KEEP |
| 2 | Fix the null check in parser.py | delivery | no | KEEP or /clear |
| 3 | Design a notification service for 50k RPS | architecture | yes if staged | /model opus (if not on it), then /do docs/handoff/… |
| 4 | Add RAG over our Confluence docs | ai-engineering (+ delivery) | yes | /clear, /do docs/handoff/02-delivery.md |
| 5 | Security review of the login flow | security | no (yes if fixes follow) | /model opus for sign-off |
| 6 | Add a GitHub Actions pipeline with tests | platform-sre + delivery | yes | /clear, /do docs/handoff/… |
| 7 | Write a test strategy for the payments module | quality | no | KEEP or /clear |
| 8 | Compare Trivy vs Grype vs Snyk | research | no | /clear if unrelated |
| 9 | Build a 3-agent triage pipeline | ai-engineering + delivery | yes | /model opus for design stage |
| 10 | Migrate monolith auth to SSO | staged: architecture → security → delivery → quality | yes, 01 written before work | /clear, /model, /do docs/handoff/02-security.md |
| 11 | `/do done` on a finished task | none new | writes NN-done.md | DONE, /clear |
| 12 | A stage ends PARTIAL | same skill continues | writes continuation doc first | /clear, /do docs/handoff/NN-<skill>.md |

Pass criteria: right skills loaded, no extra skills, every reply ends with ▶ NEXT containing a `Context:` line and literal commands.
