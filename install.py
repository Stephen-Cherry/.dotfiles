import time
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

# Check for and create DOTFILES_DIRECTORY
if os.path.exists(DOTFILES_DIRECTORY):
    shutil.rmtree(DOTFILES_DIRECTORY, ignore_errors=True)

# Clone repository
REPO_URL = "https://www.github.com/Stephen-Cherry/.dotfiles.git"
subprocess.run(["git", "clone", REPO_URL, DOTFILES_DIRECTORY], check=True)

# Check USER_CONFIG_DIRECTORY
if not USER_CONFIG_DIRECTORY:
    sys.exit(1)

# Copy configuration files
for app in ["nvim", "tmux"]:
    source = os.path.join(DOTFILES_DIRECTORY, app)
    destination = os.path.join(USER_CONFIG_DIRECTORY, app)
    shutil.copytree(source, destination, dirs_exist_ok=True)

# Download Dotnet script
subprocess.run(["wget", DOTNET_SCRIPT_URL, "-O", DOTNET_SCRIPT_DEST], check=True)
subprocess.run(["chmod", "+x", DOTNET_SCRIPT_DEST], check=True)

# Install Dotnet
subprocess.run([DOTNET_SCRIPT_DEST], check=True)
subprocess.run([DOTNET_SCRIPT_DEST, "--channel", "STS"], check=True)

# Install Tmux
subprocess.run(["pamac", "install", "tmux"], check=True)

# Start Neovim
neovim = subprocess.Popen(["nvim"])
time.sleep(30)
neovim.terminate()

# Install Python LSP package
PYTHON_LSP_PIP = os.path.expanduser(
    "~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/pip"
)
subprocess.run([PYTHON_LSP_PIP, "install", "python-lsp-black"], check=True)
