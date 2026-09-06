# Skill fixtures (hardening)

Synthetic **project roots** and **golden tables** used by `scripts/validate-skill.sh` / `scripts/test-skill-hardening.sh`.

| Fixture | Intent | Shape |
|---------|--------|--------|
| `thin-repo/` | adopt-full / from-zero candidate | Node/TS code + README, no `AGENTS.md` / `docs/` |
| `python-thin-repo/` | polyglot MVP | `pyproject.toml` + `src/hello_app/`, no hub/docs |
| `go-thin-repo/` | polyglot MVP | `go.mod` + `cmd/` + `internal/`, no hub/docs |
| `monorepo-thin/` | monorepo hubs | workspaces + `packages/api` + `packages/web`, no root hub/docs |
| `mature-repo/` | integrate / plan-vs-feature | hub + roadmap + feature pack + plan + code |
| `no-docs-repo/` | bootstrap | README only |
| `golden/autopilot-cases.tsv` | mode regression | anchors must exist in SKILL/modes |
| `claims-pass/` | audit-claims.sh PASS | matrix with OK / Partial only |
| `claims-fail/` | audit-claims.sh FAIL | critical + Contradicted row |
| `claims-none/` | audit-claims.sh skip | no `docs/audit/claims-matrix.md` |
| `survey-heuristics/` | survey-docs.sh | CapCase `Readme.md`; `docs/adr/0001-…`; `examples/` demo MD; `TableHeadRenderer.tsx` |

Stack detection smoke: `scripts/detect-stack.sh scripts/fixtures/<fixture>`.  
Package list smoke: `scripts/detect-packages.sh scripts/fixtures/monorepo-thin`.  
Claims gate smoke: `scripts/audit-claims.sh scripts/fixtures/claims-{pass,fail,none}`.  
Survey heuristics smoke: `scripts/survey-docs.sh --readme|--adrs|--claim-scope scripts/fixtures/survey-heuristics`.

These are **not** full agent e2e runs. They lock layout expectations and decision-table contracts so refactors fail fast.
