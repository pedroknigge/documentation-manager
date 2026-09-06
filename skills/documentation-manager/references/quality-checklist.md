# Quality checklist

Run before reporting done.

## Accuracy

- [ ] Claims about behavior match code or are labeled as planned/inferred
- [ ] Paths, package names, and APIs are real (or marked TBD)
- [ ] No invented features or endpoints

## Structure

- [ ] Hub exists and links to every new/updated top-level doc
- [ ] Feature docs live under `docs/features/<kebab-slug>/`
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
- [ ] Audit / reconcile reads were **diff-first** (git change set); no full-tree scan unless the user opted in
- [ ] Cascade: recommended review only when a parent breadcrumb appears in the change set; apply [modes.md §6.7](modes.md#67-cascade-verdicts-haken) (hold / escalate / break / for-review); HITL when ambiguous — captain decides ties; no cascade engine
- [ ] Reconcile: agent-written plans/MDs classified **evolution** / **regime change** / **orphan** / **contradiction** ([modes.md §6.8](modes.md#68-reconcile-classification-plansmds)); no living contradictions; supersede marking — never parallel contradicting SSOT; latest-by-date does not auto-win; HITL when unclear — captain decides ties
- [ ] Recommend review: when cascade / reconcile / audit needs eyes, recommend **human** or **agent** ([modes.md §6.9](modes.md#69-recommend-review-human-vs-agent)) with pointers into the change set / claims / class; HITL → human; no assign, notify, merge, or engine
- [ ] from-zero: full KB only with that Intent; sandbox when path requested; old docs treated as hypothesis
- [ ] from-zero does not silently overwrite mature productive SSOT without confirm

## Living claims + CI audit (v2.5)

- [ ] Structural claims use living-claims columns: Anchor path (+ optional symbol/hash) and Severity (`critical` \| `normal`)
- [ ] Wire matches [living-claims.md](living-claims.md) / [ADR-0001](../../../docs/adr/0001-living-claims-wire-format.md) — matrix-first, no parallel wiki
- [ ] Verdict enum unchanged; omitted severity treated as `normal`
- [ ] Truth score described as **advisory**; **CI / `audit-claims.sh`** is the gate for critical Contradicted
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

## Template telemetry (v2.4)

- [ ] Telemetry **default off**; enabled only with explicit user opt-in
- [ ] Events are **template/skill UX gaps** only — no product source, secrets, or repo URLs
- [ ] Local ledger only (`template-telemetry.sh`); **network never**
- [ ] Air-gapped path verified: skill usable with opt-in off (no-op record)
- [ ] Never-send list respected ([template-telemetry.md](template-telemetry.md))

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
- [ ] Coverage matrix (Surface coverage) lists discovered surfaces; gaps explicit
- [ ] ADR numbering matches repo scheme; no duplicate decisions
- [ ] Feature packs are entry points (surface + links) when module docs already exist — not re-dumps
- [ ] Clusters use index + children; no undocumented mega-domain single pack
- [ ] Product-vision (if written) has product outcomes only — not maintainer/process rules
- [ ] Sandbox (if used): non-SSOT banner + promotion plan in summary

## Snapshots

- [ ] No hardcoded table/route/endpoint counts
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

## Voice

- [ ] Matches repo language (or user's language)
- [ ] Concrete nouns, active voice, no filler
- [ ] Prefer "you can…" / "the system does…" over vague corporate tone
