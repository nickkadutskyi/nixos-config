{ pkgs, config, ... }:
let
  confDir = config.xdg.configHome;
in
pkgs.writeShellScriptBin "select-project"
  # bash
  ''
    TMUX_BIN=${pkgs.tmux}/bin/tmux
    FD=${pkgs.fd}/bin/fd
    FZF=${pkgs.fzf}/bin/fzf
    # XARGS=${pkgs.findutils}/bin/xargs
    SED=${pkgs.gnused}/bin/sed
    # Lists Developer projects
    list_projects() {
      {
        $FD . ~/Developer/*/* -d 1 -t d -E "*/.*"
        $FD -t d -H '^.git$' ~/.config --min-depth 2 -x echo {//}
      }
    }
    sessions=$($TMUX_BIN list-sessions -F "#{session_name}" 2>/dev/null)
    projects=$(list_projects)
    project_options=()
    while read -r project_path; do
      project_path="''${project_path%/}"
      project_name=''${project_path##*/}
      project_name=''${project_name//[:,. ]/_}
      dir=''${project_path%/*}
      project_code=''${dir##*/}
      project_code=''${project_code#"''${project_code%%[!0]*}"}
      temp=''${dir%/*}
      account_code=''${temp##*/}

      session_name="$account_code$project_code $project_name"

      has_session=false
      while read -r session; do
        if [[ "$session" == "$session_name" ]]; then
          has_session=true
          break
        fi
      done <<<"$sessions"

      if [[ "$has_session" == true ]]; then
        project_options+=("$project_path (tmux: $session_name)")
      else
        project_options+=("$project_path")
      fi
    done <<<"$projects"

    selected_project_path="$(printf "%s\n" "''${project_options[@]}" |
      FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 -q "$1" | $SED 's/ (.*)\(.*\)$//g')"

    if [[ -n "$selected_project_path" ]]; then
      echo $selected_project_path
    fi
  ''
