# AGENTS.md

## Purpose

This file defines repo-local guidance for Codex and other agents working in `dotfiles-arch`.

Use the global Codex configuration as the baseline, then apply the rules here for repo-specific truth, safety, and verification.

## Repo Layout And Source Of Truth

- This repo is shell-driven. Treat [`install.sh`](install.sh) and the executable scripts in [`runs/`](runs/) as the source of truth for installer behavior.
- [`home/`](home/) contains the dotfiles payload that installer tasks deploy.
- [`package-list.txt`](package-list.txt) is the current package manifest. [`runs/pkg.sh`](runs/pkg.sh) reads package categories from `#` headings and sends packages that are not in the pacman sync DB through `yay`.
- The theme workflow lives in [`runs/theme.sh`](runs/theme.sh), [`home/bin/theme-switch/theme-switch`](home/bin/theme-switch/theme-switch), and [`home/.config/dotfiles-arch/themes/`](home/.config/dotfiles-arch/themes/). Runtime theme assets and current state are user-owned under `$XDG_STATE_HOME/dotfiles-arch`, and stowed configs should import `dotfiles-arch/themes/current`.

When working on installer logic, inspect the current shell flow and prefer focused bash changes that preserve existing behavior unless the task explicitly calls for a larger redesign.

## Working Rules

- Restate the task briefly, inspect the repo, then make the smallest explicit change that solves it.
- For installer changes, handle repo-root resolution, dry-run behavior, and missing-file failures explicitly. Do not rely on `$PWD`, shell expansion quirks, or implicit environment state.
- Do not invent commands, manifests, or asset locations. Verify them in the repo first.
- For theme changes, keep dark/light theme assets explicit, avoid duplicate active-theme wrappers unless they are intentional compatibility shims, and update TODO/README when adding or removing app adapters.
- Preserve user changes. Do not revert unrelated work in a dirty tree.
- Prefer read-heavy investigation and targeted edits over broad rewrites.

## Safety Rules

- Treat installer scripts as potentially destructive. In particular:
  - [`install.sh`](install.sh) can modify `/etc/sudoers`, packages, and desktop defaults.
  - [`runs/stow.sh`](runs/stow.sh) and [`runs/theme.sh`](runs/theme.sh) can back up and replace user config targets before stowing or linking.
  - [`runs/pkg.sh`](runs/pkg.sh), [`runs/grub.sh`](runs/grub.sh), and [`runs/sddm.sh`](runs/sddm.sh) can change system packages, boot config, and display-manager state.
  - [`home/bin/theme-switch/theme-switch`](home/bin/theme-switch/theme-switch) modifies GTK/XDG settings and supported app configs during apply/toggle, including VS Code, Chromium/Chrome live repainting, Zsh, Codex, and optional Spicetify when configured.
- Do not execute host-mutating installer scripts unless the user explicitly asks for execution.
- Do not use installer execution or real-home theme application as routine verification for code changes.
- When fixing install-path behavior, prefer conflict detection, backups, and fail-fast errors over delete-first replacement.

## Verification

- Use non-mutating verification first.
- For shell changes, use targeted inspection and static checks before considering any manual execution path.
- For theme changes, prefer `bash -n` and isolated `HOME`/`XDG_CONFIG_HOME`/`XDG_STATE_HOME` checks; avoid `theme-switch apply` or `theme-switch toggle` against the real user home unless requested.
- Prefer `rg` and focused file reads to confirm current behavior and referenced paths.
- If something cannot be verified locally, say so clearly and name the missing dependency or system requirement.

## Subagent Guidance

- Keep work local unless a specialist materially improves quality.
- Use `software-architect` for installer architecture, migration boundaries, or interface design.
- Use `code-reviewer` for regression, safety, or destructive-behavior review.
- If those named specialists are unavailable in the current runtime, use the closest available reviewer/explorer role and say so.
- Avoid multi-agent orchestration for small or single-file edits.

## Default Assumptions

- Bash is the supported installer control plane for this repo.
- Balanced strictness is preferred: explicit warnings and verification expectations, without blocking straightforward maintenance work.
