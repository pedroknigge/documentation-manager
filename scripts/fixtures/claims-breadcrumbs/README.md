# claims-breadcrumbs — @claim parser corpus (audit-claims.sh --list-claims)

Static breadcrumb samples. Hardening copies this tree into a **temp git repo** and dirties selected files — `--list-claims` is change-set only (never a full-tree grep).

| Path | Shape |
|------|--------|
| `src/ok.ts` | valid `id=C-001 parent=C-002 plane=P1 status=changed` |
| `src/ok.py` | valid `id=C-002` (no parent) `plane=P2 status=adjusted` |
| `src/untouched.ts` | valid breadcrumb that must **not** appear unless that file is in the change set |
| `src/malformed.ts` | missing plane / bad status / two `parent=` / invalid plane |
| `src/unknown-id.ts` | `id=C-999` present in the comment, **absent** from the matrix |
| `docs/audit/claims-matrix.md` | `C-001`, `C-002` only (read-only cross-check) |
