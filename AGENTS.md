# AGENTS.md

## Purpose

This file defines repo-local guidance for Codex and other agents working in `dotfiles-arch`.

Use the global Codex configuration as the baseline, then apply the rules here for repo-specific truth, safety, and verification.

## Repo Layout And Source Of Truth

- This repo is shell-driven. Treat [`install.sh`](/home/raccoon/dotfiles-arch/install.sh) and the executable scripts in [`runs/`](/home/raccoon/dotfiles-arch/runs) as the source of truth for installer behavior.
- [`home/`](/home/raccoon/dotfiles-arch/home) contains the dotfiles payload that installer tasks deploy.
- [`package-list.txt`](/home/raccoon/dotfiles-arch/package-list.txt) exists in the repo, but current package-install scripts expect `packages/*`. Verify package sources before changing installer behavior.

When working on installer logic, inspect the current shell flow and prefer focused bash changes that preserve existing behavior unless the task explicitly calls for a larger redesign.

## Working Rules

- Restate the task briefly, inspect the repo, then make the smallest explicit change that solves it.
- For installer changes, handle repo-root resolution, dry-run behavior, and missing-file failures explicitly. Do not rely on `$PWD`, shell expansion quirks, or implicit environment state.
- Do not invent commands, manifests, or asset locations. Verify them in the repo first.
- Preserve user changes. Do not revert unrelated work in a dirty tree.
- Prefer read-heavy investigation and targeted edits over broad rewrites.

## Safety Rules

- Treat installer scripts as potentially destructive. In particular:
  - [`install.sh`](/home/raccoon/dotfiles-arch/install.sh) can modify `/etc/sudoers`, packages, and desktop defaults.
  - [`runs/stow.sh`](/home/raccoon/dotfiles-arch/runs/stow.sh) removes existing config targets before stowing.
  - [`runs/pkg.sh`](/home/raccoon/dotfiles-arch/runs/pkg.sh), [`runs/grub.sh`](/home/raccoon/dotfiles-arch/runs/grub.sh), and [`runs/sddm.sh`](/home/raccoon/dotfiles-arch/runs/sddm.sh) can change system packages, boot config, and display-manager state.
- Do not execute host-mutating installer scripts unless the user explicitly asks for execution.
- Do not use installer execution as routine verification for code changes.
- When fixing install-path behavior, prefer conflict detection, backups, and fail-fast errors over delete-first replacement.

## Verification

- Use non-mutating verification first.
- For shell changes, use targeted inspection and static checks before considering any manual execution path.
- Prefer `rg` and focused file reads to confirm current behavior and referenced paths.
- If something cannot be verified locally, say so clearly and name the missing dependency or system requirement.

## Subagent Guidance

- Keep work local unless a specialist materially improves quality.
- Use `software-architect` for installer architecture, migration boundaries, or interface design.
- Use `code-reviewer` for regression, safety, or destructive-behavior review.
- Avoid multi-agent orchestration for small or single-file edits.

## Default Assumptions

- Bash is the supported installer control plane for this repo.
- Balanced strictness is preferred: explicit warnings and verification expectations, without blocking straightforward maintenance work.
