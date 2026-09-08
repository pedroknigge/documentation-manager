# Adoption matrix — documentation-manager v2.5

> Hub: [AGENTS.md](../AGENTS.md) · [Roadmap](./roadmap.md) · Companion: [ArkGate](https://github.com/pedroknigge/arkgate)  
> **Purpose:** Track where this skill is (or should be) installed, and the ArkGate pairing path.  
> **Honesty rule:** only mark **Verified** when someone ran install/validate against that target. Hypotheses stay **Candidate**.

**Last updated:** 2026-09-08 · Skill version **2.5.10**

## How to use

1. Add a row when you install Documentation Manager on a real project.  
2. Status tokens: `Candidate` | `Installed` | `Verified` | `Churned`.  
3. Pairing: `none` | `ArkGate present` | `bridge exercised` (post-gate docs pass once).  
4. Do **not** invent install counts or stars.

## Package / distribution

| Channel | Path / command | Status | Notes |
|---------|----------------|--------|-------|
| GitHub source | [pedroknigge/documentation-manager](https://github.com/pedroknigge/documentation-manager) | Verified | Skill package repo |
| npx skills | `npx skills add pedroknigge/documentation-manager` | Candidate | Re-verify after each publish |
| Classic install | `./install.sh` or curl main install.sh | Verified | Covered by `install-smoke.sh` |
| Hosts | Claude Code · Grok · Codex · Cursor · Gemini CLI | Candidate | Any host that loads `SKILL.md`; Gemini via `~/.gemini/skills/` |

## 10× capability surface (what adopters get in v2.0)

| Capability | Since | Entry |
|------------|-------|-------|
| Intent integrate / audit / from-zero | 1.2 | [SKILL.md](../skills/documentation-manager/SKILL.md) |
| Feature autopilot + plans | 1.3 | modes §3 |
| Feature autopilot v2 + Implementation bridge | 1.5 | [implementation-bridge.md](../skills/documentation-manager/references/implementation-bridge.md) |
| ArkGate bridge (post-gate sync/audit) | 1.4 | [arkgate-bridge.md](../skills/documentation-manager/references/arkgate-bridge.md) |
| Knowledge dashboard (HTML view) | 1.6 | `scripts/generate-docs-dashboard.sh` |
| Hardening suite + discovery | 1.7 | `scripts/test-skill-hardening.sh` · [skill-discovery.md](../skills/documentation-manager/references/skill-discovery.md) |
| Adoption matrix (this file) | **2.0** | packaging + tracking |
| Polyglot stack detection (Python/Go/Node-TS) | **2.1** | [polyglot-mvp](./features/polyglot-mvp/README.md) · `detect-stack.sh` |
| Monorepo hubs (package index + root map) | **2.2** | [monorepo-hubs](./features/monorepo-hubs/README.md) · `detect-packages.sh` |
| Team governance (`docs/team/` owners + notes) | **2.3** | [team-governance](./features/team-governance/README.md) |
| Template telemetry (opt-in local ledger) | **2.4** | [Withdrawn](./features/template-telemetry/README.md) — not on the current skill surface (does not serve north star) |
| Living claims v0 + local CI structural audit | **2.5** | [living-claims](./features/living-claims/README.md) · `audit-claims.sh` — Knowledge OS **first increment** (toward 100×; not a second 10×) |
| Go/no-go Gate A/B trail (ops/TO-BE) | **2.5.4** | [go-nogo](./features/go-nogo/README.md) · `docs/ops/go-nogo.md` — not living-claims CI |
| §2 Mínimo product-domain (propose + presence) | **2.5.6** | [modes.md §16](../skills/documentation-manager/references/modes.md#16-product-domain-minimo) — Missing ≠ OK; adopt evolved home |
| Production-harden DoD (§2 / §20 + claims/matrix) | **2.5.8** | [modes.md §17](../skills/documentation-manager/references/modes.md#17-production-harden-dod) · [quality-checklist.md](../skills/documentation-manager/references/quality-checklist.md) — not a signed Go |
| Cold-agent readable (file-alone intent) | **2.5.10** | [modes.md §19](../skills/documentation-manager/references/modes.md#19-cold-agent-readable) · [quality-checklist.md](../skills/documentation-manager/references/quality-checklist.md) — dual reading → gap / HITL |

## Target projects

| Project | Role | Docs skill | ArkGate | Pairing | Status | Last checked |
|---------|------|------------|---------|---------|--------|--------------|
| documentation-manager (this repo) | Skill package dogfood | native | no (skill-only) | n/a | Verified | 2026-07-15 |
| arkgate (`pedroknigge/arkgate` / local `Desktop/ARK/v1`) | Architecture gate companion | Candidate install | Verified product | bridge designed for | Candidate | — |
| Consumer apps with `ark.config.json` | Real product codebases | Candidate | Present when config exists | post-gate docs | Candidate | — |
| Brownfield mature monorepos | integrate-first path | Candidate | optional | — | Candidate | — |
| Greenfield / sandbox `test/` | from-zero | Candidate | optional | — | Candidate | — |

### Local machine notes (non-canonical)

These paths may exist on a maintainer machine and are useful for dogfood; they are **not** public adoption claims:

| Path hint | Why relevant |
|-----------|----------------|
| `…/ARK/v1` | Full ArkGate product + `ark.config.json` |
| Repos with `.ark/` + `ark.config.json` | Natural bridge targets |

Update the public table above only when install is intentional and recorded.

## Adoption checklist (per target)

- [ ] Install skill (`npx skills add` or `install.sh`)  
- [ ] Confirm version ≥ **2.0.0** in installed `SKILL.md`  
- [ ] Hub + docs layout exists or created via integrate/from-zero  
- [ ] If ArkGate present: run gate once → Documentation Manager bridge offer  
- [ ] Optional: `./scripts/generate-docs-dashboard.sh`  
- [ ] Row status → **Verified**

## Metrics (honest)

Sales/dogfood anonymous metrics live at [sales-stats.json](./sales-stats.json) (usable by marketing agents; no target names). Aggregates also back or lower README claims when evidence changes (code wins).

| Metric | Baseline (v1.3 era) | v2.0 packaging | How measured |
|--------|---------------------|----------------|--------------|
| Install friction | Manual discover | install + discovery docs | Time to first hub |
| Post-change docs precision | Manual audit only | audit + Ark bridge procedure | Claims matrix usage |
| Regression safety | smoke only | fixtures + golden anchors | `validate-skill.sh` |
| Public multi-repo installs | Low / unknown | Matrix rows | This file |

×10 adoption is an **objective**, not a claim of current install count.

## Related

- Roadmap: [roadmap.md](./roadmap.md)  
- Feature pack: [features/tenx-v2-release/README.md](./features/tenx-v2-release/README.md)  
- Publish: [PUBLISH.md](../PUBLISH.md)  
- CHANGELOG: [CHANGELOG.md](../CHANGELOG.md)
