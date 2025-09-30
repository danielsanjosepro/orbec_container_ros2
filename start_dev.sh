#overrideCommand This script shows how to start the devcontainer with the dotfiles repository outside of vscode

devcontainer up --workspace-folder . --dotfiles-repository https://github.com/danielsanjosepro/dotfiles.git
devcontainer exec --workspace-folder . bash
