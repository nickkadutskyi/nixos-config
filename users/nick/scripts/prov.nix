{
  pkgs,
  config,
  inputs,
  ...
}:
let
  confDir = config.xdg.configHome;
  neovim = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
in
pkgs.writeShellScriptBin "prov"
  # bash
  ''
    FD=${pkgs.fd}/bin/fd
    FZF=${pkgs.fzf}/bin/fzf
    DIRENV=${pkgs.direnv}/bin/direnv
    NVIM=${neovim}/bin/nvim
    # Lists Developer projects
    list_projects() {
      {
        $FD . ~/Developer/*/* -d 1 -t d -E "*/.*"
        $FD -t d -H '^.git$' ~/.config --min-depth 2 -x echo {//}
      }
    }

    # Navigate to Developer project and open in nvim
    project="$(list_projects | FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 -q "$1")"

    if [[ -n $project ]]; then
      cd "$project" && eval "$($DIRENV export zsh)" && $NVIM .
    fi
  ''
