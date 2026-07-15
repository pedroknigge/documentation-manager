# Skill fixtures (hardening)

Synthetic **project roots** and **golden tables** used by `scripts/validate-skill.sh` / `scripts/test-skill-hardening.sh`.

| Fixture | Intent | Shape |
|---------|--------|--------|
| `thin-repo/` | adopt-full / from-zero candidate | code + README, no `AGENTS.md` / `docs/` |
| `mature-repo/` | integrate / plan-vs-feature | hub + roadmap + feature pack + plan + code |
| `no-docs-repo/` | bootstrap | README only |
| `golden/autopilot-cases.tsv` | mode regression | anchors must exist in SKILL/modes |

These are **not** full agent e2e runs. They lock layout expectations and decision-table contracts so refactors fail fast.
