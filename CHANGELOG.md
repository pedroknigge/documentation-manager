# Changelog

All notable changes to the **documentation-manager** skill package.

Format: keep entries scannable. Versions follow semver for the skill package (`SKILL.md` metadata).

## [Unreleased]

### Changed

- **P1 Reconcile:** dual-plane who-wins — **AS-IS** code (and anchored matrix claims); **TO-BE** one living SSOT after classification  
- Date / mtime remains **evidence**, not a silent winner, on both planes (no date-wins engine)  
- Procedure [modes.md §6.8](skills/documentation-manager/references/modes.md#who-wins-as-is-vs-to-be); ADR-0002 reconcile row  
- No version bump — install floor stays **2.5.0**

- **Glance version:** `SKILL.md` `description` starts with `v2.5.0 —` (Orderfield habit); `metadata.version` unchanged  
- **P1 Docs:** first-contact honesty — documented procedures vs four on-demand loops (parse / persist / record / cascade-recommend); “has Haken” ≠ DB / daemon  
- **P1 Docs:** skill entry names the four on-demand kernel loops (`--list-claims` / `--upsert-claims` / `--record-haken` / `--cascade-recommend`); Haken ≠ DB / daemon  
- No version bump — install floor stays **2.5.0**

### Added

- **P1 Audit:** report stale / redundant / snapshot / fact-vs-changed-symbol narrative comments in the git change set (audit + sync)  
- Procedure [modes.md §6.10](skills/documentation-manager/references/modes.md#610-narrative-comments-report-first) — classify and emit §6.9 recommend-review (`path:line` + class); never auto-edit  
- Non-goals: auto-delete, full-tree campaign, CI gate on narrative comments, treating free prose as matrix rows  
- No new CLI (procedure over helper; `--list-changed` already scopes files)  
- No version bump — install floor stays **2.5.0**

- **P1 Kernel:** cascade recommend from `parent=` in the change set (`audit-claims.sh --cascade-recommend`)  
- Parent released in the set (`status=changed`) → list **for-review** children already in the set that name that `parent=` + evidence + modes.md §6.9 block  
- Read-only (does not write the matrix); children not in the set are not listed (no repo-wide grep; documented gap)  
- Reuses `--list-claims` change-set parse; no graph walker  
- Fixture + hardening asserts on `scripts/fixtures/claims-breadcrumbs/`  
- No version bump — install floor stays **2.5.0**

- **P0 Kernel:** record Haken verdicts on audit (`audit-claims.sh --record-haken`)  
- Writes hold / for-review to matrix **Action** (or an existing **Haken** column) with `path:line` + parent id; never into Verdict  
- escalate vs break / unclear `s≈f(q)` → HITL stderr; no silent invent; captain supersedes (not date-wins)  
- Reuses `--list-claims` change-set parse; no graph walker  
- Fixture + hardening asserts on `scripts/fixtures/claims-breadcrumbs/`  
- No version bump — install floor stays **2.5.0**

- **P0 Kernel:** parse `@claim` breadcrumbs from the git change set only (`audit-claims.sh --list-claims`)  
- Reports `id` / `parent` / `plane` / `status` (path + line); malformed → HITL stderr + exit 1; never invents fields  
- Optional read-only note when a comment id is missing from the matrix (no matrix write)  
- Fixture: `scripts/fixtures/claims-breadcrumbs/` + hardening asserts  
- No version bump — install floor stays **2.5.0**

### Fixed

- **C-062 / ArkGate dogfood note:** §7 distinguishes origin package vs host/consumer — when the working tree is ArkGate, the bridge applies (code wins)  
- **Cold-start survey heuristics** (LIVE FIELD DOGFOOD / [#11](https://github.com/pedroknigge/documentation-manager/issues/11)): case-insensitive root README (`Readme.md` counts); tight ADR homes/names (no `*adr*` substring — `TableHeadRenderer.tsx` is not an ADR); default claim/doc scope is `docs/` + root + `.github` and **excludes** `examples/**` unless you opt in  
- Helper: `scripts/survey-docs.sh` (same shape as `detect-stack.sh` / `detect-packages.sh`)  
- Flat CapCase `docs/*.md` stays **adopted** — never rewritten to the skill template tree  
- No version bump — install floor stays **2.5.0**

### Removed

- **Template telemetry** withdrawn from the skill surface (P2 subtract vs [ADR-0002](docs/adr/0002-knowledge-enslavement-captain.md))  
- Deleted `scripts/template-telemetry.sh` and `references/template-telemetry.md`  
- Agents no longer load a telemetry mode, rule, or quality-checklist ritual  
- History: shipped in **2.4.0**; pack marked [Withdrawn](docs/features/template-telemetry/README.md)  
- No version bump — install floor stays **2.5.0**

## [2.5.0] — 2026-08-30

### Added

- **Knowledge OS first increment (toward 100×):** living claims v0 + local CI structural audit  
- Procedure: `references/living-claims.md`; feature pack: [docs/features/living-claims/](docs/features/living-claims/README.md)  
- Air-gapped entrypoint: `scripts/audit-claims.sh` (fail on critical Contradicted)  
- Example workflow: `.github/workflows/docs-audit.yml`  
- install.sh remote refs include `living-claims.md`  

### Notes

- **Not** a second 10× (that shipped at v2.0) and **not** a full 100× Knowledge OS leap  
- Core stays local/air-gapped — no SaaS/control-plane in this release  
- Continues [knowledge-os](docs/plans/knowledge-os/README.md) epic after Fase 2 Bridge (v2.4.0)  

## [2.4.0] — 2026-07-17

### Added

- **Template telemetry (Slice D / Fase 2 Bridge complete):** opt-in local JSONL ledger  
- Privacy contract: default off, never-send (source/secrets/repo URLs), air-gapped no-op  
- Script: `scripts/template-telemetry.sh` (`status` / `record`) — no network tools  
- Modes §12 + SKILL rule 24; quality checklist  
- Feature pack: [docs/features/template-telemetry/](docs/features/template-telemetry/README.md)  

### Notes

- Network upload deferred (local ledger only in v2.4)  
- Completes Fase 2 Bridge slices A–D  

## [2.3.0] — 2026-07-17

### Added

- **Team governance (Slice C / Fase 2 Bridge):** optional `docs/team/` surface  
- Procedure: create vs link, integrate-first non-writes, hub pointer (anti-wiki)  
- Templates: `team-owners-template.md`, `team-approval-notes-template.md`  
- Modes §11 + SKILL rule 23; quality checklist + agents-md Team links  
- Feature pack: [docs/features/team-governance/](docs/features/team-governance/README.md)  
- install.sh remote refs include team templates  

### Notes

- Markdown only — no CODEOWNERS engine, merge bots, or BPM  
- Slice D (template telemetry) remains planned  

## [2.2.0] — 2026-07-17

### Added

- **Monorepo hubs (Slice B / Fase 2 Bridge):** package index + root hub as map  
- Detection signals: `pnpm-workspace.yaml`, `package.json` workspaces, `go.work`, multi-package dirs  
- Modes §0.4 + package non-writes when root-index only; multi-package coverage with **gap**  
- `scripts/detect-packages.sh` — lists package paths from real workspace signals  
- Fixture: `monorepo-thin/` (`packages/api`, `packages/web`)  
- Feature pack: [docs/features/monorepo-hubs/](docs/features/monorepo-hubs/README.md)  
- Hub template: Package index section in agents-md-template  

### Notes

- Orthogonal to polyglot stack detection (v2.1); stack may still run per package  
- Team governance (Slice C) and telemetry (Slice D) remain planned  

## [2.1.0] — 2026-07-17

### Added

- **Polyglot MVP (Slice A / Fase 2 Bridge):** stack detection for **Python**, **Go**, and Node/TS baseline  
- Tables: **Inventory by stack** + **Docs layout guidance by stack** in `references/skill-discovery.md`  
- Modes wiring: §0.3 + adopt/audit/from-zero use stack tables (no Node-only default)  
- `scripts/detect-stack.sh` — filesystem detector (`node-ts` / `python` / `go` / `unknown`)  
- Fixtures: `python-thin-repo/`, `go-thin-repo/` + hardening asserts  
- Feature pack: [docs/features/polyglot-mvp/](docs/features/polyglot-mvp/README.md)

### Notes

- Shared hub + `docs/` layout across stacks; monorepo multi-hub remains Slice B  
- Anti-hallucination: no invented ModuleIds/endpoints without code evidence  

## [2.0.0] — 2026-07-15

### Added

- **Adoption matrix** (`docs/adoption-matrix.md`) for tracking installs and ArkGate pairing honestly  
- **10× release pack** docs (`docs/features/tenx-v2-release/`)  
- Package marked **v2.0.0**: completes Fase 1 roadmap (bridge · autopilot v2 · dashboard · hardening · adoption)

### Included from 1.4–1.7 (rolled into the 10× line)

- ArkGate bridge (post-gate audit/sync, sensor not fusion)  
- Feature autopilot v2 (Kind spike/epic/redesign, Implementation bridge opt-in)  
- Knowledge dashboard (`scripts/generate-docs-dashboard.sh`)  
- Skill hardening (fixtures, golden mode anchors, version sync, discovery)

### Notes

- Markdown remains SSOT; generated HTML is gitignored  
- No auto-commit / auto-push  
- Pre-release: `./scripts/validate-skill.sh` (includes hardening)

## [1.7.0] — 2026-07-15

- Fixtures thin/mature/no-docs  
- `scripts/test-skill-hardening.sh` + golden autopilot anchors  
- `references/skill-discovery.md`  
- PUBLISH pre-release gate  

## [1.6.0] — 2026-07-15

- Static knowledge dashboard generator  
- modes §10 + `references/knowledge-dashboard.md`  

## [1.5.0] — 2026-07-15

- Feature autopilot v2  
- Implementation bridge (stubs opt-in)  

## [1.4.0] — 2026-07-15

- ArkGate bridge procedure  

## [1.3.0] — prior

- Plan mode + feature autopilot base  
- Intent integrate / audit / from-zero  
- Code wins audit matrix  
