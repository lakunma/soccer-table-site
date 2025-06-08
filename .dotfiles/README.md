# My PowerShell Environment Setup for Windows

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

## How to Set It Up on Windows

Follow these steps to configure your environment.

### Step 1: Prerequisites - Install Scoop

We use **Scoop**, a command-line installer for Windows, to manage our tools cleanly. If you don't have it, install it first.

1.  Open PowerShell.
2.  Run the following commands:
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    irm get.scoop.sh | iex
    ```

### Step 2: Run the Automated Installer

This repository includes a script that will install Oh My Posh and the required Nerd Font using Scoop.

1.  Open PowerShell **as Administrator**.
2.  Navigate to this `.dotfiles` directory.
3.  Run the setup script:
    ```powershell
    .\setup-shell.ps1
    ```

### Step 3: Configure Your Terminal Font (Critical!)

After the installer finishes, you **must** set your terminal's font to a Nerd Font for the icons to display correctly.

1.  Open the settings for your terminal (e.g., Windows Terminal, VS Code).
2.  Change the font for your PowerShell profile to **`FiraCode NF`** or another font ending in `NF`.

### Step 4: Configure Your PowerShell Profile

The `$PROFILE` file is a script that runs every time you open a new PowerShell session. We will configure it to use our safety script and custom prompt.

1.  Open your profile file for editing:
    ```powershell
    notepad $PROFILE
    ```

2.  **Delete everything currently in that file** and replace it with the single, consolidated block of code below.

    ```powershell
    # ===================================================================
    #  Custom PowerShell Environment Initialization
    # ===================================================================

    # --- GCP Configuration Safety Check ---
    # This ensures every new PowerShell session starts with the 'safe-default'
    # GCP configuration active to prevent accidental commands.
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
        gcloud config configurations activate safe-default
        # A subtle, fast message confirms the safety net is active.
        Write-Host "[GCP] Switched to 'safe-default' configuration." -ForegroundColor DarkGray
    }

    # --- Oh My Posh Custom Prompt Initialization ---
    # This line loads our beautiful, custom prompt theme from the .dotfiles directory.
    oh-my-posh init pwsh --config '~/.dotfiles/work-personal.omp.json' | Invoke-Expression
    ```

### Step 5: Restart Your Terminal

Close and reopen PowerShell. Your new, safe, and beautiful environment is now fully configured and ready to use!