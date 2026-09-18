# go-workspace-repo (fixture)

Synthetic **Go workspace** root for Documentation Manager hardening (`stack_unknown` #51).

- Has: root `go.work` + member `apps/api/go.mod` and `apps/cli/go.mod`
- Does **not** have: root `go.mod`, `AGENTS.md`, `docs/`

Not a product app — inventory smoke only. Expect `detect-stack.sh` → `go` (same MVP token as a root `go.mod`). `detect-packages.sh` lists the workspace members.
