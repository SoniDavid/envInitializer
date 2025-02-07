#!/bin/bash

echo "Setting up Environment"

###############################
# Ensure Homebrew & Cask are installed
###############################

# Install Homebrew if not installed.
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi

# Note: Homebrew Cask is now part of Homebrew.
if brew info cask &>/dev/null; then
    echo "Homebrew Cask is available."
else
    echo "Homebrew Cask not found. Installing Cask..."
    brew install cask
fi

##############################
# Check which packages are already installed
###############################

# Define package lists.
# Cask-installed packages.
cask_packages=("visual-studio-code" "cursor" "discord" "docker")
# Formula-installed packages.
formula_packages=("python3" "pyenv")
# Special packages (Rust installed via rustup).
special_packages=("rust")

# Array to hold names of already installed packages.
installed_packages=()

# Check each cask package.
for pkg in "${cask_packages[@]}"; do
    if brew list --cask "$pkg" &>/dev/null; then
        installed_packages+=("$pkg")
    fi
done

# Check each formula package.
for pkg in "${formula_packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        installed_packages+=("$pkg")
    fi
done

# Check for Rust (by verifying the existence of rustc).
if command -v rustc &>/dev/null; then
    installed_packages+=("rust")
fi

# Report which packages are already installed.
if [ ${#installed_packages[@]} -gt 0 ]; then
    echo "The following packages are already installed and will be ignored:"
    for pkg in "${installed_packages[@]}"; do
        echo "  - $pkg"
    done
else
    echo "No additional packages are pre-installed."
fi

###############################
# Prompt function for user input
###############################

prompt() {
    while true; do
        read -p "$1 (yes/no): " yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Answer yes or no." ;;
        esac
    done
}

###############################
# Define installation functions 
###############################

install_vscode() {
    echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code
    echo "Visual Studio Code installed."
}

install_cursor() {
    echo "Installing Cursor..."
    brew install --cask cursor
    echo "Cursor installed."
}

install_discord() {
    echo "Installing Discord..."
    brew install --cask discord
    echo "Discord installed."
}

install_python3() {
    echo "Installing Python3..."
    brew install python3
    echo "Python3 installed."
}

install_pyenv() {
    echo "Installing Pyenv..."
    brew install pyenv
    echo "Pyenv installed."
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Rust installed."
}

install_docker() {
    echo "Installing Docker..."
    brew install --cask docker
    echo "Docker installed."
}

###############################
# Check if package is installed
###############################

is_installed() {
    local pkg=$1
    for installed in "${installed_packages[@]}"; do
        if [[ "$installed" == "$pkg" ]]; then
            return 0  # Found: installed.
        fi
    done
    return 1  # Not found.
}

###############################
# Main function to run the installation
###############################

main() {
    if ! is_installed "visual-studio-code"; then
        if prompt "Install Visual Studio Code?"; then
            install_vscode
        else
            echo "Skipping Visual Studio Code installation."
        fi
    fi

    if ! is_installed "cursor"; then
        if prompt "Install Cursor?"; then
            install_cursor
        else
            echo "Skipping Cursor installation."
        fi
    fi

    if ! is_installed "discord"; then
        if prompt "Install Discord?"; then
            install_discord
        else
            echo "Skipping Discord installation."
        fi
    fi

    if ! is_installed "python3"; then
        if prompt "Install Python3?"; then
            install_python3
        else
            echo "Skipping Python3 installation."
        fi
    fi

    if ! is_installed "pyenv"; then
        if prompt "Install Pyenv?"; then
            install_pyenv
        else
            echo "Skipping Pyenv installation."
        fi
    fi

    if ! is_installed "rust"; then
        if prompt "Install Rust?"; then
            install_rust
        else
            echo "Skipping Rust installation."
        fi
    fi

    if ! is_installed "docker"; then
        if prompt "Install Docker?"; then
            install_docker
        else
            echo "Skipping Docker installation."
        fi
    fi
}

###############################
# Run the main menu
###############################

main

echo "Environment setup complete."
