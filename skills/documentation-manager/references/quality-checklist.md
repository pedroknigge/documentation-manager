# Quality checklist

Run before reporting done.

## Accuracy

- [ ] Claims about behavior match code or are labeled as planned/inferred
- [ ] Paths, package names, and APIs are real (or marked TBD)
- [ ] No invented features or endpoints

## Structure

- [ ] Hub exists and links to every new/updated top-level doc
- [ ] Feature docs live under `docs/features/<kebab-slug>/` **unless the repo already evolved a different feature-doc path** — then adopt that path
- [ ] **No silent structure rewrite** — default layout is a proposal; templates were not forced over the captain ([ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md))
- [ ] Relative links work from their file location
- [ ] ADRs one decision per file; status + date present
- [ ] Feature status uses [status-taxonomy.md](status-taxonomy.md) tokens

## Scope discipline

- [ ] Project bootstrap: core set only (no empty feature trees)
- [ ] Feature / plan mode: did not force full product-vision/requirements suite
- [ ] Sync: only impacted docs touched
- [ ] No auto-commit / auto-push

## Feature autopilot / plan (v1.3 + v2)

- [ ] Named “new feature X” used **plan** or **feature** autopilot — not project from-zero
- [ ] No code / planning language → `docs/plans/<slug>/` from plan-template
- [ ] Code-backed surface → `docs/features/<slug>/` from feature template
- [ ] **Kind** set when signaled (new feature | spike | epic | redesign); epic → child slugs not mega-pack
- [ ] Default **non-writes** applied and listed (vision, requirements, unrelated ADRs/packs)
- [ ] User was **not** required to specify folders or non-writes
- [ ] Ask at most once (name / plan-vs-pack / multi-module split)
- [ ] Hub links Plans and/or Features as appropriate
- [ ] Promote path documented when plan written; promote updates plan status when packing
- [ ] **Implementation bridge:** off by default; on only for implement/stubs/scaffold language
- [ ] Stubs (if any) marked hypothesis; no Real public surface without code evidence
- [ ] Ark detected → placement uses layers/contract when filling bridge
- [ ] Promote uses **code** inventory, not stubs alone (implementation-bridge promote checklist)

## Intent / audit / from-zero

- [ ] **Intent** announced: `integrate` | `audit` | `from-zero` (or n/a for pure feature/sync)
- [ ] Announce line includes Intent and Out
- [ ] Code inventory ran before trusting existing docs (audit, from-zero, or drift-prone integrate)
- [ ] On conflict **code wins** — no inventing features to match docs
- [ ] Audit (if run): claims matrix with verdicts OK / Partial / Missing / Contradicted
- [ ] Audit / reconcile reads were **diff-first** (git change set); no full-tree scan unless the user opted in. Valid-but-huge set → announced `docs-universe` and constrained to hub docs / Out sandbox ([modes.md §6.0](modes.md#60-change-set-diff-first)) — not a silent full-repo walk; HITL optional (do not block forever)
- [ ] Cold-start / full-tree claim scope (if used) defaulted to `docs/` + root + `.github`; **`examples/**` excluded** unless opted in ([skill-discovery.md](skill-discovery.md) Cold-start survey heuristics)
- [ ] Cascade: recommended review only when a parent breadcrumb appears in the change set; apply [modes.md §6.7](modes.md#67-cascade-verdicts-haken) (hold / escalate / break / for-review); record with `audit-claims.sh --record-haken` on **Action** (or an existing Haken column) — never Verdict; list for-review with `--cascade-recommend` (children in the set only); HITL when ambiguous — captain decides ties; no cascade engine
- [ ] Reconcile: agent-written plans/MDs classified **evolution** / **regime change** / **orphan** / **contradiction** ([modes.md §6.8](modes.md#68-reconcile-classification-plansmds)); no living contradictions; **AS-IS** code wins / **TO-BE** one living SSOT; supersede marking — never parallel contradicting SSOT; latest-by-date does not auto-win on either plane; HITL when unclear — captain decides ties
- [ ] Recommend review: when cascade / reconcile / audit / narrative comments need eyes, recommend **human** or **agent** ([modes.md §6.9](modes.md#69-recommend-review-human-vs-agent)) with pointers into the change set / claims / class; `--cascade-recommend` lists the §6.9 block for for-review children already in the set; HITL → human; no assign, notify, merge, or engine
- [ ] Narrative comments: scanned **change-set files only**; classified stale / redundant / snapshot / fact-vs-changed-symbol ([modes.md §6.10](modes.md#610-narrative-comments-report-first)); emitted §6.9 recommend review with `path:line` + class; **no auto-edit / auto-delete**; did not treat free prose as matrix rows; no full-tree comment campaign; no CI gate on narrative comments
- [ ] from-zero: full KB only with that Intent; sandbox when path requested; old docs treated as hypothesis
- [ ] from-zero does not silently overwrite mature productive SSOT without confirm
- [ ] Project from-zero / integrate: **§2 Mínimo** proposed or mapped ([modes.md §16](modes.md#16-product-domain-minimo)) — no invented product facts
- [ ] Project audit: §2 presence scored **only** if a product-domain doc is in the §6.0 set or announced docs-universe — no tree walk to find vision

## Go/no-go Gate A/B (v2.5.4)

- [ ] Production decision trail written to `docs/ops/go-nogo.md` (or adopted evolved path) from [go-nogo-template.md](go-nogo-template.md) when go/no-go / Gate A/B / production gate was in scope
- [ ] Criteria copied from the project’s **§20** / Apéndice A **Gate A/B firmado** — no invented parallel checklist; no invented product facts
- [ ] Answers are **Sí** / **No** / **N/A justificado** / **unanswered**; **Sí** has an evidence pointer; **never invent a Sí**; no greenwash
- [ ] **Gate A:** any **No** → Decision **cannot be Go**
- [ ] **Gate B:** **No** only with **owner + due date**
- [ ] **One residual-risk sentence** present (or trail left unsigned)
- [ ] Dual-plane: trail is ops / TO-BE — **not** a living-claims row; **living-claims CI ≠ production go/no-go**; did not auto-fill from `audit-claims.sh`
- [ ] **Go** signed only by the **human captain**; HITL when unclear

## Living claims + CI audit (v2.5)

- [ ] Structural claims use living-claims columns: Anchor path (+ optional symbol/hash) and Severity (`critical` \| `normal`)
- [ ] Wire matches [living-claims.md](living-claims.md) / [ADR-0001](../../../docs/adr/0001-living-claims-wire-format.md) — matrix-first, no parallel wiki
- [ ] Verdict enum unchanged; omitted severity treated as `normal`
- [ ] Truth score described as **advisory**; **CI / `audit-claims.sh`** is the gate for critical Contradicted (whole matrix; agent reads stay **diff-first**)
- [ ] Breadcrumbs: `audit-claims.sh --list-claims` on the §6.0 set; HITL if malformed; do not invent ids; persist with `--upsert-claims`; record §6.7 with `--record-haken` (Action / existing Haken column; never Verdict); list §6.9 for-review with `--cascade-recommend` (set + visible `parent=` only)
- [ ] Domain invariants encoded as `@claim` + matrix rows ([living-claims.md](living-claims.md#domain-invariants-dual-plane-cookbook)); same dual-plane who-wins — no second regime; no greenwash OK
- [ ] Did not invent code to satisfy a claim; did not auto-commit
- [ ] No SaaS/control-plane invented for the core gate (local/air-gapped)

## ArkGate bridge (v1.4)

- [ ] Detection ran when adopt/audit/sync or user mentioned Ark/gate (signals documented in arkgate-bridge.md)
- [ ] No Ark signals → bridge no-op (not required)
- [ ] Post-gate **pass** → scoped sync/audit offered or run with announce-before-write
- [ ] Residual violations → Contradicted/Partial claims; docs not rewritten to excuse architecture debt
- [ ] Did not edit `ark.config.json` or app source as part of this skill
- [ ] No hardcoded gate/violation **counts** in permanent narrative docs (anti-snapshot)
- [ ] Non-writes listed when bridge writes

## Polyglot stack detection (v2.1)

- [ ] Project-level work: **Stack** detected (`node-ts` | `python` | `go` | `mixed` | `unknown`) via [skill-discovery.md](skill-discovery.md) Polyglot stack detection (or `detect-stack.sh`)
- [ ] Inventory used **Inventory by stack** rows — not Node/TS-only defaults on Python/Go repos
- [ ] Feature/plan slug sources follow **Docs layout guidance by stack**
- [ ] No invented ModuleIds/endpoints/framework surfaces without code evidence
- [ ] Announce line includes `Stack: …` when Intent is integrate / audit / from-zero

## Monorepo hubs (v2.2)

- [ ] Monorepo signals checked (`pnpm-workspace` / workspaces / `go.work` / multi-package) or `detect-packages.sh`
- [ ] If monorepo: root hub is a **map** with **Package index** (not a narrative dump)
- [ ] Multi-package **Surface coverage** rows; packages without docs marked **gap**
- [ ] Default package **non-writes** when only indexing root (no rewrite of mature package vision/ADRs/packs)
- [ ] No mega feature pack swallowing all packages; one authority per package topic

## Team governance (v2.3)

- [ ] Team work used [team-governance.md](team-governance.md): **create** vs **link** decided deliberately
- [ ] Layout `docs/team/` with **OWNERS.md** (and approval-notes if requested); templates not invented HR wiki
- [ ] Hub links Team as a **pointer** only
- [ ] Integrate-first: adding team did **not** rewrite product-vision / requirements / ADRs
- [ ] No invented owner names; empty owner = gap
- [ ] Approval notes are last-approved style only — no BPM / ticket clone

## Product domain Mínimo (v2.5.6 · Pedro norte §2)

Closed checklist: [modes.md §16](modes.md#16-product-domain-minimo). Parent: §2 Producto y dominio (Mínimo). Does **not** reuse modes §14 (go/no-go) or §15 (Appendix A).

- [ ] Pack items considered: problem·user·**JTBD** one page; **MVP scope + non-goals**; critical flows **alta / login / valor / pago / baja/export**; **1–2 success metrics**; **killer assumptions**
- [ ] from-zero / bootstrap / adopt-full: **proposed** into the adopted or proposed home — Confirmed / Inferred / gap; **never invent product facts**
- [ ] integrate: **mapped** onto the evolved home; gaps listed; did **not** force `product-vision.md` over the captain
- [ ] audit: presence tokens Present / Partial / **Missing** / N/A-with-evidence; **Missing stays Missing** (never OK; never greenwash)
- [ ] N/A used only for a critical flow with a one-line evidence note — not as a synonym for Missing
- [ ] Diff-first / docs-universe **unchanged** — no full-tree walk to find vision
- [ ] Did not write a real product’s JTBD for this skill-package repo; did not add Sólido edges/states here

## Knowledge dashboard (v1.6)

- [ ] Generated only from existing docs (no invented features/claims for the UI)
- [ ] Output under generated path (default `docs/audit/generated/`); not treated as SSOT
- [ ] Offline / no required CDN
- [ ] Links back to markdown sources
- [ ] Did not auto-commit generated HTML
- [ ] Auto-open browser only if user asked

## Mature-repo / adopt

- [ ] Maturity classified (`thin` | `mixed` | `mature`); variant announced (`full` | `integrate`)
- [ ] No parallel tree that rewrites existing ADRs/modules when mature **and Intent=integrate**
- [ ] Evolved layout **adopted** (integrate) — did not reshape `docs/` to match the recommended tree; HITL before any reshape
- [ ] Root README detected **case-insensitively** (`Readme.md` counts — do not report “no README”)
- [ ] ADRs from **real ADR homes/names** only — no `*adr*` substring glob (e.g. `TableHeadRenderer.tsx` is not an ADR)
- [ ] Coverage matrix (Surface coverage) lists discovered surfaces; gaps explicit
- [ ] ADR numbering matches repo scheme; no duplicate decisions
- [ ] Feature packs are entry points (surface + links) when module docs already exist — not re-dumps
- [ ] Clusters use index + children; no undocumented mega-domain single pack
- [ ] Product-vision (if written) has product outcomes only — not maintainer/process rules
- [ ] Sandbox (if used): non-SSOT banner + promotion plan in summary

## Snapshots

- [ ] No hardcoded table/route/endpoint counts. Any published count carries its remeasure command beside it (or the number is omitted) — [modes.md §6.0](modes.md#60-change-set-diff-first)
- [ ] `api.md` = conventions + discovery + authZ pattern (not full inventory unless asked)
- [ ] `data-model.md` = invariants + ownership + links (not full schema dump)

## Usefulness

- [ ] Overview sections are short and scannable
- [ ] Acceptance criteria or success metrics where decisions depend on them
- [ ] Mermaid/diagrams only where they clarify
- [ ] Open questions listed instead of silent assumptions
- [ ] Integrate mode: non-writes listed in session summary

## Agent readiness

- [ ] Hub tells agents to read docs before major work and update after
- [ ] "Code wins for how; docs capture why/what" is clear
- [ ] Last updated / status line refreshed
- [ ] Adopt: Surface coverage section present on hub

## Prototype → production (Apéndice A)

- [ ] Loaded [prototype-to-production.md](prototype-to-production.md) when production-checklist / Apéndice A was in scope
- [ ] Did not claim **generate** for artifacts marked **audits** or **out-of-scope (captain)**
- [ ] Did not invent threat model, SEV runbooks, or a data inventory; did not claim a signed Go (trail is §14 proposal; captain signs)
- [ ] Human remained captain; tool proposed only

## Production-harden DoD (Pedro norte §2 / §20)

When Intent is **production-harden** (“no volver a prototipo”, “endurecer a producción”, harden for production). Product Definition of Done — **not** a signed Gate A/B **Go** (that stays [modes.md §14](modes.md#14-gono-go-decision-trail-v254) / captain). Reuses [§16](modes.md#16-product-domain-minimo) Mínimo + §14 §20 trail + living claims. Procedure: [modes.md §17](modes.md#17-production-harden-dod). Critical-entity transition maps: [modes.md §18](modes.md#18-solido-statestransitions) — Missing stays Missing when shipping.

- [ ] Domain-changing PR / change set: **claims/matrix updated** (diff-first) — new or changed domain sentences have `@claim` + matrix rows, or an honest Missing / Contradicted; **no greenwash OK**
- [ ] **§2** Mínimo not dropped: presence or mapped still scored if in scope; Missing stays Missing ([modes.md §16](modes.md#16-product-domain-minimo))
- [ ] Shipping / production-harden: if a critical entity in the in-scope domain doc has no states/transitions map → **Missing** ([modes.md §18](modes.md#18-solido-statestransitions)) — never OK
- [ ] **§20** / Apéndice A Gate A/B criteria still copied (not invented); never invent a Sí; living-claims CI ≠ production go/no-go
- [ ] Captain / HITL: skill proposes; human signs; no auto-merge; no invented Sí

## Sólido states/transitions (v2.5.9 · Pedro norte §2)

Closed artifact: [modes.md §18](modes.md#18-solido-statestransitions). Parent: §2 Producto y dominio (Sólido — estados y transiciones). Does **not** reuse modes §14–§17 as the procedure (those stay numbered as shipped). Presence tokens: [§16.2](modes.md#162-presence-tokens-closed).

- [ ] Artifact is a compact table (**entity** | **states** | **allowed transitions** | **notes**) **or** one link to the captain’s existing authority — **no flag soup**
- [ ] from-zero / bootstrap / adopt-full: **proposed** into the adopted or proposed home — Confirmed / Inferred / gap; **never invent domain states**
- [ ] integrate: **mapped** onto the evolved home; gaps listed; did **not** force a filename over the captain
- [ ] audit: presence scored **only** if a product-domain / domain-model doc is in the §6.0 set or announced docs-universe — no tree walk to find vision/domain
- [ ] Presence tokens Present / Partial / **Missing** / N/A-with-evidence; **Missing stays Missing** (never OK; never greenwash)
- [ ] Intent=`production-harden` / shipping language: critical entity with no transition map reported **Missing** (DoD tie §17)
- [ ] Did not invent a real product’s state machine for this skill-package repo; did not add CLI / matrix verdicts / living-claims wire

## Voice

- [ ] Matches repo language (or user's language)
- [ ] Concrete nouns, active voice, no filler
- [ ] Prefer "you can…" / "the system does…" over vague corporate tone
