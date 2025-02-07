#!/bin/bash

echo "Setting up Environment"

###############################
# Update and upgrade system
###############################
sudo apt update
sudo apt upgrade -y

###############################
# Define package lists
###############################
apt_packages=("python3" "neovim" "software-properties-common" "apt-transport-https" "wget" "ca-certificates" "curl" "terminator" "git")
snap_packages=() # preferably none xd
special_packages=("rust")

###############################
# Check which packages are already installed
###############################
installed_packages=()

# Check each APT package.
for pkg in "${apt_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        installed_packages+=("$pkg")
    fi
done

# Check each Snap package.
for pkg in "${snap_packages[@]}"; do
    if snap list | grep -q "^$pkg "; then
        installed_packages+=("$pkg")
    fi
done

# Check for Rust.
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
# Install missing packages
###############################
for pkg in "${apt_packages[@]}"; do
    if ! [[ " ${installed_packages[@]} " =~ " ${pkg} " ]]; then
        sudo apt install -y "$pkg"
    fi
done

###############################
# Prompt function for user input
###############################
prompt() {
    while true; do
        read -p "$1 (yes/no): " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Answer yes or no." ;;
        esac
    done
}

###############################
# Define installation functions
###############################
install_vscode() {
    echo "Installing Visual Studio Code..."
    sudo apt update
    sudo apt install software-properties-common apt-transport-https wget -y
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt install code -y
    echo "Visual Studio Code installed."
}

install_discord() {
    echo "Installing Discord..."
    wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install ./discord.deb -y
    rm discord.deb
    echo "Discord installed."
}

install_docker() {
    echo "Installing Docker..."
    sudo apt-get remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc -y
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    echo "Docker installed."
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "Rust installed."
}

###############################
# Main function to run the installation
###############################
main() {
    if ! is_installed "code" && prompt "Install Visual Studio Code?"; then
        install_vscode
    fi

    if ! is_installed "discord" && prompt "Install Discord?"; then
        install_discord
    fi

    if ! is_installed "docker" && prompt "Install Docker?"; then
        install_docker
    fi

    if ! is_installed "rust" && prompt "Install Rust?"; then
        install_rust
    fi
}

###############################
# Run the main function
###############################
main

echo "Environment setup complete."
