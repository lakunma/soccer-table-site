# scripts/setup-windows.ps1
#
# Sets up the development environment for Windows users using Scoop.
# Must be run from an Administrator PowerShell.

Write-Host "🚀 Starting development environment setup for Windows..."

# This ensures the script stops if any command fails.
$ErrorActionPreference = 'Stop'

# 1. Install Scoop if it's not already installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop package manager not found. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
    Write-Host "✅ Scoop installed successfully." -ForegroundColor Green
} else {
    Write-Host "Scoop is already installed." -ForegroundColor Yellow
}

# 2. Add the 'gcloud' bucket if it doesn't exist
if (!(scoop bucket list | Select-String -Quiet 'gcloud')) {
    Write-Host "Adding the 'gcloud' bucket for Google Cloud SDK..."
    scoop bucket add gcloud
}

# 3. Define the list of required tools
$tools = @(
    "git",
    "nodejs",
    "terraform",
    "gcloud"
)

Write-Host "`nChecking and installing required tools: $($tools -join ', ')"

foreach ($tool in $tools) {
    if (scoop status $tool | Select-String -Quiet 'is installed') {
        Write-Host "- $tool is already installed. Skipping." -ForegroundColor Yellow
    } else {
        Write-Host "- Installing $tool..." -ForegroundColor Cyan
        scoop install $tool
    }
}

Write-Host "`n✅ All required tools are installed or up to date." -ForegroundColor Green
Write-Host "➡️ Next steps: Run 'gcloud auth application-default login' and then 'terraform init' in the /infrastructure directory."