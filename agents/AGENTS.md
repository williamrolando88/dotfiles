# Environment & Terminal Context

- **Terminal Emulator**: Kitty
- **Shell**: Fish (`fish`)
- **Prompt**: Starship (`starship`)
- **Font**: Fira Code (`FiraCode`)

## Command & Scripting Guidelines
- When providing terminal commands or suggestions for the user to run interactively in their console, format them for **Fish shell** syntax:
  - Environment variables: `set -gx VAR "value"` (or `set -x VAR "value"`) instead of `export VAR="value"`.
  - Config paths: `~/.config/fish/config.fish` instead of `.bashrc` / `.zshrc`.
  - Sourcing files: `source` / `.` works, but avoid bashisms.
- Be aware of Kitty terminal features (true color, clipboard protocols, Kitty kitten commands, config at `~/.config/kitty/kitty.conf`).
- Starship prompt is configured via `~/.config/starship.toml`.
- Font is Fira Code (supports ligatures and developer glyphs).

## Available Modern CLI Tooling (Prefer Over Legacy Tools)

The following modern CLI tools are installed globally via Linuxbrew (`/home/linuxbrew/.linuxbrew/bin`) and MUST be leveraged whenever the task requires them:
- **AST Search & Refactoring**: `ast-grep` (binary `ast-grep`), `difftastic` (binary `difft`). Prioritize `ast-grep` for syntax-aware code searches and AST replacements in TypeScript/JS/Python over brittle regex, and `difft` for structural AST diffs.
- **Fast Search & Traversal**: `ripgrep` (`rg`), `fd`. Use `rg` (with `--json` when structured data is helpful) over `grep`, and `fd` over `find`.
- **Structured Data & Configs**:
  - `jq`: For querying, filtering, and slicing JSON.
  - `yq`: For querying and safely modifying YAML/TOML/XML (Docker Compose, CI/CD, configs) without breaking indentation.
  - `fq`: For binary format parsing and schema inspection.
  - `gron`: For flattening nested JSON into discrete greppable lines.
- **APIs & Protocols**:
  - `grpcurl`: For discovering, inspecting, and executing gRPC procedures (e.g. testing satellite bridge endpoints).
  - `xh`: For modern, formatted HTTP requests.
- **Benchmarking**: `hyperfine`. For statistical benchmarking and measuring command/script execution times.
