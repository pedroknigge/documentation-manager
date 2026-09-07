# How to publish this repo

## Option A — GitHub CLI (recommended)

Prereq: `gh auth login` once.

From this folder:

```bash
chmod +x install.sh scripts/*.sh
git init -b main
git add .
git commit -m "Initial release: documentation-manager skill v1.0.0"
gh repo create documentation-manager --public --source=. --remote=origin --push \
  --description "Living knowledge for codebases — AGENTS.md + docs/ that agents can trust. Intent · Audit · From-zero · Code wins."
```

If the repo already exists:

```bash
git remote add origin git@github.com:pedroknigge/documentation-manager.git
git push -u origin main
```

## Option B — Manual

1. Create a public empty repo `documentation-manager` on GitHub (no README/license).
2. Then:

```bash
git init -b main
git add .
git commit -m "Initial release: documentation-manager skill v1.0.0"
git remote add origin git@github.com:pedroknigge/documentation-manager.git
git push -u origin main
```

## Verify install paths

```bash
# Skills ecosystem
npx skills add pedroknigge/documentation-manager -l
npx skills add pedroknigge/documentation-manager -g -y

# Classic installer
curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash
```

In Claude Code / Grok, `/documentation-manager` should appear.  
In Codex, the pointer block is in `~/.codex/AGENTS.md` and the full skill is under `~/.agents/skills/documentation-manager/`.

## Pre-release gate (required)

```bash
./scripts/validate-skill.sh          # structure + chains test-skill-hardening.sh
./scripts/test-skill-hardening.sh    # fixtures, golden mode anchors, version sync, v2 matrix
./scripts/install-smoke.sh           # install / reinstall / uninstall
```

All must exit **0**. Do not tag or push a release if any fail.

Version must match across:

- `skills/documentation-manager/SKILL.md` → `metadata.version`
- `README.md` badge + `vX.Y.Z` heading
- `AGENTS.md` status line
- `CHANGELOG.md` section for that version
- `docs/adoption-matrix.md` version line (when cutting a major)

### Cutting **2.5.3** (anonymous sales/GTM dogfood stats)

Narrative: empty schema v1 ledger at `docs/sales-stats.json` for LIVE FIELD DOGFOOD (every 72h, off-repo). Public rows never include target owner/repo/URLs. **Not** a new major; **not** a Knowledge OS leap.

```bash
# after gate is green:
git tag -a v2.5.3 -m "documentation-manager skill v2.5.3 — anonymous sales/GTM dogfood stats"
git push origin main --tags   # only when you intend to publish
```

### Cutting **2.5.2** (Gemini / agy classic install)

Narrative: classic `install.sh` covers Gemini CLI (`~/.gemini/skills/`) plus existing `~/.gemini/config/skills/` and `~/.gemini/antigravity/skills/` parents. **Not** a new major; **not** a Knowledge OS leap.

```bash
# after gate is green:
git tag -a v2.5.2 -m "documentation-manager skill v2.5.2 — Gemini (+ agy) classic install paths"
git push origin main --tags   # only when you intend to publish
```

### Cutting **2.5.1** (catch-up patch)

Narrative: fold all post-2.5.0 **Unreleased** into one honest patch (kernel loops, dual-plane reconcile, §6.0 escape, install ships `audit-claims`, npx-then-install honesty, comment report-first, C-062, …). **Not** a new major; **not** a second Knowledge OS leap. Going forward: **patch-per-PR**.

```bash
# after gate is green:
git tag -a v2.5.1 -m "documentation-manager skill v2.5.1 — catch-up patch on Knowledge OS floor"
git push origin main --tags   # only when you intend to publish
```

### Cutting **2.5.0** (Knowledge OS first increment)

Narrative: **first OS foundation slice toward 100×** (living claims v0 + local CI audit). Do **not** market as a second 10× or a full 100× leap. Historical — current install floor is **2.5.3**.

```bash
# after gate is green:
git tag -a v2.5.0 -m "documentation-manager skill v2.5.0 — Knowledge OS first increment (living claims + CI audit)"
git push origin main --tags   # only when you intend to publish
```

### Cutting **2.0.0** (reference)

```bash
# after gate is green:
git tag -a v2.0.0 -m "documentation-manager skill v2.0.0 — 10x package"
git push origin main --tags   # only when you intend to publish
```

Users upgrade with (**npx first**, then classic install — npx last wipes `scripts/`):

```bash
npx skills add pedroknigge/documentation-manager -y
./install.sh
```

Record new installs in [docs/adoption-matrix.md](./docs/adoption-matrix.md).

## Update a release

1. Edit skill files under `skills/documentation-manager/`
2. Bump `metadata.version` in `SKILL.md` (and README/AGENTS/CHANGELOG)
3. Run the **pre-release gate** above
4. Commit and push — users: **npx first**, then `install.sh` (npx last wipes `scripts/`)

## Notes

- Keep `SKILL.md` under ~500 lines; put detail in `references/`.
- Do not commit local agent dirs (see `.gitignore`).
- Fixtures live under `scripts/fixtures/` (see that folder’s README).
