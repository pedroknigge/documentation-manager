# Go / no-go — Gate A/B

> Hub: [AGENTS.md](../../AGENTS.md) (adjust relative path)  
> **Purpose:** signed **ops / TO-BE** production decision trail. Not a living-claims row.  
> *(Copy this file to consumer `docs/ops/go-nogo.md`. Adopt an evolved path if the captain already has one.)*  
> Binding: project §20 tables / Apéndice A **Gate A/B firmado**. If those tables exist in-repo, **copy the criteria verbatim** — do not invent a parallel checklist.

**Date:** YYYY-MM-DD  
**Scope:** project | release:`id`  
**Captain (human):** _name / handle — required to sign **Go**_  
**Recorder:** documentation-manager | human  
**Criteria source:** _path to project §20 / Apéndice A | pending captain_  
**Decision:** unanswered | **Go** | **No-Go**

**Golden rule:** if you cannot point to where an answer lives, it does not exist. **No greenwash.**

## Locked rules

| Block | Rule |
|-------|------|
| **A** | Any **No** → Decision **cannot be Go**. |
| **B** | **No** only with **owner + due date**. Missing either → row incomplete; cannot sign Go. |
| Evidence | Code / runnable evidence wins. **Never invent a Sí.** Unclear → HITL (human captain). |
| Dual-plane | This file is an **ops / TO-BE** record. It is **not** a code claim and **not** a living-claims matrix row. |
| CI | `audit-claims.sh` / living-claims CI **≠** production go/no-go. **Never auto-fill** Gate answers from the claims matrix or a green CI job. |
| Sign-off | Agents may propose rows and may record **No-Go** when Block A has a **No**. **Go** requires the **human captain**. |

Answers: **Sí** | **No** | **N/A justificado** | **unanswered**

- **Sí** — pointer to evidence (path, command, or artifact). No pointer → not Sí.  
- **No** — state what is missing; Block A No blocks Go; Block B No needs owner + due.  
- **N/A justificado** — one-line why this criterion does not apply (not a back-door Sí).  
- **unanswered** — default; do not upgrade to Sí to look complete.

## Gate A (Block A)

Any **No** in this table → Decision **cannot be Go**.

| ID | Criterion (§20 / Apéndice A) | Answer | Evidence (path / cmd / artifact) | N/A justification |
|----|------------------------------|--------|----------------------------------|-------------------|
| A-01 | _paste from project §20_ | unanswered | | |
| A-02 | _paste from project §20_ | unanswered | | |
| A-03 | _paste from project §20_ | unanswered | | |

Add or replace rows to match the project’s §20 Gate A table. Do not invent product facts to fill empty criteria.

## Gate B (Block B)

**No** allowed only with **owner + due date**.

| ID | Criterion (§20 / Apéndice A) | Answer | Evidence (path / cmd / artifact) | Owner | Due | N/A justification |
|----|------------------------------|--------|----------------------------------|-------|-----|-------------------|
| B-01 | _paste from project §20_ | unanswered | | | YYYY-MM-DD | |
| B-02 | _paste from project §20_ | unanswered | | | YYYY-MM-DD | |

## Residual risk

**residual-risk** (one sentence). What remains true after this decision (accepted risk, or why No-Go). Empty sentence → trail is incomplete; cannot sign Go.

## Decision record

| Field | Value |
|-------|-------|
| Decision | unanswered \| Go \| No-Go |
| Block A Nos | 0 \| list IDs |
| Block B Nos (owner + due) | none \| list IDs |
| Signed by (human captain) | _required for Go_ |
| Signed date | YYYY-MM-DD |

**Go** only when: Block A has zero **No** (all **Sí** or **N/A justificado**), every Block B **No** has owner + due, residual-risk sentence is present, and the human captain signed. Otherwise leave **unanswered** or record **No-Go**.

## Related

- Procedure: [modes.md §14](modes.md#14-gono-go-decision-trail-v254)  
- Living claims (different plane): [living-claims.md](living-claims.md) · [audit-template.md](audit-template.md)  
- Captain: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)  
