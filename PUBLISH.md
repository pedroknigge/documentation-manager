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
./scripts/test-skill-hardening.sh    # fixtures, golden mode anchors, version sync
./scripts/install-smoke.sh           # install / reinstall / uninstall
```

All must exit **0**. Do not tag or push a release if any fail.

Version must match across:

- `skills/documentation-manager/SKILL.md` → `metadata.version`
- `README.md` badge + `vX.Y.Z` heading
- `AGENTS.md` status line

## Update a release

1. Edit skill files under `skills/documentation-manager/`
2. Bump `metadata.version` in `SKILL.md` (and README/AGENTS)
3. Run the **pre-release gate** above
4. Commit and push — users re-run `install.sh` or `npx skills add …` / update

## Notes

- Keep `SKILL.md` under ~500 lines; put detail in `references/`.
- Do not commit local agent dirs (see `.gitignore`).
- Fixtures live under `scripts/fixtures/` (see that folder’s README).
