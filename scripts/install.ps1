#!/usr/bin/env pwsh
# dev-charter quick installer (PowerShell counterpart of install.sh)
#
# Usage:
#   irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex
#
# Environment variables (all optional):
#   CHARTER_REMOTE       git remote name          (default: dev-charter)
#   CHARTER_URL          repository URL           (default: https://github.com/y-marui/dev-charter)
#   CHARTER_PREFIX       install directory        (default: docs/dev-charter)
#   CHARTER_BRANCH       branch to install from   (default: full)
#   CHARTER_UPDATE_ONLY  refuse to fresh-install; only update an existing
#                        install (set to 1). Useful for a Makefile target
#                        that shouldn't silently install `full` the first
#                        time it's run. If nothing is installed yet, prompts
#                        (interactively) or errors out (non-interactively)
#                        instead of picking a branch for you.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$remoteName = if ($env:CHARTER_REMOTE) { $env:CHARTER_REMOTE } else { 'dev-charter' }
$remoteUrl = if ($env:CHARTER_URL) { $env:CHARTER_URL } else { 'https://github.com/y-marui/dev-charter' }
$prefix = if ($env:CHARTER_PREFIX) { $env:CHARTER_PREFIX } else { 'docs/dev-charter' }
$branch = if ($env:CHARTER_BRANCH) { $env:CHARTER_BRANCH } else { 'full' }

# 1. Verify we are inside a git repository
git rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'not in a git repository. Run this script from your project root.'
    exit 1
}

# Prompt the user to launch Claude Code with the given prompt, or print the
# command to run it later. Shared by both the fresh-install and update paths.
function Invoke-ClaudeLaunchOffer {
    param([string]$Prompt)
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if ($claude) {
        if (-not [Console]::IsInputRedirected) {
            $answer = Read-Host 'Launch Claude Code now to run the setup? [Y/n]'
            if ([string]::IsNullOrEmpty($answer) -or $answer -match '^[Yy]') {
                & claude "$Prompt"
            } else {
                Write-Host ''
                Write-Host 'To start setup later, run:'
                Write-Host "  claude ""$Prompt"""
            }
        } else {
            Write-Host 'Tip: launch Claude Code to start setup:'
            Write-Host "  claude ""$Prompt"""
        }
    }
}

# 2. If already installed, update in place instead of installing
if (Test-Path $prefix) {
    # Detect the already-installed variant from CHARTER_INDEX.md's
    # "# Charter Index (<branch>)" marker instead of trusting CHARTER_BRANCH.
    $installedBranch = 'full'
    $installedIndex = Join-Path $prefix 'CHARTER_INDEX.md'
    if (Test-Path $installedIndex) {
        $firstLine = Get-Content -Path $installedIndex -TotalCount 1
        if ($firstLine -match '\(([a-z0-9_-]+)\)$') { $installedBranch = $Matches[1] }
    }
    $branch = $installedBranch
    Write-Host "dev-charter is already installed at $prefix ($branch). Updating..."

    git remote get-url $remoteName *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Adding remote '$remoteName'..."
        git remote add $remoteName $remoteUrl
    }

    Write-Host "Fetching $remoteName..."
    git fetch $remoteName

    # git subtree pull fails on a dirty working tree, so stash first (like
    # the Makefile helper documented in README) and restore afterward.
    $stashed = $false
    $dirty = (git status --porcelain)
    if ($dirty) {
        Write-Host 'Stashing uncommitted changes before updating...'
        git stash push -u -m 'install.ps1 update'
        $stashed = $true
    }

    git subtree pull --prefix=$prefix $remoteName $branch --squash -m "chore: update dev-charter to ${remoteName}/${branch}"
    if ($LASTEXITCODE -ne 0) {
        $mergeHeadPath = (git rev-parse --git-path MERGE_HEAD 2>$null)
        if ($LASTEXITCODE -eq 0 -and $mergeHeadPath -and (Test-Path $mergeHeadPath)) {
            # A real subtree merge is in progress (shared history exists) but
            # its finishing commit was rejected - typically because this
            # project's local scripts/*.sh pre-commit hook copies predate a
            # fix that the incoming update itself carries (e.g. a MERGE_HEAD
            # exemption in check-charter-subtree-edit.sh: the fix that would
            # let this exact commit through only exists in the content the
            # pull is trying to deliver). Resync those hook scripts from the
            # now-staged $prefix/scripts/ and finish the SAME merge commit -
            # do NOT fall through to the template-repo fallback below, which
            # would discard shared subtree history unnecessarily.
            Write-Host "git subtree pull's merge commit was rejected (MERGE_HEAD present) - resyncing local hook scripts and retrying..."

            $unmergedOutsidePrefix = (git diff --name-only --diff-filter=U) | Where-Object { $_ -notlike "$prefix/*" }
            if ($unmergedOutsidePrefix) {
                Write-Error "unresolved merge conflicts outside $prefix - resolve manually, then commit to finish the merge:"
                $unmergedOutsidePrefix | ForEach-Object { Write-Host "  $_" }
                exit 1
            }

            # $prefix is machine-managed (never hand-edited locally, per
            # INSTALL_CHECKLIST.md), so a conflict confined to it is always
            # resolved in favor of the incoming side.
            $unmergedInPrefix = git diff --name-only --diff-filter=U -- $prefix
            if ($unmergedInPrefix) {
                git checkout --theirs -- $prefix
                git add $prefix
            }

            @(Get-ChildItem -Path 'scripts/*' -Include '*.sh', '*.ps1' -File -ErrorAction SilentlyContinue) |
                ForEach-Object {
                    $incoming = Join-Path $prefix "scripts/$($_.Name)"
                    if ((Test-Path $incoming) -and (Compare-Object (Get-Content $_.FullName) (Get-Content $incoming))) {
                        Copy-Item -Force $incoming $_.FullName
                        git add $_.FullName
                    }
                }

            git commit --no-edit
            if ($LASTEXITCODE -ne 0) {
                Write-Error 'could not finish the subtree merge commit even after resyncing scripts/*.sh.'
                Write-Host "  Resolve manually (git status), then run 'git commit --no-edit' to finish the same merge."
                exit 1
            }
        } else {
            # Fallback: projects created from a GitHub template repo don't
            # carry git history, so git subtree pull has no shared history to
            # diff against (see README's "projects created from a template
            # repository" note). Re-sync by replacing $prefix wholesale.
            Write-Host 'git subtree pull failed (likely no shared history - a template-repo checkout). Falling back to a full re-sync...'
            git reset --hard HEAD
            git clean -fd "$prefix/"
            $split = (git rev-parse "${remoteName}/${branch}").Trim()
            Remove-Item -Recurse -Force $prefix
            New-Item -ItemType Directory -Force -Path $prefix | Out-Null
            git archive "${remoteName}/${branch}" | tar -x -C "$prefix/"
            git add "$prefix/"
            $commitMessage = "Squashed '$prefix/' content from commit $split`n`ngit-subtree-dir: $prefix`ngit-subtree-split: $split"
            # This commit never goes through git subtree's own merge
            # machinery (there's no shared history to merge against), so a
            # plain `git commit` here is unconditionally blocked by
            # check-charter-subtree-edit.ps1 whenever it's installed and
            # active - that hook's MERGE_HEAD exemption only ever fires for
            # an actual merge commit, regardless of how current the local
            # hook copy is. Reproduce the same MERGE_HEAD + synthetic
            # squash-commit shape a real subtree merge leaves behind (kept
            # compatible with a later real git subtree pull), so this
            # finishes as a real merge commit and the hook's existing
            # exemption applies.
            $writeTree = (git write-tree).Trim()
            $squashCommit = (git commit-tree $writeTree -p $split -m $commitMessage).Trim()
            $mergeHeadPath = (git rev-parse --git-path MERGE_HEAD).Trim()
            $mergeMsgPath = (git rev-parse --git-path MERGE_MSG).Trim()
            Set-Content -Path $mergeHeadPath -Value $squashCommit
            Set-Content -Path $mergeMsgPath -Value $commitMessage
            git commit --no-edit
            if ($LASTEXITCODE -ne 0) {
                Write-Error "could not finish the re-sync commit under $prefix."
                Write-Host "  Resolve manually (git status), then run 'git commit --no-edit' to finish the same merge."
                exit 1
            }
        }
    }

    if ($stashed) {
        git stash pop
    }

    # lite には UPDATE_CHECKLIST.md がない（full 専用ファイルのため
    # scripts/charter-manifest.txt で除外）ので、branch ごとにプロンプトを変える。
    if ($branch -eq 'full') {
        $nextPrompt = "$prefix/UPDATE_CHECKLIST.md を実行して"
        $nextPromptEn = "Run $prefix/UPDATE_CHECKLIST.md"
    } else {
        $nextPrompt = "$prefix/CHARTER_INDEX.md を読み、変更点をこのプロジェクトに反映して"
        $nextPromptEn = "Read $prefix/CHARTER_INDEX.md and apply the changes to this project"
    }

    Write-Host ''
    Write-Host "dev-charter updated at $prefix"
    Write-Host ''
    Write-Host 'Next - paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):'
    Write-Host ''
    Write-Host "  $nextPrompt"
    Write-Host "  (English: $nextPromptEn)"
    Write-Host ''

    Invoke-ClaudeLaunchOffer -Prompt $nextPrompt
    exit 0
}

# 2.5. Nothing is installed yet. If this was invoked in update-only mode
# (e.g. from a Makefile target), don't silently fall through and install
# the default `full` - that would surprise someone who wanted lite. Ask
# interactively, or print guidance and stop if there's no terminal to ask.
if ($env:CHARTER_UPDATE_ONLY -eq '1') {
    Write-Host "dev-charter is not installed at $prefix yet - nothing to update."
    if (-not [Console]::IsInputRedirected) {
        $answer = Read-Host 'Install full or lite now? [F/l]'
        if ($answer -match '^[Ll]') { $branch = 'lite' } else { $branch = 'full' }
        Write-Host "Installing $branch..."
    } else {
        Write-Host 'Run one of these to install it (this only updates an existing install):' -ForegroundColor Red
        Write-Host '  irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex' -ForegroundColor Red
        Write-Host "  `$env:CHARTER_BRANCH = 'lite'; irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex" -ForegroundColor Red
        exit 1
    }
}

# 3. Add remote if not present
git remote get-url $remoteName *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Adding remote '$remoteName'..."
    git remote add $remoteName $remoteUrl
}

# 4. Fetch
Write-Host "Fetching $remoteName..."
git fetch $remoteName

# 5. Install via git subtree
Write-Host "Installing dev-charter to $prefix..."
git subtree add --prefix=$prefix $remoteName $branch --squash

# 6. Success message + prompt examples
# lite には INSTALL_CHECKLIST.md がない（full 専用ファイルのため
# scripts/charter-manifest.txt で除外）ので、branch ごとにプロンプトを変える。
if ($branch -eq 'full') {
    $nextPrompt = "$prefix/INSTALL_CHECKLIST.md を実行して"
    $nextPromptEn = "Run $prefix/INSTALL_CHECKLIST.md"
} else {
    $nextPrompt = "$prefix/CHARTER_INDEX.md を読み、このプロジェクトに合わせて AI_CONTEXT.md 等を構成して"
    $nextPromptEn = "Read $prefix/CHARTER_INDEX.md and set up AI_CONTEXT.md etc. for this project"
}

Write-Host ''
Write-Host "dev-charter installed at $prefix"
Write-Host ''
Write-Host 'Next - paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):'
Write-Host ''
Write-Host "  $nextPrompt"
Write-Host "  (English: $nextPromptEn)"
Write-Host ''

# 7. Offer to launch Claude Code if available
Invoke-ClaudeLaunchOffer -Prompt $nextPrompt
