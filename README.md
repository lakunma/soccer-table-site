# My Soccer Site Project

This repository contains the source code for a cloud-native soccer statistics website hosted on GCP.

## 🚀 Getting Started

This guide will help you set up the necessary development tools on your local machine.

### Prerequisites

The following command-line tools are required. Please run the setup script for your operating system to install them automatically.

*   **Git**: For version control.
*   **Node.js** (`~> 18.x`): For the frontend and backend runtime.
*   **Terraform** (`~> 1.5`): For managing cloud infrastructure.
*   **Google Cloud SDK (`gcloud`)**: For interacting with GCP.

---

### 💻 Development Environment Setup

#### On Windows

1.  Open **PowerShell as Administrator**.
2.  Allow script execution (you only need to do this once):
    ```powershell
    Set-ExecutionPolicy Unrestricted -Scope Process -Force
    ```
3.  Run the Windows setup script:
    ```powershell
    .\scripts\setup-windows.ps1
    ```

#### On Linux (Debian, Ubuntu, Fedora, CentOS)

1.  Open your terminal.
2.  Make the script executable:
    ```bash
    chmod +x ./scripts/setup-linux.sh
    ```
3.  Run the Linux setup script:
    ```bash
    ./scripts/setup-linux.sh
    ```
    *Note: The script will use `sudo` to install packages and will prompt for your password.*

---

### ✅ Next Steps

Once the setup script has completed successfully:

1.  Authenticate with Google Cloud:
    ```bash
    gcloud auth application-default login
    ```
2.  Navigate to the infrastructure directory and initialize Terraform:
    ```bash
    cd infrastructure
    terraform init
    ```
3.  You are now ready to run `terraform plan` and `terraform apply`.