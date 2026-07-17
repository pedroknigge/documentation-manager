# Team governance (v2.3 Slice C)

Lightweight **owners** and **approval notes** for the knowledge base. Markdown only — not CODEOWNERS enforcement, merge bots, IAM, or workflow BPM.

## Consumer layout

```
docs/team/
├── OWNERS.md              # who owns which surface / package / doc area
└── approval-notes.md      # last-approved style notes (append-friendly)
```

Optional: link both from hub Key Links as **Team** → `docs/team/OWNERS.md` (or a one-line index). Do **not** invent `docs/team/handbook.md`, org charts, or HR process pages.

Templates (copy into the consumer repo):

| Template | Consumer path |
|----------|----------------|
| [team-owners-template.md](team-owners-template.md) | `docs/team/OWNERS.md` |
| [team-approval-notes-template.md](team-approval-notes-template.md) | `docs/team/approval-notes.md` |

## When to create vs link

| Situation | Action |
|-----------|--------|
| No `docs/team/` and user asks for owners / team / governance / “quién es dueño” | **Create** minimal `OWNERS.md` (+ `approval-notes.md` if approval trail requested) |
| `docs/team/` or equivalent already exists | **Link** from hub; extend rows only; do not fork a parallel tree |
| Mature repo + Intent **integrate** and team not requested | **Optional** one-line hub link if owners already live elsewhere (CODEOWNERS, CLAUDE.md) — do not force full `docs/team/` |
| Intent **from-zero** | May include `docs/team/` in core set **only** if ownership is known from user/code; otherwise leave gap / TBD, do not invent people |
| Monorepo (Slice B) | Prefer **package-scoped** owner rows (`packages/api` …) aligned with Package index; root OWNERS is still the index authority for ownership |

## Integrate-first (non-writes)

When adding or refreshing team docs only:

| Default non-writes |
|--------------------|
| product-vision, requirements, architecture rewrites |
| Existing ADRs renumbered or forked |
| Feature packs rewritten “to match owners” |
| Parallel HR wiki under `docs/team/` |

Allowed: create/link `docs/team/*`, hub Key Links row, monorepo package owner rows, one **last approved** note when user states an approval.

## Approval notes (“last approved”)

- Append-friendly log or last-write table — keep short: **what** (doc/surface), **when** (date), **who** (name/handle), optional **note**.  
- Not a ticket system; no multi-stage workflow.  
- Do not invent approvals; only record what the user or repo already states.

## Hub link pattern (anti-wiki)

In consumer `AGENTS.md` Key Links:

```markdown
- Team (owners): [docs/team/OWNERS.md](./docs/team/OWNERS.md)
- Approval notes: [docs/team/approval-notes.md](./docs/team/approval-notes.md) *(if present)*
```

Hub stays a **pointer**, not a dump of org process. Agents read `docs/team/` for ownership; product narrative stays in vision/requirements/features.

## Announce

When team work runs:

```text
Team: create|link|skip | docs/team | owners: yes|no | approval-notes: yes|no | non-writes: product-vision,requirements,ADRs
```

## Anti-patterns

- CODEOWNERS engine or merge-gate implementation inside this skill  
- Long process handbooks, RACI matrices, or career ladders in `docs/team/`  
- Inventing owner names without evidence from user or existing docs  
- Rewriting product vision because team layout was added  

## Related

- Modes: [modes.md](modes.md) §11 Team governance  
- Hub template: [agents-md-template.md](agents-md-template.md)  
- Monorepo package rows: [skill-discovery.md](skill-discovery.md) Monorepo hubs  
