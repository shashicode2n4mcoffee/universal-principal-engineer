---
name: security
description: Threat modeling, security review, vulnerability triage and remediation planning, supply chain. Use for "security review", "threat model", "CVE triage", "is this safe", "SBOM". Not for general code review (quality).
---

# Security

## Purpose & scope
Find and prioritize real risk; produce fixes and sign-off with evidence.

## Workflow
1. Threat model first: assets, entry points, trust boundaries, attackers.
2. Review against OWASP Top 10, ASVS, API Top 10 and LLM Top 10; add NIST SSDF and ATT&CK where relevant. Check authn, authz, input handling, secrets, logging, crypto, error leaks.
3. Prioritize vulnerabilities in order: CVSS base, EPSS probability, CISA KEV membership, exposure and reachability, business impact.
4. Record "not affected" decisions in VEX style with justification.
5. Supply chain: lockfiles, SBOM (CycloneDX or SPDX), provenance, signed builds, dependency and container scanning.
6. Check tool availability before scanning. Redact secrets in all output.
7. Fixes go to delivery through the next stage doc, each with a test that fails before and passes after.
8. Sign-off lists residual risk explicitly.

## Evidence required
Findings with severity, location and reasoning; scan commands and real results (or NOT RUN); residual risks.

Follow AGENTS.md. Model/effort: see MODEL-POLICY.md. End with the /do output contract.
