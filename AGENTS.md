# Repository Guidelines

## Project Structure & Module Organization
- `config/` stores reusable YAML snippets (aliases, environment variables) that the installer sources; update these before running `./install_profile.sh` so they land in the active Bash profile.
- `src/` contains helper scripts (shell functions, installers, overrides) that are executed or sourced by the main installer; keep utilities focused and idempotent so the installer can run multiple times safely.
- `dots/` holds curated dotfiles (e.g., `waybar/`, `hypr/`) that are symlinked into your home directory; mirror the naming inside `dots/` so your setup script can sync them predictably.
- Root helpers such as `install_profile.sh` and `packages.txt` orchestrate bootstrap and package installation; treat them as entry points for understanding the workflow.

## Build, Test, and Development Commands
- `./install_profile.sh` bootstraps the Bash environment, copies dotfiles, and applies the configuration defined under `config/` and `dots/`; rerun it whenever you change those inputs.
- `bash -n src/*.sh` (or the specific script you touch) performs a syntax-only check before committing shell changes; run this locally since there is no automated CI yet.
- `bash src/<script>` can run standalone helpers—use specific filenames (like `src/refresh-aliases.sh`) as needed to preview behavior before wiring them into the installer.

## Coding Style & Naming Conventions
- Stick to clean POSIX/Bash: two spaces for indentation inside functions, double-quote all variable expansions, and keep functions short and descriptive (e.g., `link_dotfile` or `apply_aliases`).
- Use lowercase, hyphenated filenames for helper scripts (`sync-dotfiles.sh`, not `SyncDotfiles.sh`) and descriptive names for config files (e.g., `config/aliases.yaml`).
- Document non-obvious logic with concise comments and prefer built-in commands (`printf`, `install`, `ln -sf`) over external dependencies.

## Testing Guidelines
- There is no formal test suite; rely on manual verification by sourcing `install_profile.sh` in a disposable shell (`bash --noprofile --norc ./install_profile.sh`).
- When adding scripts, include simple usage examples in comments or README updates; this doubles as lightweight regression documentation.

## Commit & Pull Request Guidelines
- Follow the existing commit pattern: short, imperative messages (e.g., `Add fresh waybar layout`, `Fix alias ordering`).
- PRs should describe what changed, why, and how to verify (rerun `./install_profile.sh` or source an updated script); link related issues or dotfile requests when available.
- Attach before/after notes or screenshots when dotfile tweaks affect visible tools (Waybar, Hyprland), since reviewers rely on the context.

## Configuration & Security Tips
- Treat secrets as out-of-repo overrides; `config/` files are tracked, so store credentials elsewhere and reference them via environment variables imported at runtime.
- When editing `dots/` entries, run the installer locally first to confirm symlinks and permissions behave as expected.
