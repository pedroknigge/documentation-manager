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

## Update a release

1. Edit skill files under `skills/documentation-manager/`
2. Bump `metadata.version` in `SKILL.md` if you want
3. Run `./scripts/validate-skill.sh && ./scripts/install-smoke.sh`
4. Commit and push — users re-run `install.sh` or `npx skills update`

## Notes

- Keep `SKILL.md` under ~500 lines; put detail in `references/`.
- Do not commit local agent dirs (see `.gitignore`).
