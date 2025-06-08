# PowerShell Environment Setup for Windows

This folder contains the configuration for a safe, productive, and beautiful PowerShell environment specifically tailored for developers working on Windows.

## The "Why": Solving Two Critical Problems

This setup is designed to solve two common and critical issues for developers:

1.  **Safety:** Cloud development often involves working with multiple accounts (e.g., work, personal). It is dangerously easy to run a command in the wrong project, potentially deleting resources or incurring massive costs. This setup **forces every new terminal into a safe, inert `gcloud` configuration**, preventing such accidents by requiring a deliberate choice of context.
2.  **Productivity:** A good command prompt provides "at-a-glance" information about your current environment. This saves you from constantly running commands like `git status`, `pwd`, or `gcloud config list`. This setup provides a clean, information-dense prompt that shows you everything you need, exactly when you need it.

---

## The "How": Using Oh My Posh

To achieve this, we use **Oh My Posh**, a powerful, themeable, and highly customizable prompt engine.

### What is Oh My Posh?

Oh My Posh is not just a simple theme; it's a full-fledged engine that can dynamically display information about your environment by running small commands or checking system variables.

*   **Respectability & Popularity:** It is an extremely popular and well-respected open-source tool within the developer community, with thousands of stars on GitHub and a large user base. It is cross-platform, working on PowerShell, Bash, and Zsh across Windows, macOS, and Linux.
*   **Why Developers Use It:** Developers use it to solve exactly the problems this setup addresses. It can display Git status, cloud contexts (GCP, AWS, Azure), programming language versions (Python/Conda, Node), Kubernetes context, and much more, all within a single, unified prompt. It allows you to create a personalized "cockpit" for your command line.

### Useful Links

*   **Official Website & Documentation:** [https://ohmyposh.dev/](https://ohmyposh.dev/)
*   **GitHub Repository:** [https://github.com/JanDeDobbeleer/oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh)

---

## ⚙️ Core Requirements (Prerequisites)

Before installation, ensure you have the correct tools. We strongly recommend using **Scoop** to manage them.

### 1. PowerShell 7+ (Critical)
The default "Windows PowerShell 5" is outdated. You need **PowerShell 7** for modern features, performance, and proper Unicode/icon support.

*   **Install with Scoop:**
    ```powershell
    scoop install pwsh
    ```

### 2. Windows Terminal (Highly Recommended)
This is the best modern terminal application for Windows.

*   **Install with Scoop:**
    ```powershell
    scoop install wt
    ```

### 3. Scoop Package Manager
If you don't have Scoop, install it first.

1.  Open PowerShell 7.
2.  Run the following commands:
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    irm get.scoop.sh | iex
    ```

> **Note for Conda Users:**
> A known issue exists where `conda` commands can fail inside PowerShell 7.5+. To fix this, you must update `conda` to at least version `25.1+`. Run the following command from an Anaconda Prompt: `conda update -n base conda`

---

## 🚀 Installation & Configuration

### Step 1: Run the Automated Installer
This repository includes a script that will install Oh My Posh and a required Nerd Font using Scoop.

1.  Open PowerShell 7 **as Administrator**.
2.  Navigate to this directory.
3.  Run the setup script:
    ```powershell
    .\setup-shell.ps1
    ```

### Step 2: Set PowerShell 7 as your Default Terminal
To ensure you always get the best experience, make PowerShell 7 your default profile in Windows Terminal.

1.  In Windows Terminal, open Settings (`Ctrl` + `,`).
2.  In the "Startup" section, set the "Default profile" to **PowerShell** (the one with the dark blue icon, not the light blue "Windows PowerShell" icon).

### Step 3: Configure Your Terminal Font (Critical!)
You **must** set your terminal's font to a Nerd Font for the icons to display correctly.

1.  In Windows Terminal Settings, go to the **PowerShell** profile.
2.  Click on the "Appearance" tab.
3.  Change the "Font face" to **`FiraCode NF`** or another font ending in `NF`.
4.  Save your settings.

### Step 4: Configure Your PowerShell Profile
The `$PROFILE` file runs every time you open PowerShell. We will configure it to use our safety script and custom prompt.

1.  Open your profile file for editing from a PowerShell 7 terminal:
    ```powershell
    notepad $PROFILE
    ```
2.  **Delete everything currently in that file** and replace it with the exact block of code below. This ensures a clean, predictable setup.

    ```powershell
    # ===================================================================
    #  GCP Configuration Safety Check
    #  This ensures every new PowerShell session starts with the 'safe-default'
    #  GCP configuration active to prevent accidental commands.
    # ===================================================================
    
    # Check if the gcloud command exists before trying to use it
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
    
        # Set the active configuration to 'safe-default'
        gcloud config configurations activate safe-default
    
        # Optional: Print a confirmation message so you know it's working.
        # The color makes it stand out.
        Write-Host "[GCP] Active configuration has been set to 'safe-default'." -ForegroundColor DarkGray
        Write-Host "See defined gcloud configurations:"
        gcloud config configurations list
        Write-Host "Use the following command to switch between configurations:  gcloud config configurations activate <profile name>"
    
        Write-Host "[GCP Security]    Run 'gcloud config configurations activate' and 'gcloud auth application-default login' to begin a session." -ForegroundColor DarkGray
    
    }
    
    # ===================================================================
    #  Oh My Posh Initialization
    #  This loads the custom prompt theme. It must come AFTER the safety check.
    # ===================================================================
    oh-my-posh init pwsh --config '~/.work-personal.omp.yml' | Invoke-Expression

    ```

### Step 5: Restart Your Terminal

Close and reopen Windows Terminal. Your new, safe, and beautiful environment is now fully configured and ready to use