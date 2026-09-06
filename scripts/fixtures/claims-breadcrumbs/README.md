# claims-breadcrumbs — `@claim` corpus (`--list-claims` + `--upsert-claims` + `--record-haken` + `--cascade-recommend`)

Static breadcrumb samples. Hardening copies this tree into a **temp git repo** and dirties selected files — flags are change-set only (never a full-tree grep). `--list-claims` is read-only; `--upsert-claims` writes touched ids; `--record-haken` writes §6.7 tokens to Action (never Verdict); `--cascade-recommend` lists §6.9 for-review (read-only; no walker).

| Path | Shape |
|------|--------|
| `src/ok.ts` | valid `id=C-001 parent=C-002 plane=P1 status=changed` — upsert **updates** Action touch/status; record-haken **HITL** (escalate vs break) |
| `src/ok.py` | valid `id=C-002` (no parent) `plane=P2 status=adjusted` — no Haken trigger alone |
| `src/untouched.ts` | valid breadcrumb that must **not** appear unless that file is in the change set; vs `C-001` Anchor → HITL refuse |
| `src/malformed.ts` | missing plane / bad status / two `parent=` / invalid plane — helpers write nothing |
| `src/unknown-id.ts` | `id=C-999` present in the comment, **absent** from the matrix — upsert **inserts** |
| `src/haken-hold.ts` | `id=C-010 parent=C-002 status=adjusted` — record-haken **hold** |
| `src/haken-child.ts` | `id=C-011 parent=C-012 status=adjusted` — with `haken-released.ts` → **for-review** (record-haken write + cascade-recommend list) |
| `src/haken-released.ts` | `id=C-012` (no parent) `status=changed` — released parent in the set; alone → cascade-recommend lists no children (gap; no grep) |
| `src/haken-new.ts` | `id=C-998 parent=C-002 status=adjusted` — absent from the matrix; record-haken **inserts** + hold |
| `docs/audit/claims-matrix.md` | `C-001`, `C-002`, `C-010`, `C-011`, `C-012` (SSOT of ids) |
