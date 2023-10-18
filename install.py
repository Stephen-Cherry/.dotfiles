"Install dotfiles from https://www.github.com/Stephen-Cherry/.dotfiles"
import time
import os
import shutil
import urllib.request
import pynvim
from typing import List

# Constants
DOTFILES_DIRECTORY: str = "/tmp/dotfiles"
DOTNET_SCRIPT_URL: str = (
    "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh"
)
USER_CONFIG_DIRECTORY: str = os.path.expanduser("~/.config")
DOTNET_SCRIPT_DEST: str = f'/tmp/{DOTNET_SCRIPT_URL.rsplit("/", maxsplit=1)[-1]}'
DOTFILES_REPO_URL: str = "https://www.github.com/Stephen-Cherry/.dotfiles.git"


def get_sudo_permission() -> None:
    os.system("sudo pacman -Sy")


def check_user_config_directory() -> bool:
    return os.path.isdir(USER_CONFIG_DIRECTORY)


def remove_and_create_directory(directory: str) -> None:
    if os.path.exists(directory):
        shutil.rmtree(directory)
    os.makedirs(directory)


def clone_dotfiles_repository() -> None:
    os.system(f"git clone {DOTFILES_REPO_URL} {DOTFILES_DIRECTORY}")


def copy_dotfiles_to_user_config() -> None:
    for item in os.listdir(DOTFILES_DIRECTORY):
        source = os.path.join(DOTFILES_DIRECTORY, item)
        destination = os.path.join(USER_CONFIG_DIRECTORY, item)
        if os.path.isdir(source) and item not in [".git", ".gitignore", "install.py"]:
            if os.path.exists(destination):
                shutil.copytree(source, destination, dirs_exist_ok=True)
            else:
                shutil.copytree(source, destination)


def download_dotnet_script() -> None:
    if os.path.exists(DOTNET_SCRIPT_DEST):
        os.remove(DOTNET_SCRIPT_DEST)
    urllib.request.urlretrieve(DOTNET_SCRIPT_URL, DOTNET_SCRIPT_DEST)
    os.chmod(DOTNET_SCRIPT_DEST, 0o755)  # Sets execute permissions


def install_dotnet() -> None:
    os.system(DOTNET_SCRIPT_DEST)
    os.system(f"{DOTNET_SCRIPT_DEST} --channel STS")


def is_package_installed(package_name: str, version_flag: str) -> bool:
    try:
        os.system(f"{package_name} {version_flag} > /dev/null 2>&1")
        return True
    except OSError:
        return False


def install_missing_packages(packages: List[str]) -> None:
    if packages:
        os.system(f"sudo pacman -S --noconfirm {' '.join(packages)}")


def install_tpm() -> None:
    if not os.path.exists(os.path.expanduser("~/.tmux/plugins/tpm")):
        os.system("git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm")


def install_neovim_lazy() -> None:
    lazypath = os.path.expanduser("~/.local/share/nvim/lazy/lazy.nvim")
    if not os.path.exists(lazypath):
        git_clone_command = [
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        ]
        os.system(" ".join(git_clone_command))


def install_lazy_packages(nvim) -> None:
    print("Installing lazy packages")
    nvim.command('lua require("lazy").sync({ wait=true })')
    print("Waiting 30 seconds")
    time.sleep(30)


def install_mason_tools(nvim) -> None:
    print("\nInstalling mason tools")
    nvim.command(":MasonToolsInstall")
    print("Waiting 30 seconds")
    time.sleep(30)


def install_python_lsp_black_linter() -> None:
    python_lsp_pip = os.path.expanduser(
        "~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/pip"
    )
    os.system(f"{python_lsp_pip} install python-lsp-black")


def main() -> None:
    get_sudo_permission()

    if not check_user_config_directory():
        raise RuntimeError("User config directory not found")

    remove_and_create_directory(DOTFILES_DIRECTORY)
    clone_dotfiles_repository()
    copy_dotfiles_to_user_config()

    download_dotnet_script()
    install_dotnet()

    missing_packages: List[str] = []

    if not is_package_installed("tmux", "-V"):
        missing_packages.append("tmux")

    if not is_package_installed("nvim", "--version"):
        missing_packages.append("neovim")

    if not is_package_installed("go", "version"):
        missing_packages.append("go")

    install_missing_packages(missing_packages)

    install_tpm()
    install_neovim_lazy()

    nvim = pynvim.attach("child", argv=["nvim", "--headless", "--embed"])
    install_lazy_packages(nvim)
    install_mason_tools(nvim)
    install_python_lsp_black_linter()


if __name__ == "__main__":
    main()
