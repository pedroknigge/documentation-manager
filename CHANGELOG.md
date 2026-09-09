# Changelog

All notable changes to the **documentation-manager** skill package.

Format: keep entries scannable. Versions follow semver for the skill package (`SKILL.md` metadata).

## [Unreleased]

### Fixed

- `audit-claims.sh --base`: require a commit this clone can see before `git diff <base>...HEAD`; empty-tree / missing / non-commit → HITL + exit 2 (not git 128). Same `list_changed_files` helper for all `--base` siblings. No new flag.

## [2.5.13] — 2026-09-09

Anonymous dogfood sales-stats first live row. **Not** a new major; **not** a Knowledge OS leap.

### Changed

- **GTM:** [docs/sales-stats.json](docs/sales-stats.json) — schema v1 ledger records one anonymized ok run (aggregates: empty zeros → 1 ok). Public rows still omit target owner, repo, URLs, and identifiable foreign content. README History still points at the file without citing run counts.
- **Glance version:** `SKILL.md` `description` starts with `v2.5.13 —`; `metadata.version` **2.5.13**

## [2.5.12] — 2026-09-08

Audit/report facet: group-by provenance (owner + git opt-in). **Not** a new major; **not** a Knowledge OS leap; **not** a second truth-owner or reconcile regime. Rebased onto v2.5.11 (`5741301`).

### Added

- **Opt-in report:** `audit-claims.sh --group-by provenance [--base REF]` — same §6.0 change set; no write
- Procedure [modes.md §6.11](skills/documentation-manager/references/modes.md#611-provenance-grouping-opt-in-report): explicit `owner:` / claim steward / CODEOWNERS first (TO-BE); git first/last author bucketed `human` · `bot/agent` · `unknown` (AS-IS; never invent owner from git)
- Orphans (no owner) → propose `owner:` or archive; **Missing stays Missing**; no greenwash
- Quality-checklist section **Provenance grouping** + SKILL rule 32

### Unchanged (locked)

- **§6.8** reconcile · **§14** go/no-go · **§15** Appendix A · **§16** §2 Mínimo · **§17** production-harden DoD · **§18** Sólido · **§19** cold-agent · **§20** plans layout stay numbered as shipped
- Dual-plane: git is AS-IS only; owner is TO-BE only — no second regime
- Human captain · never invent owner from git · Missing stays Missing · no greenwash
- CI gate still whole-matrix; `--group-by provenance` is not the gate
- No dashboard rewrite · no auto-write of `owner:` · no new matrix verdicts

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.12 —`; `metadata.version` **2.5.12**

## [2.5.11] — 2026-09-08

Plans layout: creator GitHub folder + multi-doc grouping + archive-on-finish (Pedro 2026-09-08). **Not** a new major; **not** a Knowledge OS leap. Rebased onto v2.5.10 (`b211225`).

### Added

- **New writes:** plans live under `docs/plans/<github-login>/<slug>/` — `README.md` is the index; companions stay in that folder
- Procedure [modes.md §20](skills/documentation-manager/references/modes.md#20-plans-layout): creator path · multi-doc rule · detect `github-login` (`gh api user -q .login` / unambiguous git→GitHub / HITL) · archive-on-finish · stubs vs move
- **Archive-on-finish:** on plan / promote / sync / audit of plans in the change set, when Status is **Shipped | Cancelled | Superseded** or the plan was **promoted**, move the slug folder to `docs/plans/<github-login>/_archive/<slug>/` when possible
- Quality-checklist section **Plans layout / archive-on-finish** + SKILL rule 31 + plan-template banner + tree diagram

### Unchanged (locked)

- **§14** go/no-go · **§15** Appendix A · **§16** §2 Mínimo · **§17** production-harden DoD · **§18** Sólido states/transitions · **§19** cold-agent readable stay numbered as shipped
- Human captain · never invent a GitHub login · Missing stays Missing · no greenwash
- No new CLI · no new Status tokens · no second SSOT · no living-claims wire change
- Existing consumer `docs/plans/<slug>/` trees adopted — no force-migrate without HITL
- Orderfield / ArkGate ports · P3 Ports · rewriting all historical plans in this repo (out of scope)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.11 —`; `metadata.version` **2.5.11**

## [2.5.10] — 2026-09-08

Cold-agent readable bar (Pedro 2026-09-08). **Not** a new major; **not** a Knowledge OS leap. Rebased onto v2.5.9 (`ff6ea34`).

### Added

- **Closed bar:** plan / feature / promote artifacts must recover **intent**, **success criteria**, **non-goals**, and **next actions** from the file alone — no “as we discussed”, no chat-only context, no dual interpretation
- Procedure [modes.md §19](skills/documentation-manager/references/modes.md#19-cold-agent-readable): file-alone recoverable fields · writes/audits flag dual reading as gap / HITL · living TO-BE stays cold-agent readable
- Quality-checklist section **Cold-agent readable** + SKILL rule 30 + plan/feature template banners + Next actions + promote checklist row
- Complements the golden rule: if you cannot point to where it is, it does not exist

### Unchanged (locked)

- **§14** go/no-go · **§15** Appendix A · **§16** §2 Mínimo · **§17** production-harden DoD · **§18** Sólido states/transitions stay numbered as shipped
- Human captain · never invent product intent · Missing stays Missing · no greenwash
- No new CLI · no second SSOT · no living-claims wire change · no new matrix verdicts
- Orderfield / ArkGate ports · P3 Ports · rewriting all existing consumer plans (out of scope)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.10 —`; `metadata.version` **2.5.10**

## [2.5.9] — 2026-09-08

Sólido states/transitions artifact guidance (Pedro norte §2). **Not** a new major; **not** a Knowledge OS leap. Rebased onto v2.5.8 (`95f679d`).

### Added

- **P2 §2 Sólido:** skill **proposes** (from-zero / integrate) and **audits presence** of a short states/transitions table (or one link) for core entities — closed vocabulary, no flag soup
- Procedure [modes.md §18](skills/documentation-manager/references/modes.md#18-solido-statestransitions): propose · map (evolved home) · presence (in-scope only)
- Presence tokens reuse §16.2 — **Missing stays Missing** (never OK; never greenwash)
- When Intent=`production-harden` / shipping language, a critical entity with no transition map is **Missing** (light §17 DoD tie)
- Quality-checklist section + SKILL rule 29 + artifact-matrix row + announce `Sólido states/transitions`

### Unchanged (locked)

- **§14** go/no-go · **§15** Appendix A · **§16** §2 Mínimo · **§17** production-harden DoD stay numbered as shipped
- Diff-first / docs-universe — no tree walk to find vision/domain
- Never invent domain states · no flag soup · captain remains captain
- No new CLI · no living-claims wire change · no new matrix verdicts · no cascade engine

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.9 —`; `metadata.version` **2.5.9**
- SKILL rule 28 lock flipped: this slice **is** the Sólido states/transitions P2 (pointer to §18)

## [2.5.8] — 2026-09-08

Production-harden Definition of Done (Pedro norte §2 / §20). **Not** a new major; **not** a Knowledge OS leap. Rebased onto v2.5.7 (`3e3d00b`).

### Added

- **P2 DoD:** quality-checklist **Production-harden DoD** row — when Intent=`production-harden` (“no volver a prototipo”), PRs that change **domain** must update claims/matrix (diff-first)
- Procedure [modes.md §17](skills/documentation-manager/references/modes.md#17-production-harden-dod): overlay on sync/audit; §2 Mínimo not dropped; §20 / Gate A/B never invent a Sí; captain signs; no auto-merge
- Appendix A Definition of Done honesty: checklist is the skill’s harden bar — still **not** a signed production Go ([prototype-to-production.md](skills/documentation-manager/references/prototype-to-production.md))
- SKILL rule 28 + Intent overlay + announce `Production-harden DoD`

### Unchanged (locked)

- **§14** go/no-go · **§15** Appendix A · **§16** §2 Mínimo stay numbered as shipped
- Diff-first / docs-universe — no tree walk
- Never invent a Sí · no greenwash OK
- Sólido states/transitions held (other P2)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.8 —`; `metadata.version` **2.5.8**

## [2.5.7] — 2026-09-08

Domain invariants as living claims (dual-plane cookbook). **Not** a new major; **not** a Knowledge OS leap. Rebased onto v2.5.6 (`b223580`).

### Added

- **P1 Living claims:** cookbook — encode domain invariants as `@claim` + matrix rows ([living-claims.md](skills/documentation-manager/references/living-claims.md#domain-invariants-dual-plane-cookbook))
- Same locked dual-plane: **AS-IS** = code / anchored claims win; **TO-BE** = one living plan/claim per topic
- **No greenwash:** do not mark OK because the sentence sounds right or the doc is newer
- HITL when who-wins is unclear; date / mtime remains evidence, not a silent winner
- One modes pointer: [modes.md §6.8 Who wins](skills/documentation-manager/references/modes.md#who-wins-as-is-vs-to-be)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.7 —`; `metadata.version` **2.5.7**

## [2.5.6] — 2026-09-08

**P1 — §2 Mínimo pack** (Pedro norte §2 Producto y dominio). Skill can **propose** (from-zero / integrate) and **audit presence** of the closed product-domain checklist. **Not** a new major; **not** a Knowledge OS leap.

Parent: [ADR-0002](docs/adr/0002-knowledge-enslavement-captain.md) (propose; never override evolved layout) · Pedro norte §2. Rebased onto v2.5.5 Appendix A honesty map ([modes.md §15](skills/documentation-manager/references/modes.md#15-prototype--production-coverage-apendice-a)); this pack is **modes §16**.

### Added

- **§2 Mínimo (closed):** problem · user · JTBD one page; MVP scope + non-goals; critical flows alta / login / valor / pago / baja/export; 1–2 success metrics; killer assumptions
- Procedure [modes.md §16](skills/documentation-manager/references/modes.md#16-product-domain-minimo): propose (from-zero / adopt-full) · map (integrate, evolved home) · presence audit (in-scope only)
- Presence tokens Present / Partial / **Missing** / N/A-with-evidence — **Missing stays Missing** (never OK; never greenwash)
- Quality-checklist section pointing at §16 / §2
- SKILL rule 27 + artifact-matrix row + announce `§2 Mínimo`

### Unchanged (locked)

- Diff-first / docs-universe ([modes.md §6.0](skills/documentation-manager/references/modes.md#60-change-set-diff-first)) — no tree walk to find vision
- Adopt evolved layout — never force `product-vision.md` over the captain
- Never invent product facts
- **Go/no-go §14** intact (v2.5.4)
- **Appendix A §15** intact (v2.5.5)

### Out of scope (held)

- Writing a real product’s JTBD · Sólido edges/states · new CLI / matrix verdicts / living-claims wire

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.6 —`; `metadata.version` **2.5.6**
## [2.5.5] — 2026-09-08

Appendix A honesty map for Pedro norte *De prototipo a producción* v1.0. **Not** a new major; **not** a Knowledge OS leap.

### Added

- **P1 Coverage:** [prototype-to-production.md](skills/documentation-manager/references/prototype-to-production.md) — SSOT honesty matrix (generates | audits | out-of-scope (captain))
- Artifacts: Problem/scope/non-goals · Domain invariants · Context diagram · Data inventory · Threat model 1-pager · ADRs · Definition of Done · Runbooks SEV · Gate A/B signed
- Honesty: SEV runbooks + threat model are **out-of-scope (captain)**; data inventory **audits** only; Gate A/B *signing* stays captain (trail proposal is modes §14 / v2.5.4)
- Pointers: SKILL.md rule 26 + templates row; modes.md §15; quality-checklist; skill-discovery see-also (no second SSOT; does not steal §14 go/no-go)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.5 —`; `metadata.version` **2.5.5**

## [2.5.4] — 2026-09-08

Go/no-go Gate A/B decision trail in living docs. **Not** a new major; **not** a Knowledge OS leap.

### Added

- **Go/no-go:** [modes.md §14](skills/documentation-manager/references/modes.md#14-gono-go-decision-trail-v254) — write Gate A/B answers (Sí / No / N/A justificado) + **one residual-risk sentence** into `docs/ops/go-nogo.md`
- Template: [go-nogo-template.md](skills/documentation-manager/references/go-nogo-template.md) (consumer copies; adopt evolved path)
- Locked rules: Gate A any **No** → Decision **cannot be Go**; Gate B **No** only with owner + due date; never invent a Sí; never auto-fill from living-claims CI (that gate ≠ production go/no-go); dual-plane ops/TO-BE; human captain / HITL
- Audit-template token + quality-checklist + hub Key Links pointer
- Feature pack: [docs/features/go-nogo/README.md](docs/features/go-nogo/README.md)

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.4 —`; `metadata.version` **2.5.4**

## [2.5.3] — 2026-09-07

Anonymous sales/GTM dogfood stats file for LIVE FIELD DOGFOOD (every 72h, off-repo). **Not** a new major; **not** a Knowledge OS leap.

### Added

- **GTM:** [docs/sales-stats.json](docs/sales-stats.json) — schema v1 empty ledger (`runs: []`); later anonymized rows: `{ at, ok, duration_s, skill_version, phases[], findings, finding_kinds[] }`
- Privacy: public rows never include target owner, repo, URLs, or identifiable foreign content; aggregates may back or lower README product claims (never invent numbers; never name target repos)
- Pointers: README History one-liner + [docs/adoption-matrix.md](docs/adoption-matrix.md) — marketing agents; README-claims coupling

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.3 —`; `metadata.version` **2.5.3**

## [2.5.2] — 2026-09-06

Classic installer covers Gemini CLI (and Antigravity “agy” when that parent already exists). **Not** a new major; **not** a Knowledge OS leap.

### Added

- **Install:** `install.sh` writes `~/.gemini/skills/documentation-manager` when `gemini` is on PATH or `~/.gemini` exists (official Gemini CLI user skills path)
- **Install:** also writes `~/.gemini/config/skills/` if that parent already exists (Antigravity/config layout)
- **Install:** also writes `~/.gemini/antigravity/skills/` if that parent already exists (agy)
- Uninstall removes the same paths when present
- Honesty: [skill-discovery.md](skills/documentation-manager/references/skill-discovery.md) + README Install name Gemini paths; `install-smoke` + hardening cover the anchors

### Changed

- **Glance version:** `SKILL.md` `description` starts with `v2.5.2 —`; `metadata.version` **2.5.2**

## [2.5.1] — 2026-09-06

Catch-up patch on the Knowledge OS floor after many merges stayed frozen on 2.5.0. **Not** a new major; **not** a second Knowledge OS leap. Going forward: patch-per-PR.

### Changed

- **P1 Install honesty:** upgrade order is **npx first → then `./install.sh`** (or the curl/bash install.sh); `npx skills add` replaces the skill folder and **wipes** `scripts/`  
- README Upgrade row no longer treats the two paths as interchangeable / idempotent  

- **P1 Reconcile:** dual-plane who-wins — **AS-IS** code (and anchored matrix claims); **TO-BE** one living SSOT after classification  
- Date / mtime remains **evidence**, not a silent winner, on both planes (no date-wins engine)  
- Procedure [modes.md §6.8](skills/documentation-manager/references/modes.md#who-wins-as-is-vs-to-be); ADR-0002 reconcile row  

- **Glance version:** `SKILL.md` `description` starts with `v2.5.1 —` (Orderfield habit); `metadata.version` **2.5.1**  
- **P1 Docs:** first-contact honesty — documented procedures vs four on-demand loops (parse / persist / record / cascade-recommend); “has Haken” ≠ DB / daemon  
- **P1 Docs:** skill entry names the four on-demand kernel loops (`--list-claims` / `--upsert-claims` / `--record-haken` / `--cascade-recommend`); Haken ≠ DB / daemon  

### Added

- **P1 Install:** `install.sh` ships `audit-claims.sh` (required) plus `detect-stack.sh` / `detect-packages.sh` / `survey-docs.sh` / `generate-docs-dashboard.sh` into the installed skill `scripts/` (local clone and raw GitHub curl)  
- Agent resolve: installed skill `scripts/` first; consumer-repo `./scripts/` is opt-in CI only — [skill-discovery.md](skills/documentation-manager/references/skill-discovery.md#skill-runtime-scripts)  

- **P1 Audit:** valid-but-huge change set escape in [modes.md §6.0](skills/documentation-manager/references/modes.md#60-change-set-diff-first) — base is a real commit but the set is unusable → announce `docs-universe`, constrain to hub docs / Out sandbox, HITL optional (do not block forever); never a silent full-repo walk; never full-tree by default  
- Anti-snapshot: any count written into docs must carry its remeasure command beside it, or omit the number (do not inherit)  
- No new CLI walker; no auto-pick base  

- **P1 Docs:** English starter / follow-up prompt on the public README (copy-paste; first run or audit/sync)  

- **P1 Audit:** report stale / redundant / snapshot / fact-vs-changed-symbol narrative comments in the git change set (audit + sync)  
- Procedure [modes.md §6.10](skills/documentation-manager/references/modes.md#610-narrative-comments-report-first) — classify and emit §6.9 recommend-review (`path:line` + class); never auto-edit  
- Non-goals: auto-delete, full-tree campaign, CI gate on narrative comments, treating free prose as matrix rows  
- No new CLI (procedure over helper; `--list-changed` already scopes files)  

- **P1 Kernel:** cascade recommend from `parent=` in the change set (`audit-claims.sh --cascade-recommend`)  
- Parent released in the set (`status=changed`) → list **for-review** children already in the set that name that `parent=` + evidence + modes.md §6.9 block  
- Read-only (does not write the matrix); children not in the set are not listed (no repo-wide grep; documented gap)  
- Reuses `--list-claims` change-set parse; no graph walker  
- Fixture + hardening asserts on `scripts/fixtures/claims-breadcrumbs/`  

- **P0 Kernel:** record Haken verdicts on audit (`audit-claims.sh --record-haken`)  
- Writes hold / for-review to matrix **Action** (or an existing **Haken** column) with `path:line` + parent id; never into Verdict  
- escalate vs break / unclear `s≈f(q)` → HITL stderr; no silent invent; captain supersedes (not date-wins)  
- Reuses `--list-claims` change-set parse; no graph walker  
- Fixture + hardening asserts on `scripts/fixtures/claims-breadcrumbs/`  

- **P0 Kernel:** parse `@claim` breadcrumbs from the git change set only (`audit-claims.sh --list-claims`)  
- Reports `id` / `parent` / `plane` / `status` (path + line); malformed → HITL stderr + exit 1; never invents fields  
- Optional read-only note when a comment id is missing from the matrix (no matrix write)  
- Fixture: `scripts/fixtures/claims-breadcrumbs/` + hardening asserts  

### Fixed

- **C-062 / ArkGate dogfood note:** §7 distinguishes origin package vs host/consumer — when the working tree is ArkGate, the bridge applies (code wins)  
- **Cold-start survey heuristics** (LIVE FIELD DOGFOOD / [#11](https://github.com/pedroknigge/documentation-manager/issues/11)): case-insensitive root README (`Readme.md` counts); tight ADR homes/names (no `*adr*` substring — `TableHeadRenderer.tsx` is not an ADR); default claim/doc scope is `docs/` + root + `.github` and **excludes** `examples/**` unless you opt in  
- Helper: `scripts/survey-docs.sh` (same shape as `detect-stack.sh` / `detect-packages.sh`)  
- Flat CapCase `docs/*.md` stays **adopted** — never rewritten to the skill template tree  

### Removed

- **Template telemetry** withdrawn from the skill surface (P2 subtract vs [ADR-0002](docs/adr/0002-knowledge-enslavement-captain.md))  
- Deleted `scripts/template-telemetry.sh` and `references/template-telemetry.md`  
- Agents no longer load a telemetry mode, rule, or quality-checklist ritual  
- History: shipped in **2.4.0**; pack marked [Withdrawn](docs/features/template-telemetry/README.md)  

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
