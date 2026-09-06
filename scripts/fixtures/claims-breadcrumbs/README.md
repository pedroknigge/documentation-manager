# claims-breadcrumbs — @claim corpus (`--list-claims` + `--upsert-claims`)

Static breadcrumb samples. Hardening copies this tree into a **temp git repo** and dirties selected files — both flags are change-set only (never a full-tree grep). `--list-claims` is read-only; `--upsert-claims` writes the matrix.

| Path | Shape |
|------|--------|
| `src/ok.ts` | valid `id=C-001 parent=C-002 plane=P1 status=changed` — upsert **updates** Action touch/status |
| `src/ok.py` | valid `id=C-002` (no parent) `plane=P2 status=adjusted` |
| `src/untouched.ts` | valid breadcrumb that must **not** appear unless that file is in the change set; vs `C-001` Anchor → HITL refuse |
| `src/malformed.ts` | missing plane / bad status / two `parent=` / invalid plane — upsert writes nothing |
| `src/unknown-id.ts` | `id=C-999` present in the comment, **absent** from the matrix — upsert **inserts** |
| `docs/audit/claims-matrix.md` | `C-001`, `C-002` only (SSOT of ids) |
