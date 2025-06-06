#!/bin/bash
#
# scripts/setup-linux.sh
#
# Sets up the development environment for Linux users (Debian/Ubuntu/Fedora/CentOS).
# This script requires 'sudo' privileges for package installation.

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting development environment setup for Linux..."

# --- Helper function to check if a command exists ---
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Detect Package Manager ---
if command_exists apt-get; then
    PM="apt"
elif command_exists dnf; then
    PM="dnf"
elif command_exists yum; then
    PM="yum"
else
    echo "❌ Unable to find supported package manager (apt, dnf, yum). Please install tools manually." >&2
    exit 1
fi

echo "✅ Detected package manager: $PM"

# --- Install Git & Curl (Prerequisites) ---
echo "➡️ Installing prerequisites (git, curl, etc.)..."
if [ "$PM" = "apt" ]; then
    sudo apt-get update
    sudo apt-get install -y git curl apt-transport-https ca-certificates gnupg
else # dnf/yum
    sudo $PM install -y git curl
fi

# --- Install Node.js (via NodeSource) ---
if command_exists node; then
    echo "Node.js is already installed. Skipping."
else
    echo "➡️ Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo $PM install -y nodejs
fi

# --- Install Terraform ---
if command_exists terraform; then
    echo "Terraform is already installed. Skipping."
else
    echo "➡️ Installing Terraform..."
    # Add HashiCorp GPG key and repository
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install -y terraform
fi

# --- Install Google Cloud SDK ---
if command_exists gcloud; then
    echo "Google Cloud SDK is already installed. Skipping."
else
    echo "➡️ Installing Google Cloud SDK..."
    # Add gcloud repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-cli
fi

echo ""
echo "✅ All required tools are installed."
echo "➡️ Next steps: Run 'gcloud auth application-default login' and then 'terraform init' in the /infrastructure directory."