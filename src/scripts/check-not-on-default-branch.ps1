#!/usr/bin/env pwsh
# PowerShell counterpart of check-not-on-default-branch.sh (same behavior).
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($env:CI) { exit 0 }

$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
if (-not $branch -or $branch -eq 'HEAD') { exit 0 }

$defaultBranch = $null
git remote get-url origin *> $null
if ($LASTEXITCODE -eq 0) {
    $ref = (git symbolic-ref --short refs/remotes/origin/HEAD 2>$null)
    if ($ref) { $defaultBranch = $ref -replace '^origin/', '' }
}

if ($branch -eq 'main' -or $branch -eq 'master' -or ($defaultBranch -and $branch -eq $defaultBranch)) {
    Write-Host "error: デフォルトブランチ (${branch}) への直接コミットはブロックされています。"
    Write-Host '  作業用ブランチを作成してください: git checkout -b work/<short-description>'
    exit 1
}

exit 0
