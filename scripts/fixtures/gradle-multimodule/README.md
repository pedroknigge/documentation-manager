# gradle-multimodule (fixture)

Synthetic **Gradle** multi-module root. Used to lock the JVM gap: `detect-stack.sh` stays `unknown` (no `jvm` token) and writes a stderr gap naming `gradle`. `detect-packages.sh` lists `include` modules that exist on disk.

- Has: root `build.gradle` + `settings.gradle` with both `include 'a', ':b:c'` and `include("lib")`
- Modules on disk: `app`, `feature/api` (`:feature:api`), `lib`
- Declared but absent: `:not:there`
- Commented `include 'commented'` — directory exists and must not be listed
- Does **not** have: `AGENTS.md`, `docs/`

Not a product app — inventory smoke only.
