# Knowledge dashboard (v1.6)

Static **HTML view** of `docs/` knowledge for humans. **Markdown remains SSOT.** Never edit the HTML as documentation authority.

## When to generate

| Signal | Action |
|--------|--------|
| User: “dashboard”, “docs HTML report”, “knowledge dashboard” | Generate |
| After **audit** (optional once) | Offer generate — do not spam every sync |
| Post-gate Ark bridge (optional) | Offer if matrix or packs changed |
| CI / packaging | Optional artifact; prefer gitignored |

## Command

From the **consumer project root** (or this skill package):

```bash
./scripts/generate-docs-dashboard.sh [project-root] [output-path]
```

Defaults:

- `project-root` = current directory  
- `output-path` = `docs/audit/generated/dashboard.html`

The script lives at package root `scripts/generate-docs-dashboard.sh`. **`install.sh` copies it into the installed skill as `…/documentation-manager/scripts/generate-docs-dashboard.sh`** (same ship path as the other [skill-runtime scripts](skill-discovery.md#skill-runtime-scripts)).

If the script is still missing (partial install / old host), either:

1. Re-run `install.sh` / install from a full clone, or  
2. Agent reimplements the same **read-only scan** (features/plans README meta + optional claims matrix) and writes the HTML.

From this package repo:

```bash
./scripts/generate-docs-dashboard.sh .
# → docs/audit/generated/dashboard.html
```

From an installed skill tree (after install.sh):

```bash
~/.agents/skills/documentation-manager/scripts/generate-docs-dashboard.sh /path/to/project
```

## What it reads (no invention)

| Source | Fields |
|--------|--------|
| `docs/features/*/README.md` | `#` title, `**Status:**`, `**Slug:**` |
| `docs/plans/*/README.md` | same |
| `docs/audit/claims-matrix.md` | structural verdict token counts only |
| `AGENTS.md` / `docs/roadmap.md` | nav links |

Missing matrix → empty claims section (honest “not found”), not fake scores.

**Truth score is advisory.** Enforcement for **critical Contradicted** is local CI (`scripts/audit-claims.sh` / docs-audit) — see [living-claims.md](living-claims.md).

## Output policy

- Default path under `docs/audit/generated/` — **gitignore** in consumer repos (and this package).  
- Banner in HTML: **View only** / Markdown SSOT.  
- Offline: single file, **no CDN**.  
- Auto-open browser: **opt-in** only (`open file://…` if user asks).

## Skill announce

```text
Dashboard: generated | path: docs/audit/generated/dashboard.html | SSOT: markdown
```

## Non-writes

- Do not rewrite feature/plan bodies just to feed the dashboard.  
- Do not treat HTML as audit evidence over code.  
- Do not auto-commit the generated file.
