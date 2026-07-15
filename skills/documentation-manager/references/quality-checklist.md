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
- [ ] from-zero: full KB only with that Intent; sandbox when path requested; old docs treated as hypothesis
- [ ] from-zero does not silently overwrite mature productive SSOT without confirm

## ArkGate bridge (v1.4)

- [ ] Detection ran when adopt/audit/sync or user mentioned Ark/gate (signals documented in arkgate-bridge.md)
- [ ] No Ark signals → bridge no-op (not required)
- [ ] Post-gate **pass** → scoped sync/audit offered or run with announce-before-write
- [ ] Residual violations → Contradicted/Partial claims; docs not rewritten to excuse architecture debt
- [ ] Did not edit `ark.config.json` or app source as part of this skill
- [ ] No hardcoded gate/violation **counts** in permanent narrative docs (anti-snapshot)
- [ ] Non-writes listed when bridge writes

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
