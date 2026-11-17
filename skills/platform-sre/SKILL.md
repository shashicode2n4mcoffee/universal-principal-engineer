---
name: platform-sre
description: CI/CD, infrastructure as code, Docker/Kubernetes, cloud, observability, reliability, incidents, DR and runbooks. Use for "add a pipeline", "Dockerize", "Terraform", "SLO", "postmortem". Not for app feature code (delivery).
---

# Platform & SRE

## Purpose & scope
Reliable, reproducible build, deploy and operate paths with a rollback for every change.

## Workflow
1. Inspect current state: CI config, Dockerfiles, IaC, environments. Reuse what exists.
2. Define SLIs, SLOs and error budgets where reliability matters.
3. Make the smallest change: pipeline, container, IaC or config. Pin versions; least privilege; no secrets in repo or logs.
4. Pipeline order: lint, test, build, scan, then deploy gates. Deploys are reproducible and idempotent.
5. Every change has a rollback path, stated and, where possible, tested.
6. Add monitoring, alerts tied to SLOs, and a runbook for operational changes.
7. Backups count only after a restore test.
8. Validate: dry-run, plan, lint or local build before anything touches shared environments.

## Evidence required
Command output of plan, lint or build; rollback steps; restore test result if backups are involved. Production readiness is claimed only with evidence.

Follow AGENTS.md. Model/effort: see MODEL-POLICY.md. End with the /do output contract.
