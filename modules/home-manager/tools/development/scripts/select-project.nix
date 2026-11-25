{ pkgs, config, ... }:
let
  confDir = config.xdg.configHome;
  list-projects = import ./list-projects.nix { inherit pkgs; };
in
pkgs.writeShellScriptBin "select-project"
  # bash
  ''
    TMUX_BIN=${pkgs.tmux}/bin/tmux
    FZF=${pkgs.fzf}/bin/fzf
    # XARGS=${pkgs.findutils}/bin/xargs
    SED=${pkgs.gnused}/bin/sed
    GIT=${pkgs.git}/bin/git
    STARSHIP=${config.programs.starship.package}/bin/starship

    # Parse arguments
    FETCH_REMOTES=false
    SHOW_GIT_INFO=false
    SHOW_TMUX_INFO=false
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
        -t)
          SHOW_TMUX_INFO=true
          shift
          ;;
        *)
          QUERY="$1"
          shift
          ;;
      esac
    done

    sessions=""
    if [[ "$SHOW_TMUX_INFO" == true ]]; then
      sessions=$($TMUX_BIN list-sessions -F "#{session_name}" 2>/dev/null)
    fi

    projects=$(${list-projects}/bin/list-projects)
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

      session_name="$project_name"

      has_session=false
      if [[ "$SHOW_TMUX_INFO" == true ]]; then
        while read -r session; do
          if [[ "$session" == "$session_name" ]]; then
            has_session=true
            break
          fi
        done <<<"$sessions"
      fi

      # Check for VCS status (prioritize JJ over Git)
      vcs_info=""
      if [[ "$SHOW_GIT_INFO" == true ]]; then
        # First check for JJ repo
        jj_status=$([[ -d "$project_path/.jj" ]] && cd "$project_path" && STARSHIP_SHELL=sh $STARSHIP module vcs 2>/dev/null | $SED -E 's/\x1b\[[0-9;]*m//g; s/ +$//')
        if [[ $? -eq 0 && -n "$jj_status" ]]; then
          vcs_info="$jj_status "
        elif [[ -d "$project_path/.git" ]]; then
          # Fall back to Git if no JJ repo
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
                  unmerged=" 󰧆"
                fi
              elif [[ "$line" == "1 "* ]]; then
                status_code=$(echo "$line" | cut -d' ' -f2)
                index_status="''${status_code:0:1}"
                working_status="''${status_code:1:1}"
                if [[ "$index_status" != "." || "$working_status" != "." ]]; then
                  is_dirty=" 󰇂"
                fi
              fi
            done <<<"$git_status"

            if [[ -n "$branch" ]]; then
              vcs_info="$branch$unpulled$unmerged$is_dirty "
            fi
          fi
        fi
      fi

      # Show $HOME as ~ in fzf; it is expanded back after selection
      display_path="$project_path"
      if [[ "$project_path" == "$HOME"/* ]]; then
        display_path="~''${project_path#"$HOME"}"
      fi

      # A tab separates the path from the info so it can be cut off after
      # selection; --tabstop=1 renders it as a single space.
      if [[ "$has_session" == true && "$SHOW_TMUX_INFO" == true ]]; then
        project_options+=("$display_path"$'\t'"⧉ $session_name  $vcs_info")
      else
        project_options+=("$display_path"$'\t'"$vcs_info")
      fi
    done <<<"$projects"

    selected_project_path="$(printf "%s\n" "''${project_options[@]}" |
      FZF_DEFAULT_OPTS_FILE=${confDir}/fzf/fzfrc $FZF -1 --tabstop=1 --bind """ctrl-p:become(echo p {})""" --bind """ctrl-t:become(echo t {})""" --bind """ctrl-d:become(echo d {})""" -q "$QUERY" | $SED 's/\t.*$//' | $SED "s|^\(. \)\?~/|\1$HOME/|")"

    if [[ -n "$selected_project_path" ]]; then
      echo $selected_project_path
    fi
  ''
