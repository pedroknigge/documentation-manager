# Claims matrix fixture — all OK (must PASS audit-claims.sh)

## Claims matrix

| ID | Claim | Source doc | Code evidence | Anchor | Severity | Verdict | Action |
|----|-------|------------|---------------|--------|----------|---------|--------|
| C-001 | Entrypoint script exists | README | `scripts/audit-claims.sh` | `anchor.path=scripts/audit-claims.sh` | critical | OK | keep |
| C-002 | Air-gapped (no network in gate) | modes | local shell only | `anchor.path=scripts/audit-claims.sh` | normal | OK | keep |
| C-003 | Optional partial coverage | notes | n/a | | normal | Partial | keep |
