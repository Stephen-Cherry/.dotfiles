# Install lsp/linter packages

import time
import subprocess
import os
import sys
import shutil

DOTFILES_DIRECTORY = "/tmp/dotfiles"

if os.path.exists(DOTFILES_DIRECTORY):
    shutil.rmtree(DOTFILES_DIRECTORY, ignore_errors=True)
repo_url: str = "https://www.github.com/Stephen-Cherry/.dotfiles.git"
subprocess.run(["git", "clone", repo_url, DOTFILES_DIRECTORY], check=True)

user_config_directory: str | None = os.path.expanduser("~/.config")
if not user_config_directory:
    sys.exit(1)
shutil.copytree(
    f"{DOTFILES_DIRECTORY}/nvim/", f"{user_config_directory}/nvim/", dirs_exist_ok=True
)
shutil.copytree(
    f"{DOTFILES_DIRECTORY}/tmux/", f"{user_config_directory}/tmux/", dirs_exist_ok=True
)


DOTNET_SCRIPT_URL = (
    "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh"
)
DOTNET_SCRIPT = f'/tmp/{DOTNET_SCRIPT_URL.rsplit("/", maxsplit=1)[-1]}'
subprocess.run(["wget", DOTNET_SCRIPT_URL, "-O", DOTNET_SCRIPT], check=True)
subprocess.run(["chmod", "+x", DOTNET_SCRIPT], check=True)
subprocess.run(
    [
        DOTNET_SCRIPT,
    ],
    check=True,
)
subprocess.run([DOTNET_SCRIPT, "--channel", "STS"], check=True)

subprocess.run(["pamac", "install", "tmux"], check=True)

neovim = subprocess.Popen(
    [
        "nvim",
    ],
)
time.sleep(10)
neovim.terminate()
PYTHON_LSP_PIP: str = os.path.expanduser(
    "~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/pip"
)
subprocess.run([PYTHON_LSP_PIP, "install", "python-lsp-black"], check=True)
