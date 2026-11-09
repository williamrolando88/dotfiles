# Environment & Terminal Context

- **Terminal Emulator**: Kitty
- **Shell**: Fish (`fish`)
- **Prompt**: Starship (`starship`)
- **Font**: FiraCode Nerd Font

## Command & Scripting Guidelines
- When providing terminal commands or suggestions for the user to run interactively in their console, format them for **Fish shell** syntax. This applies only to commands the user types; commands you execute yourself run in your own tool's shell (bash/zsh), so keep using that syntax there:
  - Environment variables: `set -gx VAR "value"` (or `set -x VAR "value"`) instead of `export VAR="value"`.
  - Config paths: `~/.config/fish/config.fish` instead of `.bashrc` / `.zshrc`.
  - Sourcing files: `source` / `.` works, but avoid bashisms.
- Be aware of Kitty terminal features (true color, clipboard protocols, Kitty kitten commands). Config lives at `~/.config/kitty/kitty.conf`, with OS-specific overrides in `macos.conf` / `linux.conf` next to it.
- Starship prompt is configured via `~/.config/starship.toml`.
- Font is FiraCode Nerd Font (supports ligatures and developer glyphs).

## Available Modern CLI Tooling (Prefer Over Legacy Tools)

The following tools are optional: the dotfiles installer lets the user pick them from the Brewfile, so a given machine (macOS or Linux, via Homebrew) may not have all of them. Check with `command -v <tool>` before relying on one, prefer it when present, and fall back to the standard tool when it is missing:
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
