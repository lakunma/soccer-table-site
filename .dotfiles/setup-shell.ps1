# setup-shell.ps1
#
# This script installs the necessary tools for the custom PowerShell environment.
# Must be run from an Administrator PowerShell session.

Write-Host "🚀 Starting shell environment setup..." -ForegroundColor Cyan

# 1. Check for Scoop Package Manager
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Please install it first from https://scoop.sh"
    exit 1
}
Write-Host "✅ Scoop is installed." -ForegroundColor Green

# 2. Install a Nerd Font (FiraCode is a great choice)
Write-Host "Checking for Nerd Font (FiraCode)..."
if (!(scoop status FiraCode | Select-String -Quiet 'is installed')) {
    Write-Host "Installing FiraCode Nerd Font..."
    scoop bucket add nerd-fonts
    scoop install FiraCode
    Write-Host "✅ FiraCode installed. IMPORTANT: You must manually set this as your terminal font!" -ForegroundColor Yellow
} else {
    Write-Host "✅ FiraCode is already installed." -ForegroundColor Green
}

# 3. Install Oh My Posh
Write-Host "Checking for Oh My Posh..."
if (!(Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Oh My Posh..."
    scoop install oh-my-posh
    Write-Host "✅ Oh My Posh installed." -ForegroundColor Green
} else {
    Write-Host "✅ Oh My Posh is already installed." -ForegroundColor Green
}

Write-Host "`n🎉 Setup complete! Please follow the instructions in README.md to configure your `$PROFILE` file." -ForegroundColor Magenta