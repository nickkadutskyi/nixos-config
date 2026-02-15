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
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed, but keep project specific packages
  # in their project specific flake.nix accessible via `nix develop`
  home.packages = [
    # ----------------------------------------------------------------
    # Tooling
    # ----------------------------------------------------------------
    pkgs.bash-language-server
    pkgs.nixfmt # Reformats Nix code
    pkgs.nixd # Nix language server
    # Runs JavaScript (required by Copilot in Neovim )
    pkgs.nodejs
    # Reformats shell script
    pkgs.shfmt
    pkgs.tailspin # Highlight log files
    pkgs.taplo # Reformats TOML code
    pkgs.xclip

    # ----------------------------------------------------------------
    # Other Packages
    # ----------------------------------------------------------------

    # Simple, modern and secure encryption tool
    pkgs.age
    pkgs.attic-client # For binary cache backup
    pkgs.awscli2
    # Feature–rich alternative to ls
    pkgs.eza
    # Fuzzy finder
    pkgs.fzf
    pkgs.google-cloud-sdk
    pkgs.jq # Parses JSON
    pkgs.lnav # Log file viewer with SQL-like querying
    # Provides Nerd fonts for icons support
    pkgs.nerd-fonts.jetbrains-mono
    # Manages secrets
    pkgs.sops
    # Creates age encrypted file from ssh key
    pkgs.ssh-to-age
    pkgs.tree-sitter
    # To watch commands
    pkgs.viddy
  ];

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
  ];

  home.shellAliases = {
    ll = "ls -lah";
    le = "eza -lag";
    vi = "nvim";
    vim = "nvim";
    view = "nvim";
    vimdiff = "nvim -d";
    # Git
    gbr = "git branch";
    gco = "git checkout";
    gd = "git diff";
    gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    gs = "git status";
    # IPs
    ip4 = "curl -4 icanhazip.com -s";
    ip6 = "curl -6 icanhazip.com -s";
    ipl =
      if isLinux then
        # bash
        ''
          DEFAULT_IF=$(ip -o route show default | awk '{print $5}' | head -1); \
          ip -brief addr show scope global up | \
          awk -v def="$DEFAULT_IF" '
          {
              iface=$1; state=toupper($2); ip=(NF>=3)?$3:"-";
              c="\033["; r=c"0m"; cyan=c"1;36m"; green=c"1;32m"; red=c"1;31m"; purp=c"1;35m"; yel=c"1;33m";
              s=(state=="UP")?green"UP"r:red"DOWN"r;
              p=(ip!="-")?purp ip r:ip;
              if (iface==def && state=="UP") printf "%s%-10s%s  %-8s  %s  %s← default%s\n", cyan,iface,r,s,p,yel,r;
              else printf "%s%-10s%s  %-8s  %s\n", cyan,iface,r,s,p;
          }'
        ''

      else if isDarwin then
        # bash
        ''
          DEFAULT_IF=$(route -n get default | awk '/interface:/ {print $2}')
          ifconfig -a | awk -v def="$DEFAULT_IF" '
            /^[a-z]+[0-9]+:/ {
              if (NR > 1 && length(ip) > 0) {
                state = (act == 1) ? "\033[1;32mUP\033[0m" : "\033[1;31mDOWN\033[0m";
                if (iface == def) {
                  printf "\033[1;33m%-10s\033[0m %-8s \033[1;35m%s\033[0m  ← default\n", iface, state, ip;
                } else {
                  printf "\033[1;36m%-10s\033[0m %-8s \033[1;35m%s\033[0m\n", iface, state, ip;
                }
              }
              iface = substr($1, 1, length($1)-1);
              ip = "";
              act = 0;
              next
            }
            /status: active/ { act = 1; next }
            /inet / && $2 !~ /^127\./ {
              if (ip == "") ip = $2;
            }
            END {
              if (length(ip) > 0) {
                state = (act == 1) ? "\033[1;32mUP\033[0m" : "\033[1;31mDOWN\033[0m";
                if (iface == def) {
                  printf "\033[1;33m%-10s\033[0m %-8s \033[1;35m%s\033[0m  ← default\n", iface, state, ip;
                } else {
                  printf "\033[1;36m%-10s\033[0m %-8s \033[1;35m%s\033[0m\n", iface, state, ip;
                }
              }
            }
          '
        ''
      else
        "echo 'Unsupported OS'";
    ips = "echo \"IPv4: $(ip4)\nIPv6: $(ip6)\n$(ipl)\"";
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
    "fzf/light.fzfrc".text = builtins.readFile ./fzf/light.fzfrc;
    "fzf/dark.fzfrc".text = builtins.readFile ./fzf/dark.fzfrc;
    "grep/grep-colors-light" = {
      text = "mt=01;48;5;223:fn=38;5;16:ln=38;5;244:ms=01;48;5;223:mc=01;48;5;223:sl=0:cx=0:se=0";
    };
    "grep/grep-colors-dark" = {
      text = "mt=01;38;5;16;48;5;137:fn=38;5;250:ln=38;5;243:ms=01;38;5;16;48;5;137:mc=01;38;5;16;48;5;137:sl=0:cx=0:se=0";
    };
    "ripgrep/.ripgreprc-light".text = builtins.readFile ./ripgrep/ripgreprc-light;
    "ripgrep/.ripgreprc-dark".text = builtins.readFile ./ripgrep/ripgreprc-dark;
    "zsh/zsh-hist-sub-light".text = builtins.readFile ./zsh/zsh-hist-sub-light;
    "zsh/zsh-hist-sub-dark".text = builtins.readFile ./zsh/zsh-hist-sub-dark;
    "zsh/zsh-theme-light".text = builtins.readFile ./zsh/zsh-theme-light;
    "zsh/zsh-theme-dark".text = builtins.readFile ./zsh/zsh-theme-dark;
    "tmux/tmux.conf".text = builtins.readFile ./tmux/tmux.conf;
    "tmux/tmux-light.conf".text = builtins.readFile ./tmux/tmux-light.conf;
    "tmux/tmux-dark.conf".text = builtins.readFile ./tmux/tmux-dark.conf;
    "vim/vimrc".source = ../../modules/home-manager/tools/development/vim/vimrc;
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
  };

  home.activation = {
    init =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          mkdir -p ${homeDir}/.local/bin ${homeDir}/.local/scripts ${homeDir}/.config/sops/age
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
              tmp
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
    signing = {
      key = null;
      signByDefault = true;
    };
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.starship = {
    enable = true;
    settings = import ./starship/starship.nix {
      inherit
        config
        lib
        pkgs
        machine
        ;
    };
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
          rev = "5e56b9e2d4fdb042b979fee75de6bfa4aa80a8a1";
          sha256 = "sha256-EbgHIH1EeaoES+w14kVynomUrmyOahFnxMgzrI1mOig="; # Replace with correct hash
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
      '';
  };
}
