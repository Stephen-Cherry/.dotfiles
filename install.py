"""Install Dotfiles"""
import subprocess
import os
import sys
import shutil

# Constants
DOTFILES_DIRECTORY = "/tmp/dotfiles"
DOTNET_SCRIPT_URL = (
    "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh"
)
USER_CONFIG_DIRECTORY = os.path.expanduser("~/.config")
DOTNET_SCRIPT_DEST = f'/tmp/{DOTNET_SCRIPT_URL.rsplit("/", maxsplit=1)[-1]}'
DOTFILES_REPO_URL = "https://www.github.com/Stephen-Cherry/.dotfiles.git"

# Get sudo permission for pacman commands later in the script
subprocess.run(["sudo", "pacman", "-Sy"], check=True)

# Check USER_CONFIG_DIRECTORY returned a valid path
if not os.path.isdir(USER_CONFIG_DIRECTORY):
    sys.exit(1)

# Delete DOTFILES_DIRECTORY if exists and create it
subprocess.run(["rm", "-rf", DOTFILES_DIRECTORY], check=True)
subprocess.run(["mkdir", "-p", DOTFILES_DIRECTORY], check=True)

# Clone DOTFILES_REPO_URL into DOTFILES_DIRECTORY
subprocess.run(["git", "clone", DOTFILES_REPO_URL, DOTFILES_DIRECTORY], check=True)

# Copy directories in DOTFILES_DIRECTORY to USER_CONFIG_DIRECTORY.
# If item exists in USER_CONFIG_DIRECTORY, merge files.
for item in os.listdir(DOTFILES_DIRECTORY):
    source = os.path.join(DOTFILES_DIRECTORY, item)
    destination = os.path.join(USER_CONFIG_DIRECTORY, item)
    if os.path.isdir(source) and item not in [".git", ".gitignore", "install.py"]:
        if os.path.exists(destination):
            shutil.copytree(source, destination, dirs_exist_ok=True)
        else:
            shutil.copytree(source, destination)

# Download Dotnet script from DOTNET_SCRIPT_URL to DOTNET_SCRIPT_DEST
subprocess.run(["rm", "-f", DOTNET_SCRIPT_DEST], check=True)
subprocess.run(["wget", DOTNET_SCRIPT_URL, "-O", DOTNET_SCRIPT_DEST], check=True)
subprocess.run(["chmod", "+x", DOTNET_SCRIPT_DEST], check=True)

# Install Dotnet
subprocess.run([DOTNET_SCRIPT_DEST], check=True)
subprocess.run([DOTNET_SCRIPT_DEST, "--channel", "STS"], check=True)

# Install Tmux with pacman without confirm
subprocess.run(["sudo", "pacman", "-S", "--noconfirm", "tmux"], check=True)

# Install Tmux Plugin Manager if not already installed
if not os.path.exists("~/.tmux/plugins/tpm"):
    subprocess.run(
        ["git", "clone", "https://github.com/tmux-plugins/tpm", "~/.tmux/plugins/tpm"],
        check=True,
    )

# Install Neovim with pacman without confirm
subprocess.run(["sudo", "pacman", "-S", "--noconfirm", "neovim"], check=True)

# Install neovim Lazy plugin manager
lazypath = os.path.expanduser("~/.local/share/nvim/lazy/lazy.nvim")

if not os.path.exists(lazypath):
    git_clone_command = [
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",  # latest stable release
        lazypath,
    ]
    subprocess.run(git_clone_command, check=True)

# Install Lazy packages
subprocess.run(["nvim", "--headless", "+Lazy! sync", "+qa"], check=True)

# Install Python LSP package
PYTHON_LSP_PIP = os.path.expanduser(
    "~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/pip"
)
subprocess.run([PYTHON_LSP_PIP, "install", "python-lsp-black"], check=True)
