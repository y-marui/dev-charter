# GitHub Template Repository Guidelines

> **This is the reference (English) version.**
> The canonical (Japanese) version is [GITHUB_TEMPLATE_GUIDELINES.md](GITHUB_TEMPLATE_GUIDELINES.md).

Guidelines for creating new GitHub template repositories.
While other charter documents define cross-project principles, this document is limited to the specific form of template repositories.

---

## 1. Development Target Definition

Before creating a template repository, define the following.

| Item | What to Define | Examples |
|---|---|---|
| Target platform | What environment the template is for | iOS app / Python package / Chrome extension |
| Tech stack | Language, framework, minimum version | Swift 5.9 / iOS 17 / SwiftUI |
| Template purpose | What will be built from this template | Starter for personal iOS apps |
| Build artifacts | Whether artifacts exist and their format | Yes (.app / .ipa) / None |

Record these in the `README.md` metadata table so users can immediately understand the template's purpose.

---

## 2. Development Environment Definition

### 2.1 Team Structure

Include the following in the template's `README.md`.

| Item | Options | How to Record |
|---|---|---|
| Scale | Individual / Small team (1–3) / OSS (multiple maintainers) / Contracted | "Development environment" field in metadata table |
| Decision-making | Individual / Team consensus | Only when multiple people are involved |

### 2.2 AI Tools

If the template assumes AI-assisted development, explicitly state which AI tools are used and their roles.

**Where to record:** `AI_CONTEXT.md` "AI Tool Responsibilities" section, and `README.md` metadata table (optional row)

| AI Tool | Standard Role |
|---|---|
| Claude Code | Structural changes, large-scale implementation, architecture design |
| GitHub Copilot | Fine-grained implementation, test creation, typo fixes |
| Gemini CLI | Document generation, translation support (manual invocation) |

State "None" if no AI tools are used. Only list tools actually used; omit unused ones.

### 2.3 Software and Tools

Required software must be listed in `README.md` under "Requirements" or "Quick Start".

**Required entries:**
- IDE / Editor (with version)
- Runtime / SDK (e.g., Xcode 15+, Python 3.11+)
- Package manager (e.g., Homebrew, pip, npm)
- Security hooks (if using pre-commit)

---

## 3. Language Policy

Template repository language follows [LANGUAGE_POLICY.md](LANGUAGE_POLICY.md). Template-specific rules are defined below.

### 3.1 Document Language

| Use case | Language | Basis |
|---|---|---|
| Closed / internal template | Japanese (canonical) + English (reference) | LANGUAGE_POLICY.md §1 |
| OSS / public template | English (canonical) + Japanese (reference) | LANGUAGE_POLICY.md §2 |

### 3.2 Language in Code

| Target | Rule |
|---|---|
| Identifiers (variables, functions, classes) | English only |
| Code comments | Unified in primary language (Japanese or English) |
| Commit messages | English (Conventional Commits format) |
| Issue / PR titles | Japanese OK (closed) / English recommended (OSS) |

### 3.3 README Language Handling

- Japanese canonical: `README-jp.md`
- English version (reference): `README.md`
- Both files must be updated **in the same commit**
- A canonical/reference declaration must appear at the top of each file

**Japanese version header:**
```
> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。
```

**English version header:**
```
> **This is the reference (English) version.**
> The canonical (Japanese) version is [README-jp.md](README-jp.md).
```

---

## 4. License

### 4.1 LICENSE File Required

Every template repository must include a `LICENSE` file. Publishing without a license is prohibited.

### 4.2 License Selection Criteria

| Distribution type | Recommended license | Notes |
|---|---|---|
| OSS / public template | MIT | MIT as default to allow unrestricted use |
| Closed / internal | All Rights Reserved | Use custom copyright notice |
| Restricting commercial use | CC BY-NC 4.0, etc. | Limited to documentation-type templates |

### 4.3 All Rights Reserved Template

Use the following as the `LICENSE` file for closed projects.

```
Copyright (c) [YEAR] [AUTHOR]

All rights reserved.

This software and associated documentation files are proprietary and
confidential. Unauthorized copying, distribution, modification, or use
of this software, in whole or in part, is strictly prohibited without
the express written permission of the author.
```

### 4.4 MIT Template

Use the following for OSS templates.

```
MIT License

Copyright (c) [YEAR] [AUTHOR]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 5. README Standards

### 5.1 Required Files

| File | Required | Content |
|---|---|---|
| `README-jp.md` | ✅ | Japanese version (canonical) |
| `README.md` | ✅ | English version (reference) |
| `LICENSE` | ✅ | License per §4 |
| `AI_CONTEXT.md` | When using AI | Context file for AI tools |
| `CLAUDE.md` | When using Claude Code | Contains `@AI_CONTEXT.md` |
| `.github/copilot-instructions.md` | When using Copilot | Copy of AI_CONTEXT.md content |

### 5.2 Required README Sections (order mandatory)

1. **Title** — Format: `# [Technology] [Type] Template`
2. **Language declaration** — Canonical/reference declaration (format per §3.3)
3. **Badges** — CI badge (when GitHub Actions exists) + license badge
4. **One-line summary** — "A template for building [target] with [stack]. For [environment]."
5. **Metadata table** — Target, environment, primary language (+ optional: AI tools, requirements)
6. **Features** — 5–8 items, `✅` checkmark required, use specific technology names
7. **Quick Start** — Starting from `git clone`, through environment setup
8. **Command reference** — When Makefile has 3 or more targets
9. **Project structure** — Based on `tree` output, 3 levels deep, comments on major directories
10. **Documentation index** — `docs/architecture.md` and `docs/development.md` minimum
11. **License** — License name and link to `LICENSE` file

### 5.3 Conditional Sections

Add the following sections only when conditions are met.

| Section | Condition | Position |
|---|---|---|
| Requirements | Multiple platforms, or 3+ versioned dependencies | After "Features" |
| Installation | Artifacts exist + OSS | After one-line summary |
| Usage | CLI / workflow / extension with command system | After "Quick Start" |
| Customization steps | Required edits on first setup | After documentation index |
| AI-assisted development | Claude Code / Copilot + `AI_CONTEXT.md` exists | After documentation index |
| Release procedure | Artifacts exist + distribution process | Before "License" |

### 5.4 Information Gathering for AI-Generated READMEs

AI must confirm the following before generating a README. Do not guess when information is missing — ask the user.
Items determinable from existing files (`Package.swift`, `pyproject.toml`, etc.) may be auto-filled.

```
Please provide the following information to generate a README:
1. Development target: [iOS app / Python package / Chrome extension, etc.]
2. Development environment: [Individual / Small team (1–3) / OSS / Contracted]
3. Primary language: [Japanese / English]
4. Repository name: [e.g., swift-app-template]
5. Tech stack: [e.g., Swift 5.9 / iOS 17 / SwiftUI]
6. Build artifacts: [Yes (.app / .zip, etc.) / None]
7. AI tools: [Claude Code / GitHub Copilot / None]
```

### 5.5 Validation Checklist

Verify the following after creating a README.

```
[ ] All required sections (§5.2) exist and are in order
[ ] Language declaration matches primary language (Japanese / English)
[ ] Metadata table has all 3 fields: target, environment, primary language
[ ] Features section has 5–8 items
[ ] Project structure has comments on directories
[ ] Documentation index has at least 2 links
[ ] LICENSE file exists and is linked from README
[ ] Japanese and English versions updated in the same commit
[ ] No unreplaced variables ([user], [repo], [YEAR], etc.)
```

---

## 6. Template Repository Creation Steps

1. On GitHub, click **"New repository"** → check **"Template repository"**
2. Determine development target and tech stack per §1
3. Define development environment, AI tools, and software per §2
4. Determine language policy per §3
5. Create `LICENSE` file per §4
6. Create `README-jp.md` (Japanese canonical) and `README.md` (English) per §5
7. Create `AI_CONTEXT.md` and `CLAUDE.md` if using AI tools
8. Create `.github/copilot-instructions.md` if using Copilot
