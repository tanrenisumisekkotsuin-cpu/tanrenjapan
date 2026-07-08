# TANREN JAPAN案内ページ — GitHub 公開スクリプト
# 使い方: このフォルダで PowerShell を開き .\publish-to-github.ps1 を実行

$ErrorActionPreference = "Stop"
$repoOwner = "tanrenisumisekkotsuin-cpu"
$repoName = "tanrenjapan"
$root = $PSScriptRoot

function Require-Command($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "$name が見つかりません。先にインストールしてください。"
    }
}

Write-Host ""
Write-Host "TANREN JAPAN 案内ページ — GitHub 公開"
Write-Host "アカウント: $repoOwner"
Write-Host "リポジトリ: $repoName"
Write-Host ""

Require-Command git
Require-Command gh

if (-not (gh auth status 2>$null)) {
    Write-Host "GitHub にログインします..."
    gh auth login
}

Set-Location $root

if (-not (Test-Path ".git")) {
    git init -b main
}

git add index.html style.css script.js vercel.json .gitignore README.md netlify.toml
git status

$hasChanges = git status --porcelain
if ($hasChanges) {
    git commit -m "TANREN JAPAN案内ページを公開（LINE URL更新済み）"
} else {
    Write-Host "コミットする変更はありません。"
}

$repoExists = gh repo view "$repoOwner/$repoName" 2>$null
if (-not $repoExists) {
    Write-Host "GitHub に公開リポジトリを作成します..."
    gh repo create $repoName --public --source . --remote origin --description "TANREN JAPAN 公式案内・相談窓口ページ"
} else {
    if (-not (git remote | Select-String -Quiet "^origin$")) {
        git remote add origin "https://github.com/$repoOwner/$repoName.git"
    }
}

Write-Host "GitHub へ push します..."
git push -u origin main

Write-Host ""
Write-Host "完了: https://github.com/$repoOwner/$repoName"
Write-Host ""
Write-Host "次のステップ（Vercel 連携）:"
Write-Host "1. https://vercel.com を開く"
Write-Host "2. tanrenjapan プロジェクト → Settings → Git"
Write-Host "3. Connect Git Repository → GitHub → $repoOwner/$repoName を選択"
Write-Host "4. Deploy 後、https://tanrenjapan.vercel.app を確認"
Write-Host ""
