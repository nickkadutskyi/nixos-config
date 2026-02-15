{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  select-project = (import ./scripts/select-project.nix { inherit pkgs config; });
  cfg = config.tools.development;
in
{
  options.tools.development = {
    enable = mkEnableOption "Development environment with tools and services for development.";
  };

  config = mkIf cfg.enable {
    #------------------------------------------------------------------------
    # General
    #------------------------------------------------------------------------
    home.shellAliases = {
      # Git
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gt = "git tag";
      gcp = "git cherry-pick";
      gignore = "git update-index --assume-unchanged";
      gunignore = "git update-index --no-assume-unchanged";
      gignored = "git ls-files -v | grep '^[[:lower:]]'";
      # JJ
      js = "jj st";
      jn = "jj new";
      je = "jj edit";
      jd = "jj desc";
      # jf -> jr to get the latest changes from the remote and rebase
      # the current bookmark on top of the latest trunk.
      jf = "jj git fetch";
      jr = "jj retrunk";
      # jt -> jp to push the current bookmark to the remote.
      jt = "jj tug";
      jp = "jj git push";
    };

    #------------------------------------------------------------------------
    # Env vars
    #------------------------------------------------------------------------
    xdg.configFile = {
      "ideavim/ideavimrc".text = ''
        source ${./vim/vimrc}
        ${builtins.readFile ./vim/ideavimrc}
      '';
      "jj/config.toml".text = import ./jj/config.nix { inherit isDarwin; };
      "starship-jj/starship-jj.toml".source = ./jj/starship-jj.toml;
      "opencode/opencode.json".source = ./opencode/opencode.json;
    };
    home.file = {
      ".aws/config".text = # confini
        ''
          [default]
          region = us-west-2
          [profile epicure-nimbi-staging]
          region = us-west-2
          [profile epicure-nimbi-prod]
          region = us-west-2
        '';
    };

    #---------------------------------------------------------------------
    # Packages
    #---------------------------------------------------------------------
    home.packages = [
      pkgs.opencode # TUI AI Assistant
      pkgs.jujutsu # Alternative VCS
      pkgs.starship-jj
      pkgs.watchman # Needed for Jujutsu register-snapshot-trigger

      (import ./scripts/aws_cd_deployments.nix { inherit pkgs; })
      (import ./scripts/aws_ec2_instances.nix { inherit pkgs; })
    ];

    #---------------------------------------------------------------------
    # Programs
    #---------------------------------------------------------------------

    # Enables direnv to automatically switch environments in project directories.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      silent = true;
    };
    programs.zsh = {
      enable = true;
      initContent =
        # bash
        ''
          # Adds Anthropics API key to environment for avante.nvim
          export ANTHROPIC_API_KEY
          ANTHROPIC_API_KEY="$([ -f /run/secrets/anthropic/api_key ] && cat /run/secrets/anthropic/api_key)"

          # Adds Tavily API key to environment for avante.nvim
          export TAVILY_API_KEY
          TAVILY_API_KEY="$([ -f /run/secrets/tavily/api_key ] && cat /run/secrets/tavily/api_key)"

          # Select and cd to the project directory
          function select-project() { ${select-project}/bin/select-project "$@" }
          function pro() { local p=$(select-project "$@") && [ -n "$p" ] && cd "$p" }
          function prov() { pro "$@" && eval "$(${pkgs.direnv}/bin/direnv export zsh)" && ${pkgs.neovim}/bin/nvim }
          function handle-tmux(){
            local p name code acc sess TMUX_BIN
            TMUX_BIN=${pkgs.tmux}/bin/tmux
            p="$1"
            if [ -n "$p" ]; then
              name="''${p%/}" && name="''${name##*/}" && name="''${name//[:,. ]/_}"
              code="''${p%/*}" && code=''${code##*/} && code=''${code#"''${code%%[!0]*}"} && code="''${code//[:,. ]/_}"
              acc="''${p%/*}" && acc=''${acc%/*} && acc=''${acc##*/} && acc="''${acc//[:,. ]/_}"
              sess="$name"
              if ! $TMUX_BIN has-session -t="$sess" 2>/dev/null; then
                $TMUX_BIN new -ds "$sess" -c "$p" -n "$sess" \; select-pane -t "$sess":1.1 -T "$sess"
                $TMUX_BIN send-keys -t "$sess" "ready-tmux" ^M
              fi
              if [[ -z "$TMUX" ]]; then
                $TMUX_BIN attach -t "$sess"
              else
                $TMUX_BIN switchc -t "$sess"
              fi
            else
              echo "No project provided."
            fi
          }
          function prot() {
            local p name code acc sess TMUX_BIN
            p=$(select-project -t "$@")
            handle-tmux "$p"
          }
          function prd() {
            local p name code acc sess TMUX_BIN
            p=$(select-project -t "$@")
            read -r first rest <<< "$p"

            if [[ "$first" == "p" ]]; then
              p="$rest"
              if [ -n "$p" ]; then
                cd "$p"
              else
                echo "No project provided."
              fi
            elif [[ "$first" == "t" ]]; then
              p="$rest"
              if [ -n "$p" ]; then
                handle-tmux "$p"
              else
                echo "No project provided."
              fi
            else
              if [ -n "$p" ]; then
                cd "$p"
                eval "$(${pkgs.direnv}/bin/direnv export zsh)"
                ${pkgs.neovim}/bin/nvim
              else
                echo "No project provided."
              fi
            fi
          }
        '';
    };
  };
}
