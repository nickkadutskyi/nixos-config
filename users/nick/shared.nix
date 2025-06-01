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
  pkgs-master = inputs.nixpkgs-master.legacyPackages.${pkgs.system};
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.system};
  homeDir = config.home.homeDirectory;
  # Used in scripts for project navigation
  select-project = (import ./scripts/select-project.nix { inherit pkgs config; });
  # neovim = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
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
  home.packages =
    with pkgs;
    [
      # ----------------------------------------------------------------
      # Development Tooling used across most projects
      # ----------------------------------------------------------------

      bash-language-server
      # GNU find, xargs, locate, updatedb utilities
      findutils
      gitlint
      lua-language-server
      # Lints Lua code
      luajitPackages.luacheck
      # Nix language server
      nil
      # Reformats Nix code
      nixfmt-rfc-style
      # Another Nix language server
      nixd
      # Runs JavaScript (required by Copilot in Neovim )
      nodePackages_latest.nodejs
      prettierd
      # Lints Lua code
      selene
      # Reformats shell script
      shfmt
      # Lints CSS and SCSS
      # stylelint
      # pkgs-stable.stylelint-lsp
      # Reformats Lua code
      stylua
      # Reformats TOML code
      taplo
      typescript-language-server
      # Provides vscode-css-language-server vscode-eslint-language-server
      # vscode-html-language-server vscode-json-language-server
      # vscode-markdown-language-server
      vscode-langservers-extracted
      # Neeeded for DAP but currently not in nixpkgs TODO package it for nixpkgs
      # vscode-php-debug
      xclip

      # ----------------------------------------------------------------
      # Development Tooling that can be moved to project specific flakes
      # ----------------------------------------------------------------

      # For testing Stripe API (UPWZ TODO make it project scoped)
      stripe-cli

      # ----------------------------------------------------------------
      # Other Packages
      # ----------------------------------------------------------------

      # Simple, modern and secure encryption tool
      age
      # pkgs-master.awscli2
      awscli2
      # cat with syntax highlighting
      bat
      # Feature–rich alternative to ls
      eza
      # Faster alternative to find
      fd
      # Fuzzy finder
      fzf
      # GNU Tools for consistency across systems
      gnutar
      gnused
      gnugrep
      google-cloud-sdk
      git
      # System monitoring
      htop
      # Parses JSON
      jq
      # Main editor
      neovim
      # inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
      # Provides Nerd fonts for icons support
      nerd-fonts.jetbrains-mono
      # Searching PDF file contents (TODO check if I use this)
      pdfgrep
      pkgs.python314
      # Faster alternative to grep
      ripgrep
      # Manages secrets
      sops
      sourcemapper
      speedtest-cli
      # Creates age encrypted file from ssh key
      ssh-to-age
      # Multiplexing
      tmux
      # Shows directory structure
      tree
      wget

      # ----------------------------------------------------------------
      # Scripts and wrappers for non-nix packages
      # ----------------------------------------------------------------
      (import ./scripts/aws_cd_deployments.nix { inherit pkgs; })
      (import ./scripts/aws_ec2_instances.nix { inherit pkgs; })
      (import ./scripts/tizen-sdb.nix { inherit pkgs; })
      (import ./scripts/tizen.nix { inherit pkgs; })
    ]
    ++ (lib.optionals (isLinux && !isWSL) [
      chromium
      ghostty
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

  home.shellAliases =
    {
      ll = "ls -lah";
      le = "eza -lag";
      vi = "nvim";
      vim = "nvim";
      view = "nvim";
      vimdiff = "nvim -d";
      g = "git";
      ip = "curl -4 icanhazip.com";
      ip4 = "curl -4 icanhazip.com";
      ip6 = "curl -6 icanhazip.com";
      iplan = lib.mkIf isDarwin "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
      ips = lib.mkIf isDarwin "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
      ip4a = "dig +short -4 myip.opendns.com @resolver4.opendns.com";
      ip6a = "dig +short -6 myip.opendns.com @resolver1.ipv6-sandbox.opendns.com AAAA";
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
    "1Password/ssh/agent.toml".text =
      # toml
      ''
        [[ssh-keys]]
        vault = "Private"
        [[ssh-keys]]
        vault = "Clients"
        [[ssh-keys]]
        vault = "EPDS"
        ${
          if machine == "Nicks-MacBook-Air-0" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-MacBook-Air-0"
            ''
          else if machine == "Nicks-Mac-mini-0" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-Mac-mini-0"
            ''
          else
            ""
        }
      '';
    "fzf/light.fzfrc".text = builtins.readFile ./fzf/light.fzfrc;
    "fzf/dark.fzfrc".text = builtins.readFile ./fzf/dark.fzfrc;
    "grep/grep-colors-light".text = "mt=01;48;5;223:fn=38;5;16:ln=38;5;244:ms=01;48;5;223:mc=01;48;5;223:sl=0:cx=0:se=0";
    "grep/grep-colors-dark".text =
      "mt=01;38;5;16;48;5;137:fn=38;5;250:ln=38;5;243:ms=01;38;5;16;48;5;137:mc=01;38;5;16;48;5;137:sl=0:cx=0:se=0";
    "ripgrep/.ripgreprc-light".text = builtins.readFile ./ripgrep/ripgreprc-light;
    "ripgrep/.ripgreprc-dark".text = builtins.readFile ./ripgrep/ripgreprc-dark;
    "zsh/zsh-hist-sub-light".text = builtins.readFile ./zsh/zsh-hist-sub-light;
    "zsh/zsh-hist-sub-dark".text = builtins.readFile ./zsh/zsh-hist-sub-dark;
    "zsh/zsh-theme-light".text = builtins.readFile ./zsh/zsh-theme-light;
    "zsh/zsh-theme-dark".text = builtins.readFile ./zsh/zsh-theme-dark;
    "ghostty" = {
      source = ./ghostty;
      recursive = true;
    };
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
    userName = "Nick Kadutskyi";
    userEmail = "nick@kadutskyi.com";
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
    extraConfig = {
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
        # Use this public key for ssh signing while gpg signing will
        # use the one based on email
        ssh.defaultKeyCommand = "echo 'key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOOm/kpbXdO0Zg7XzDK3W67QUCZ/jutXK8w+pgoZqq'";
        openpgp.program = "gpg";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        followTags = true;
      };
    };
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
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
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
        function select-project() { ${select-project}/bin/select-project $1 }
        function pro() { local p=$(select-project $1) && [ -n "$p" ] && cd "$p" }
        function prov() { pro $1 && eval "$(${pkgs.direnv}/bin/direnv export zsh)" && ${pkgs.neovim}/bin/nvim }
        function prot() {
          local p name code acc sess TMUX_BIN
          TMUX_BIN=${pkgs.tmux}/bin/tmux
          p=$(select-project $1)
          if [ -n "$p" ]; then
            name="''${p%/}" && name="''${name##*/}" && name="''${name//[:,. ]/_}"
            code="''${p%/*}" && code=''${code##*/} && code=''${code#"''${code%%[!0]*}"}
            acc="''${p%/*}" && acc=''${acc%/*} && acc=''${acc##*/}
            sess="$acc$code $name"
            if ! $TMUX_BIN has-session -t="$sess" 2>/dev/null; then
              $TMUX_BIN new -ds "$sess" -c "$p" -n "$sess" \; select-pane -t "$sess":1.1 -T "$sess"
              $TMUX_BIN send-keys -t "$sess" "ready-tmux" ^M
            fi
            if [[ -z "$TMUX" ]]; then
              $TMUX_BIN attach -t "$sess"
            else
              $TMUX_BIN switchc -t "$sess"
            fi
          fi
        }
      '';
  };

}
