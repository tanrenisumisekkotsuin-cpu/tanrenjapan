# TANREN JAPAN案内ページ — GitHub 公開スクリプト
# 使い方: このフォルダで PowerShell を開き .\publish-to-github.ps1 を実行

$ErrorActionPreference = "Stop"
$repoOwner = "tanrenisumisekkotsuin-cpu"
$repoName = "tanrenjapan"
$root = $PSScriptRoot
$safeRepo = ($root -replace '\\', '/')

function Require-Command($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "$name が見つかりません。先にインストールしてください。"
    }
}

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & git -c "safe.directory=$safeRepo" -c "user.name=$repoOwner" -c "user.email=$repoOwner@users.noreply.github.com" @Args
}

Write-Host ""
Write-Host "TANREN JAPAN 案内ページ — GitHub 公開"
Write-Host "アカウント: $repoOwner"
Write-Host "リポジトリ: $repoName"
Write-Host ""

Require-Command git
Require-Command gh

$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub にログインします（ブラウザが開きます）..."
    gh auth login --hostname github.com --git-protocol https --web
}

Set-Location $root

if (-not (Test-Path ".git")) {
    Invoke-Git init -b main
}

Invoke-Git add index.html style.css script.js vercel.json .gitignore README.md netlify.toml publish-to-github.ps1
Invoke-Git status

$hasChanges = Invoke-Git status --porcelain
if ($hasChanges) {
    Invoke-Git commit -m "TANREN JAPAN案内ページを公開（LINE URL更新済み）"
} else {
    Write-Host "コミットする変更はありません。"
}

$repoExists = $false
try {
    gh repo view "$repoOwner/$repoName" | Out-Null
    $repoExists = $true
} catch {
    $repoExists = $false
}

if (-not $repoExists) {
    Write-Host "GitHub に公開リポジトリを作成します..."
    gh repo create $repoName --public --source . --remote origin --description "TANREN JAPAN 公式案内・相談窓口ページ"
} else {
    $remotes = Invoke-Git remote
    if ($remotes -notcontains "origin") {
        Invoke-Git remote add origin "https://github.com/$repoOwner/$repoName.git"
    }
}

Write-Host "GitHub へ push します..."
Invoke-Git push -u origin main

Write-Host ""
Write-Host "完了: https://github.com/$repoOwner/$repoName"
Write-Host ""
Write-Host "次のステップ（Vercel 連携）:"
Write-Host "1. https://vercel.com を開く"
Write-Host "2. tanrenjapan プロジェクト → Settings → Git"
Write-Host "3. Connect Git Repository → GitHub → $repoOwner/$repoName を選択"
Write-Host "4. Deploy 後、https://tanrenjapan.vercel.app を確認"
Write-Host ""
