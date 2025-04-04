{ pkgs, config, ... }:
let
  confDir = config.xdg.configHome;
in
pkgs.writeShellScriptBin "pro"
  # bash
  ''
    FD=${pkgs.fd}/bin/fd
    FZF=${pkgs.fzf}/bin/fzf
    # Lists Developer projects
    list_projects() {
      {
        $FD . ~/Developer/*/* -d 1 -t d -E "*/.*"
        $FD -t d -H '^.git$' ~/.config --min-depth 2 -x echo {//}
      }
    }
    # Navigate to Developer project
    project="$(list_projects | FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 -q "$1")"

    if [[ ! -z $project ]]; then
      cd "$project" || exit
    fi
  ''
