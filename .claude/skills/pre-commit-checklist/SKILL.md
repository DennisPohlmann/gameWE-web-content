---
name: pre-commit-checklist
description: Mandatory checklist before EVERY commit in the gameWE web templates: README/docs check, Conventional Commit message, signed commit, dependency/toolchain update check (suggest only), license check. Use before every git commit, together with security-check and security-privacy-audit.
---

# Pre-commit checklist (the gameWE web templates)

Run this before every commit, also for small fixes, together with the
`security-check` and `security-privacy-audit` skills. Scope is the diff that goes into the commit
(`git status --short`, `git diff HEAD`). Do the steps, then commit; in the
answer report one line per step (done / nothing to do / suggestion).

## 1. README.md and docs/

- Read the parts of `README.md` and `docs/*.md` (INSTALLATION, DEVELOPMENT)
  that the diff touches: the template table, the fallbacks, install and
  verify steps, archive names, version numbers, examples.
- A new or removed template changes the table in `README.md` (and the
  fallback column must match `REMOVED_TEMPLATES` in gameWE-web).
- Fix wrong or outdated statements you notice on the way and links that
  point to removed files.

## 2. Commit message (Conventional Commits) and signature

`CHANGELOG.md`, `VERSION` and the tags are written by semantic-release in CI
from the commit messages. Never edit `CHANGELOG.md` or `VERSION` by hand and
never create tags.

- Format: `<type>(<optional scope>): <summary>`, summary in English,
  imperative, lower case, no full stop, at most ~72 characters. Body: what
  changed for users and what they have to do.
- Types: `feat` (new template or feature, minor release), `fix` (fix of a
  template, patch release), `perf`, `refactor`, `docs`, `test`, `build`,
  `ci`, `chore` (no release). Scope is usually the template name. Security
  fixes are `fix(security): ...`.
- Breaking change: `feat!:` / `fix!:` or a `BREAKING CHANGE: <what to do>`
  footer (major release); removing or renaming a template is one.
- One logical change per commit, so each changelog line is meaningful.
- Commits are signed (`commit.gpgsign`, SSH key); never `--no-gpg-sign`.
- Say in the answer which type you chose and whether it will trigger a
  release; a `feat` or `fix` on `main` needs the `release-security-gate`
  skill and Dennis' go before the push.

## 3. Dependencies and toolchain: check, suggest, do not update on your own

- GitHub Actions in `.github/workflows/build.yml`, the runner image and the
  pinned semantic-release packages: note newer versions.
- Report available updates as a short list: name, current → newest,
  patch/minor/major, and for security fixes the advisory. Recommend which
  ones to take.
- Do not change versions without Dennis's OK, except when the commit is
  about exactly that update or a security advisory forces it (then say so).
- If the check needs network access that is not available, say that it was
  not possible instead of skipping silently.

## 4. Licenses

- The templates come from gameWE-web (GPL-3.0-or-later) and stay under that
  license; `LICENSE` is the GPL-3.0 text.
- Templates contain no third-party fonts, images or icons. If a template
  ever needs third-party material, stop and ask Dennis first (gameWE-web
  would not load it from `theme.css` anyway).
- Code or colours taken over from other projects keep their notice and are
  named in README.md (section License).

## 5. Security and privacy audit

- Run the `security-privacy-audit` skill over the working tree, the
  staged diff (`git diff --cached`), touched docs and the commit message.
- Use `gitleaks protect --staged` if gitleaks is installed; otherwise say
  that it was not available and rely on the targeted searches.
- A `BLOCKED` finding stops the commit. Report only category and
  location, never the value.
- End the answer with the audit summary from that skill.
