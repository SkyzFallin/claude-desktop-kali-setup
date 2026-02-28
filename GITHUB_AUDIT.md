# GitHub Repo Audit: Claude-Desktop-Kali-Setup

## Snapshot
- **Project strength:** clear single-purpose installer with good README and practical defaults.
- **Primary risk areas:** trust chain for package source, script robustness around user/home resolution, and missing repo security policy metadata.

## Improvements Implemented in This Audit
1. Installer now uses the official `claude.ai` Debian repo and key path for a cleaner trust chain.
2. User/home directory resolution was hardened to avoid `eval`-based expansion.
3. Added safer config write flow: build in temp file, JSON-validate, then atomically install with secure permissions.
4. Added dependency bootstrap (`ca-certificates`, `curl`, `gnupg`) before key/repo setup.

## Coding Improvements (Next)
- Add `--dry-run` mode to preview changes without mutating system state.
- Add CLI flags for advanced users:
  - `--skip-mcp-config`
  - `--config-path`
  - `--repo-url`
- Add a `uninstall-claude-desktop.sh` companion script so rollback is symmetric.
- Add CI with:
  - `shellcheck install-claude-desktop.sh`
  - `bash -n install-claude-desktop.sh`
  - markdown linting for `README.md`

## Security Improvements (Next)
- Add a `SECURITY.md` policy with:
  - supported versions
  - private vulnerability reporting contact/process
  - response SLA targets
- Consider key fingerprint verification in-script before trusting downloaded key.
- Consider optional package pinning for `claude-desktop` source priority.
- Add explicit checks that binaries (`curl`, `gpg`, `python3`) exist and fail with actionable messages.

## “Make It Cooler” Suggestions
- Add badges: CI status, shellcheck, latest release, license.
- Add architecture diagram in README:
  - Claude Desktop
  - Filesystem MCP
  - Kali MCP API server
- Add animated terminal demo GIF (install + first launch + MCP tool call).
- Ship a GitHub Action that runs nightly install smoke tests in Debian/Ubuntu/Kali containers.

## Community/Project Hygiene
- Add issue templates for:
  - bug report
  - distro compatibility report
  - security concern
- Add PR template with checklist (tested distro/version, logs, expected behavior).
- Add `CONTRIBUTING.md` with coding standards and release flow.
