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
- [ ] Feature mode: did not force full product-vision/requirements suite
- [ ] Sync: only impacted docs touched
- [ ] No auto-commit / auto-push

## Mature-repo / adopt

- [ ] Maturity classified (`thin` | `mixed` | `mature`); variant announced (`full` | `integrate`)
- [ ] No parallel tree that rewrites existing ADRs/modules when mature
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
