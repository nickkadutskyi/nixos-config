# List projects -> select one -> start tmux session for that project
{ pkgs, config, ... }:
let
  confDir = config.xdg.configHome;
in
pkgs.writeShellScriptBin "prot"
  # bash
  ''
    TMUX_BIN=${pkgs.tmux}/bin/tmux
    FD=${pkgs.fd}/bin/fd
    FZF=${pkgs.fzf}/bin/fzf
    XARGS=${pkgs.findutils}/bin/xargs
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
      project_name=''${project_name//[:,. ]/____}
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
      FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 -q "$1")"

    switch_to() {
      if [[ -z "$TMUX" ]]; then
        $TMUX_BIN attach -t "$session_name"
      else
        $TMUX_BIN switchc -t "$session_name"
      fi
    }

    if [[ -n "$selected_project_path" ]]; then
      selected_project_path=$(echo "$selected_project_path" | sed 's/ (.*)\(.*\)$//g')
      project_name=$(basename "$selected_project_path" | tr ":,. " "____")
      project_code=$(dirname "$selected_project_path" | $XARGS -- basename | $SED 's/^0*//')
      account_code=$(dirname "$selected_project_path" | $XARGS -- dirname | $XARGS -- basename)

      session_name="$account_code$project_code $project_name"
      if $TMUX_BIN has-session -t="$session_name" 2>/dev/null; then
        switch_to
      else
        $TMUX_BIN new -ds "$session_name" -c "$selected_project_path" -n "$session_name" \; select-pane -t "$session_name":1.1 -T "$session_name"
        $TMUX_BIN send-keys -t "$session_name" "ready-tmux" ^M
        switch_to
      fi
    fi
  ''
