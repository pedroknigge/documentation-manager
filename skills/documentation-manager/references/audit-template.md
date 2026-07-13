# Documentation claims audit

> Hub: [AGENTS.md](../../AGENTS.md) (adjust relative path)  
> **Code is source of truth.** Docs do not override implementation.

**Date:** YYYY-MM-DD  
**Scope:** project | feature:`slug`  
**Intent:** audit  
**Out:** root | sandbox:path  
**Auditor:** documentation-manager

## Summary

| Verdict | Count |
|---------|------:|
| OK | 0 |
| Partial | 0 |
| Missing | 0 |
| Contradicted | 0 |
| Unverifiable | 0 |

**Top risks:**  
1. …  
2. …

**Recommended next Intent:** integrate (patch) | from-zero (sandbox) | none  

## Code inventory (high level)

| Kind | Evidence (paths / symbols) | Notes |
|------|----------------------------|-------|
| ModuleIds / packages | | |
| UI surfaces | | |
| API route families | | |
| Data / schema areas | | |
| Jobs / kernel | | |

Do not paste full endpoint dumps into permanent product docs.

## Claims matrix

| ID | Claim (quote or paraphrase) | Source doc | Code evidence | Verdict | Action |
|----|----------------------------|------------|---------------|---------|--------|
| C-001 | | | | OK \| Partial \| Missing \| Contradicted \| Unverifiable | keep / fix doc / open Q |
| C-002 | | | | | |

### Verdict definitions

| Verdict | Meaning |
|---------|---------|
| **OK** | Matches code |
| **Partial** | Exists but incomplete vs claim |
| **Missing** | Not found in code |
| **Contradicted** | Code conflicts with claim |
| **Unverifiable** | Not a structural claim |

## Follow-on plan (optional)

- [ ] Patch Contradicted rows in productive docs  
- [ ] Add coverage matrix gaps  
- [ ] from-zero sandbox for clean KB  
- [ ] File net-new ADRs for decisions that only live in code  

## Related

- Status taxonomy for feature rows  
- adopt-integrate non-writes if next Intent is integrate  
