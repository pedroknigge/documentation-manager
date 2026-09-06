# Claims matrix fixture — breadcrumb id SSOT (list-claims read / upsert-claims write / record-haken Action)

## Claims matrix

| ID | Claim | Source doc | Code evidence | Anchor | Severity | Verdict | Action |
|----|-------|------------|---------------|--------|----------|---------|--------|
| C-001 | Checkout export exists | README | `src/ok.ts` | `anchor.path=src/ok.ts` | normal | OK | keep |
| C-002 | Checkout helper exists | README | `src/ok.py` | `anchor.path=src/ok.py` | normal | OK | keep |
| C-010 | Hold child still enslaved | README | `src/haken-hold.ts` | `anchor.path=src/haken-hold.ts` | normal | OK | keep |
| C-011 | For-review child | README | `src/haken-child.ts` | `anchor.path=src/haken-child.ts` | normal | OK | keep |
| C-012 | Released parent | README | `src/haken-released.ts` | `anchor.path=src/haken-released.ts` | normal | OK | keep |
