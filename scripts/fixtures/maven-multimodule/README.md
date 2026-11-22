# maven-multimodule (fixture)

Synthetic **Maven** multi-module root. Used to lock the JVM gap: `detect-stack.sh` stays `unknown` (no `jvm` token) and writes a stderr gap naming `maven`. `detect-packages.sh` lists `<module>` entries inside `<modules>` that exist on disk.

- Has: root `pom.xml` with `<modules>`
- Modules on disk: `app`, `libs/core`
- Declared but absent: `missing-mod`
- Commented `<module>commented-out</module>` — directory exists and must not be listed
- Does **not** have: `AGENTS.md`, `docs/`

Not a product app — inventory smoke only.
