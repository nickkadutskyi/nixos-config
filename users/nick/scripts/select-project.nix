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
    GIT=${pkgs.git}/bin/git

    # Parse arguments
    FETCH_REMOTES=false
    SHOW_GIT_INFO=false
    QUERY=""
    while [[ $# -gt 0 ]]; do
      case $1 in
        -f)
          FETCH_REMOTES=true
          shift
          ;;
        -g)
          SHOW_GIT_INFO=true
          shift
          ;;
        -gf|-fg)
          SHOW_GIT_INFO=true
          FETCH_REMOTES=true
          shift
          ;;
        *)
          QUERY="$1"
          shift
          ;;
      esac
    done

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

      # Check for git branch and status
      git_info=""
      if [[ "$SHOW_GIT_INFO" == true && -d "$project_path/.git" ]]; then
        # Fetch latest changes from remote to get accurate ahead/behind counts (only if -f flag is used)
        if [[ "$FETCH_REMOTES" == true ]]; then
          $GIT -C "$project_path" fetch --quiet 2>/dev/null || true
        fi
        git_status=$($GIT -C "$project_path" status --porcelain=2 --branch --show-stash --untracked-files=all 2>/dev/null)
        if [[ -n "$git_status" ]]; then
          branch=""
          unpulled=""
          unmerged=""
          is_dirty=""

          while IFS= read -r line; do
            if [[ "$line" == "# branch.head "* ]]; then
              branch=$(echo "$line" | cut -d' ' -f3)
            elif [[ "$line" == "# branch.ab "* ]]; then
              ahead_behind=$(echo "$line" | cut -d' ' -f3-)
              ahead=$(echo "$ahead_behind" | sed 's/^+\([0-9]*\) -.*/\1/')
              behind=$(echo "$ahead_behind" | sed 's/^+[0-9]* -\([0-9]*\)/\1/')
              if [[ "$behind" != "0" ]]; then
                unpulled=" 󰦸"
              fi
              if [[ "$ahead" != "0" ]]; then
                unmerged=" 󰧆 "
              fi
            elif [[ "$line" == "1 "* ]]; then
              status_code=$(echo "$line" | cut -d' ' -f2)
              index_status="''${status_code:0:1}"
              working_status="''${status_code:1:1}"
              if [[ "$index_status" != "." || "$working_status" != "." ]]; then
                is_dirty=" 󰇂 "
              fi
            fi
          done <<<"$git_status"

          if [[ -n "$branch" ]]; then
            git_info="󰘬 $branch$unpulled$unmerged$is_dirty"
          fi
        fi
      fi

      if [[ "$has_session" == true ]]; then
        project_options+=("$project_path ⧉ $session_name  $git_info")
      else
        project_options+=("$project_path $git_info")
      fi
    done <<<"$projects"

    selected_project_path="$(printf "%s\n" "''${project_options[@]}" |
      FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 -q "$QUERY" | $SED 's/ (.*$//g' | $SED 's/ 󰘬 .*$//g')"

    if [[ -n "$selected_project_path" ]]; then
      echo $selected_project_path
    fi
  ''
