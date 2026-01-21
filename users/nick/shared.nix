{
  config,
  lib,
  pkgs,

  inputs,
  machine,
  system,
  isWSL,
  user,
  ...
}:
let
  # Keep it cross-platform
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  homeDir = config.home.homeDirectory;
  # Used in scripts for project navigation
  select-project = (import ./scripts/select-project.nix { inherit pkgs config; });
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Enables XDG Base Directory Specification support
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Services and Modules
  #---------------------------------------------------------------------
  imports = [ ];

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # TODO Package Tizen Studio and install via Nix or Homebrew

  # Packages I always want installed, but keep project specific packages
  # in their project specific flake.nix accessible via `nix develop`
  home.packages = [
    # ----------------------------------------------------------------
    # Development Tooling used across most projects
    # ----------------------------------------------------------------

    pkgs.bash-language-server
    # GNU find, xargs, locate, updatedb utilities
    pkgs.findutils
    pkgs.lua-language-server
    # Reformats Nix code
    pkgs.nixfmt
    # Nix language server
    pkgs.nixd
    # Runs JavaScript (required by Copilot in Neovim )
    pkgs.nodejs
    # TUI AI Assistant
    pkgs.opencode
    # Reformats shell script
    pkgs.shfmt
    # Reformats Lua code
    pkgs.stylua
    pkgs.tailspin
    # Reformats TOML code
    pkgs.taplo
    # Provides vscode-css-language-server vscode-eslint-language-server
    # vscode-html-language-server vscode-json-language-server
    # vscode-markdown-language-server
    pkgs.vscode-langservers-extracted
    pkgs.xclip

    # ----------------------------------------------------------------
    # Development Tooling that can be moved to project specific flakes
    # ----------------------------------------------------------------

    # For testing Stripe API (UPWZ TODO make it project scoped)
    # pkgs.stripe-cli

    # ----------------------------------------------------------------
    # Other Packages
    # ----------------------------------------------------------------

    # Simple, modern and secure encryption tool
    pkgs.age
    pkgs.awscli2
    # Feature–rich alternative to ls
    pkgs.eza
    # Faster alternative to find
    pkgs.fd
    # Fuzzy finder
    pkgs.fzf
    # GNU Tools for consistency across systems
    pkgs.gnutar
    pkgs.gnused
    pkgs.gnugrep
    pkgs.google-cloud-sdk
    pkgs.git
    # System monitoring
    pkgs.htop
    # Alternative VCS
    pkgs.jujutsu
    # Parses JSON
    pkgs.jq
    pkgs.lnav
    # Main editor
    pkgs.neovim
    # Provides Nerd fonts for icons support
    pkgs.nerd-fonts.jetbrains-mono
    # Searching PDF file contents (TODO check if I use this)
    pkgs.pdfgrep
    # Faster alternative to grep
    pkgs.ripgrep
    # Manages secrets
    pkgs.sops
    pkgs.sourcemapper
    inputs.starship-jj.packages.${pkgs.stdenv.hostPlatform.system}.starship-jj
    # Creates age encrypted file from ssh key
    pkgs.ssh-to-age
    # Multiplexing
    pkgs.tmux
    # Shows directory structure
    pkgs.tree
    pkgs.tree-sitter
    # To watch commands
    pkgs.viddy
    # Needed for Jujutsu
    pkgs.watchman
    pkgs.wget

    # ----------------------------------------------------------------
    # Scripts and wrappers for non-nix packages
    # ----------------------------------------------------------------
    # 2025-12-18: Switched those to stable because csvkit in nixpkgs-ustable is broken
    (import ./scripts/aws_cd_deployments.nix { inherit pkgs; })
    (import ./scripts/aws_ec2_instances.nix { inherit pkgs; })
    (import ./scripts/tizen-sdb.nix { inherit pkgs; })
    (import ./scripts/tizen.nix { inherit pkgs; })
  ]
  ++ (lib.optionals (isLinux && !isWSL) [
    pkgs.chromium
    pkgs.ghostty
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    VISUAL = "nvim";
    GPG_TTY = "$(tty)";
    HOMEBREW_NO_ANALYTICS = "1";
    # Checks if any nerdfont is installed
    NERDFONT_ENABLED =
      if (lib.lists.any (p: (p.meta.homepage or "") == "https://nerdfonts.com/") config.home.packages) then "1" else "0";
    STARSHIP_LOG = "error";
    ZSH_TAB_TITLE_PREFIX = "$([ $SSH_CONNECTION ] && echo \"[$USER@$HOST]\") ";
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "fg=blue,bg=white,bold";
    GREP_COLORS = "mt=01;48;5;223:fn=38;5;16:ln=38;5;244:ms=01;48;5;223:mc=01;48;5;223:sl=0:cx=0:se=0";
    RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/.ripgreprc";
  };

  home.sessionPath = [
    # User-specific executable files
    "$HOME/.local/bin"
    "$HOME/.local/scripts"
    "/Applications/FlashSpace.app/Contents/Resources"
  ];

  home.shellAliases = {
    ll = "ls -lah";
    le = "eza -lag";
    vi = "nvim";
    vim = "nvim";
    view = "nvim";
    vimdiff = "nvim -d";
    # Git
    g = "git";
    ga = "git add";
    gaa = "git add --all";
    gbr = "git branch";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gd = "git diff";
    gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    gp = "git push";
    gpl = "git pull";
    gs = "git status";
    gt = "git tag";
    gignore = "git update-index --assume-unchanged";
    gunignore = "git update-index --no-assume-unchanged";
    gignored = "git ls-files -v | grep '^[[:lower:]]'";
    # JJ
    jd = "jj desc";
    jf = "jj git fetch";
    jn = "jj new";
    jp = "jj git push";
    js = "jj st";
    jt = "jj tug";
    jr = "jj retrunk";
    # IPs
    ip = "curl -4 icanhazip.com";
    ip4 = "curl -4 icanhazip.com";
    ip6 = "curl -6 icanhazip.com";
    iplan = lib.mkIf isDarwin "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
    ips = lib.mkIf isDarwin "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
  }
  // (
    if isLinux then
      {
        pbcopy = "xclip";
        pbpaste = "xclip -o";
      }
    else
      { }
  );

  xdg.configFile = {
    "1Password/ssh/agent.toml".text = import ./1p/ssh/agent.nix { inherit machine; };
    "fzf/light.fzfrc".text = builtins.readFile ./fzf/light.fzfrc;
    "fzf/dark.fzfrc".text = builtins.readFile ./fzf/dark.fzfrc;
    "grep/grep-colors-light" = {
      text = "mt=01;48;5;223:fn=38;5;16:ln=38;5;244:ms=01;48;5;223:mc=01;48;5;223:sl=0:cx=0:se=0";
    };
    "grep/grep-colors-dark" = {
      text = "mt=01;38;5;16;48;5;137:fn=38;5;250:ln=38;5;243:ms=01;38;5;16;48;5;137:mc=01;38;5;16;48;5;137:sl=0:cx=0:se=0";
    };
    "jj/config.toml".text = import ./jj/config.nix { inherit isDarwin; };
    "ripgrep/.ripgreprc-light".text = builtins.readFile ./ripgrep/ripgreprc-light;
    "ripgrep/.ripgreprc-dark".text = builtins.readFile ./ripgrep/ripgreprc-dark;
    "starship-jj/starship-jj.toml".source = ./jj/starship-jj.toml;
    "zsh/zsh-hist-sub-light".text = builtins.readFile ./zsh/zsh-hist-sub-light;
    "zsh/zsh-hist-sub-dark".text = builtins.readFile ./zsh/zsh-hist-sub-dark;
    "zsh/zsh-theme-light".text = builtins.readFile ./zsh/zsh-theme-light;
    "zsh/zsh-theme-dark".text = builtins.readFile ./zsh/zsh-theme-dark;
    "ghostty/config".text = import ./ghostty/config.nix { inherit isDarwin; };
    "ghostty/themes" = {
      source = ./ghostty/themes;
      recursive = true;
    };
    "opencode/opencode.json".text = builtins.readFile ./opencode/opencode.json;
    "tmux/tmux.conf".text = builtins.readFile ./tmux/tmux.conf;
    "tmux/tmux-light.conf".text = builtins.readFile ./tmux/tmux-light.conf;
    "tmux/tmux-dark.conf".text = builtins.readFile ./tmux/tmux-dark.conf;
    # TODO clean up vimrc and ideavimrc config
    "vim/vimrc".source = ./vim/vimrc;
  };

  home.file = {
    # Allows unfree packages for user
    ".config/nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
      }
    '';
    # Synchronizes spell file between Macs for Neovim
    ".hushlogin".text = "";
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

  home.activation = {
    init =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          mkdir -p ${homeDir}/Developer ${homeDir}/.local/bin ${homeDir}/.local/scripts ${homeDir}/.config/sops/age
          chmod 700 ${homeDir}/.config/sops/age
          mkdir -p ${homeDir}/.config/fzf ${homeDir}/.config/grep ${homeDir}/.config/ripgrep ${homeDir}/.config/zsh
          ln -sf ${homeDir}/.config/fzf/light.fzfrc ${homeDir}/.config/fzf/fzfrc
          ln -sf ${homeDir}/.config/zsh/zsh-hist-sub-light ${homeDir}/.config/zsh/zsh-hist-sub-theme
          ln -sf ${homeDir}/.config/zsh/zsh-theme-light ${homeDir}/.config/zsh/zsh-theme-theme
          ln -sf ${homeDir}/.config/grep/grep-colors-light ${homeDir}/.config/grep/grep-theme
          ln -sf ${homeDir}/.config/ripgrep/.ripgreprc-light ${homeDir}/.config/ripgrep/.ripgreprc
        '';
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.bash.enable = true;

  # Enables direnv to automatically switch environments in project directories.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    silent = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nick Kadutskyi";
        email = "nick@kadutskyi.com";
      };
      aliases = {
        a = "add";
        br = "branch";
        c = "commit";
        co = "checkout";
        cp = "cherry-pick";
        d = "diff";
        p = "push";
        l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        pl = "pull";
        s = "status";
        t = "tag";
        ignore = "update-index --assume-unchanged";
        unignore = "update-index --no-assume-unchanged";
        ignored = "!git ls-files -v | grep '^[[:lower:]]'";
      };
      pull.rebase = false;
      core = {
        autocrlf = "input";
        editor = "nvim";
        excludesFile = toString (
          pkgs.writeText "gitignore_global"
            # gitignore
            ''
              .DS_Store
            ''
        );
      };
      gpg = {
        # Sets default signature format to ssh but you can override it
        # for a single command like this: `git -c "gpg.format=openpgp" commit`
        format = "ssh";
        ssh.allowedSignersFile = builtins.toString ./git/allowed_signers;
        # Use this public key for ssh signing while gpg signing will
        # use the one based on email
        ssh.defaultKeyCommand = "echo 'key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOOm/kpbXdO0Zg7XzDK3W67QUCZ/jutXK8w+pgoZqq'";
        openpgp.program = "gpg";
      };
      push = {
        followTags = true;
      };
    };
    # extraConfig = {
    # };
    signing = {
      key = null;
      signByDefault = true;
    };
  };
  programs.ssh = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = import ./starship/starship.nix { inherit config pkgs machine; };
    # enableNushellIntegration = true;
  };

  programs.nushell = {
    enable = false;
    configFile.source = ./nu/config.nu;
    # shellAliases = shellAliases;

    # # This is appended at the end of the config file and we need to do
    # # this to override OMP's transient prompt command.
    # extraConfig = ''
    #   $env.TRANSIENT_PROMPT_COMMAND = null
    # '';
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
      ];
    };
    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
      # Adds SSH connection info to tab title if connected to my computers
      {
        name = "zsh-tab-title";
        src = pkgs.fetchFromGitHub {
          owner = "trystan2k";
          repo = "zsh-tab-title";
          rev = "main";
          sha256 = "sha256-ZEhbQ+yIfCz+vmua7XYBQ4kSVgwoNR8Y4zJyKNypsz0="; # Replace with correct hash
        };
      }
    ];
    history = {
      save = 1000000000;
      size = 1000000000;
      ignoreAllDups = false;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };
    initContent =
      # bash
      ''
        ${builtins.readFile ./zsh/zshrc}

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

}
