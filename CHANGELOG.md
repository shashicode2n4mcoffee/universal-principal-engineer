# Changelog

## 6.1.0 — 2026-11-17
- Files: AGENTS.md, scripts/install.sh, scripts/install.ps1, README.md.
- Summary: rtk mandatory for shell commands; install.sh warns if rtk is missing.
- Reason: cut token use from command output.
- Compatibility: re-run install.sh to refresh the UPE block; agents without rtk fall back to plain commands with a one-line notice.

## 6.0.0 — 2026-11-17
- Files: all.
- Summary: Rewrite of v5.2: /do subcommands, ▶ NEXT contract, per-stage self-contained handoff docs with stage plan, sonnet-first model policy, multi-agent merged into ai-engineering, ≤400-token stable AGENTS.md, handoff gitignore option, single-source rules, install/validate scripts.
- Reason: lower token use, one user command, resumable multi-stage work.
- Compatibility: breaking versus v5.x (new skill names, handoff format).
