{
  isWSL,
  inputs,
  systemName,
  systemUser,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Keep it cross-platform
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  pkgs-master = inputs.nixpkgs-master.legacyPackages.${pkgs.system};
  pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.system};
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
      # Python code formatter
      black
      # Rust package manager
      cargo
      # Rust linter
      clippy
      # Emmet support based on LSP
      emmet-ls
      # GNU find, xargs, locate, updatedb utilities
      findutils
      # Python linter
      python313Packages.flake8
      gitlint
      # PHP language server (closed source, requires license)
      intelephense
      # Python code formatter to sort imports
      isort
      java-language-server
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
      # Another PHP language server (open source)
      phpactor
      prettierd
      # Python linter
      pylint
      # Static type checker for Python
      pylyzer
      # Python language server
      pyright
      # Python language server
      python312Packages.python-lsp-server
      # Ruby linter
      rubocop
      ruby
      # Python linter
      ruff
      # Rust language server
      rust-analyzer
      # Rust formatter
      rustfmt
      # Lints Lua code
      selene
      # Reformats shell script
      shfmt
      # Ruby language server
      rubyPackages_3_4.solargraph
      # Ruby formatter
      rubyPackages.standard
      # Lints CSS and SCSS
      stylelint
      pkgs-stable.stylelint-lsp
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
      vue-language-server
      xmlstarlet
      yaml-language-server
      yamlfmt
      yamllint
      xclip
      zig
      zls

      # ----------------------------------------------------------------
      # Development Tooling that can be moved to project specific flakes
      # ----------------------------------------------------------------

      # Converts SASS to CSS (EPDS TODO make it project scoped)
      dart-sass
      # Tunnel for socks5 proxy to http proxy (EPDS TODO make it project scoped)
      gost
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
      csvkit
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
      # neovim
      inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
      # Provides Nerd fonts for icons support
      nerd-fonts.jetbrains-mono
      # Searching PDF file contents (TODO check if I use this)
      pdfgrep
      python39
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
      # Script wrappers for non-nix packages
      # ----------------------------------------------------------------

      (pkgs.writeShellScriptBin "sdb"
        # bash
        ''
          # Check for Tizen Studio location based on platform
          if [[ "$OSTYPE" == "darwin"* ]]; then
            TIZEN_PATH="$HOME/Tizen/tizen-studio/tools/sdb"
          elif [[ -d "/opt/tizen-studio" ]]; then
            TIZEN_PATH="/opt/tizen-studio/tools/sdb"
          elif [[ -d "$HOME/tizen-studio" ]]; then
            TIZEN_PATH="$HOME/tizen-studio/tools/sdb"
          else
            echo "Error: Could not locate Tizen Studio installation" >&2
            exit 1
          fi

          # Execute the binary if it exists
          if [[ -x "$TIZEN_PATH" ]]; then
            exec "$TIZEN_PATH" "$@"
          else
            echo "Error: sdb binary not found at $TIZEN_PATH" >&2
            exit 1
          fi
        ''
      )
      (pkgs.writeShellScriptBin "tizen"
        # bash
        ''
          # Check for Tizen Studio location based on platform
          if [[ "$OSTYPE" == "darwin"* ]]; then
            TIZEN_PATH="$HOME/Tizen/tizen-studio/tools/ide/bin/tizen"
          elif [[ -d "/opt/tizen-studio" ]]; then
            TIZEN_PATH="/opt/tizen-studio/tools/ide/bin/tizen"
          elif [[ -d "$HOME/tizen-studio" ]]; then
            TIZEN_PATH="$HOME/tizen-studio/tools/ide/bin/tizen"
          else
            echo "Error: Could not locate Tizen Studio installation" >&2
            exit 1
          fi

          # Execute the binary if it exists
          if [[ -x "$TIZEN_PATH" ]]; then
            exec "$TIZEN_PATH" "$@"
          else
            echo "Error: tizen binary not found at $TIZEN_PATH" >&2
            exit 1
          fi
        ''
      )

    ]
    ++ (lib.optionals isDarwin [
      _1password-cli
      # Control bluetooth (TODO check if I need this)
      blueutil
      # GNU Coreutils (gtimeout is required by snippety-helper)
      coreutils-prefixed
      # Set default applications for doc types and URL schemes (TODO check if I use it)
      duti
      # Monitors a directory for changes (required by snippety-helper)
      fswatch
    ])
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

  home.shellAliases = {
    # Navigation
    ll = "ls -lah";
    le = "eza -lag";
    # TODO Review these aliases and get rid of them if not needed
    # Tooling
    # sc = # bash
    #   "symfony console";
    # sym = "symfony";
    # mfs = # bash
    #   "php artisan migrate:fresh --seed";
    # mfss = # bash
    #   "mfs && php artisan db:seed --class=DevSeeder";
    ip = # bash
      "curl -4 icanhazip.com";
    ip4 = # bash
      "curl -4 icanhazip.com";
    ip6 = # bash
      "curl -6 icanhazip.com";
    iplan = # bash
      lib.mkIf isDarwin "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
    ips = # bash
      lib.mkIf isDarwin "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
    ip4a = # bash
      "dig +short -4 myip.opendns.com @resolver4.opendns.com";
    ip6a = # bash
      "dig +short -6 myip.opendns.com @resolver1.ipv6-sandbox.opendns.com AAAA";
    vi = "nvim";
    vim = "nvim";
    view = "nvim";
    vimdiff = "nvim -d";
    # vimn = toString inputs.neovim-nightly-overlay.packages.${pkgs.system}.default + "/bin/nvim";
    aws_ec2_instances =
      # bash
      ''
        aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'sort_by(Reservations[].Instances[], &Tags[?Key==`Name`].Value|[0] || `z-unnamed`)
          [].{InstanceID:InstanceId,Type:InstanceType,State:State.Name,PublicIP:PublicIpAddress,
          PrivateIP:PrivateIpAddress,Name:Tags[?Key==`Name`].Value|[0]}' \
        --output table
      '';
    aws_cd_deployments = # bash
      ''
        aws deploy batch-get-deployments \
        --deployment-ids $(aws deploy list-deployments --query 'deployments' --output json --max-items 10 | \
          jq -r 'join(" ")') \
        --query 'deploymentsInfo[*].[deploymentId, status, applicationName, creator, createTime, completeTime,
          revision.s3Location.key]' \
        --output json | \
          jq -r 'def format_date: if . then split("T") | (.[0] | split("-") | .[1] | tonumber) as $month |
          (.[0] | split("-") | .[2] | tonumber) as $day | (.[0] | split("-") | .[0][-2:] | tonumber) as $year |
          (.[1] | split(".") | .[0]) as $time | "\($month)/\($day)/\($year) \($time)" else "N/A" end;
          [ ["ID", "Status", "App", "Initiated", "Started", "Ended", "Revision"] ] +
          (sort_by(.[4]) | reverse | map([.[0], .[1], .[2], .[3], (.[4] | format_date), (.[5] | format_date), .[6]])) |
          map(@tsv) | .[]' | \
          csvlook --tabs -I 2> /dev/null
      '';
  };

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
          if systemName == "Nicks-MacBook-Air" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-MacBook-Air"
            ''
          else if systemName == "Nicks-Mac-mini" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-Mac-mini"
            ''
          else
            ""
        }
      '';
    "finicky/finicky.js" = {
      source = ./finicky.js;
      onChange = "cat ${config.xdg.configHome}/finicky/finicky.js > ${config.home.homeDirectory}/.finicky.js";
    };
    "fzf/light.fzfrc".text = builtins.readFile ./fzf/light.fzfrc;
    "fzf/dark.fzfrc".text = builtins.readFile ./fzf/dark.fzfrc;
    "gitlint/gitlint.ini".text = builtins.readFile ./gitlint.ini;
    "grep/grep-colors-light".text = "mt=01;48;5;223:fn=38;5;16:ln=38;5;244:ms=01;48;5;223:mc=01;48;5;223:sl=0:cx=0:se=0";
    "grep/grep-colors-dark".text =
      "mt=01;38;5;16;48;5;137:fn=38;5;250:ln=38;5;243:ms=01;38;5;16;48;5;137:mc=01;38;5;16;48;5;137:sl=0:cx=0:se=0";
    "ripgrep/.ripgreprc-light".text = builtins.readFile ./ripgrep/ripgreprc-light;
    "ripgrep/.ripgreprc-dark".text = builtins.readFile ./ripgrep/ripgreprc-dark;
    "zsh-hist-sub/light".text = builtins.readFile ./zsh-hist-sub/light;
    "zsh-hist-sub/dark".text = builtins.readFile ./zsh-hist-sub/dark;
    "zsh-theme/light".text = builtins.readFile ./zsh-theme/light;
    "zsh-theme/dark".text = builtins.readFile ./zsh-theme/dark;
    "ghostty" = {
      source = ./ghostty;
      recursive = true;
    };
    "ideavim/ideavimrc".text = ''
      source ${./vimrc}
      ${builtins.readFile ./ideavimrc}
    '';
    "karabiner/karabiner.json".text = builtins.readFile ./karabiner.json;
    "tmux/tmux.conf".text = builtins.readFile ./tmux/tmux.conf;
    "tmux/tmux-light.conf".text = builtins.readFile ./tmux/tmux-light.conf;
    "tmux/tmux-dark.conf".text = builtins.readFile ./tmux/tmux-dark.conf;
    # TODO clean up vimrc and ideavimrc config
    "vim/vimrc".source = ./vimrc;
  };

  home.file =
    let
      syncHomeDir = config.home.homeDirectory + "/Library/Mobile\ Documents/com\~apple\~CloudDocs/Sync/HOME";
    in
    {
      # Allows unfree packages for user
      ".config/nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';
      # Synchronizes spell file between Macs for Neovim
      ".config/nvim_spell" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/nvim_spell");
      };
      ".config/btt/btt.json" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/btt/btt.json");
      };
      ".config/flashspace/profiles.json" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/flashspace/profiles.json");
      };
      ".config/flashspace/settings.json" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/flashspace/settings.json");
      };
      ".hushlogin".text = "";
      # Synchronizes macOS's global spelling dictionary (Requires giving AppleSpell service Full Disk Access)
      "Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (
          syncHomeDir + "/Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary"
        );
      };
      # Adds custom BibTeX types and fields to BibDesk
      "Library/Application\ Support/BibDesk/TypeInfo.plist" = lib.mkIf isDarwin {
        source = ./bibdesk/TypeInfo.plist;
      };
      # Adds my custom templates to BibDesk
      "Library/Application\ Support/BibDesk/Templates/mdApaTemplate.txt" = lib.mkIf isDarwin {
        source = ./bibdesk/Templates/mdApaTemplate.txt;
      };
      ".local/scripts" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/scripts");
      };
      # ".config/private_php/intelephense_license.txt" = lib.mkIf isDarwin {
      #   source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/private_php/intelephense_license.txt");
      # };
      # ".config/private_clickup/key.txt" = lib.mkIf isDarwin {
      #   source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/private_clickup/key.txt");
      # };
      ".ssh/conf.d" = lib.mkIf isDarwin {
        recursive = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.ssh/conf.d");
      };
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
          mkdir -p ~/Developer
          mkdir -p ~/.local/bin
          mkdir -p ~/.local/scripts
          mkdir -p ~/.config/sops/age
          chmod 700 ~/.config/sops/age
        '';
    initDarwin = lib.mkIf isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          export CRM_ACCOUNTS USER
          USER=${systemUser}

          # Create dev directories for CRM accounts and projects
          CRM_ACCOUNTS=/Users/$USER/Library/Mobile\ Documents/com~apple~CloudDocs/Projects
          for acc_path in "$CRM_ACCOUNTS"/*/; do
            acc_name="$(basename "$acc_path")"
            for project_path in "$acc_path"/*/; do
              project_name="$(basename "$project_path" | cut -d' ' -f1)"
              if [[ $project_name =~ ^[0-9]+$ ]] && [ -f "$project_path/.project.json" ]; then
                mkdir -p "/Users/$USER/Developer/$acc_name/$project_name"
              fi
            done
          done

          # prepare intelephense directory
          /bin/mkdir -p ~/intelephense
          # and hide it
          /usr/bin/chflags hidden ~/intelephense
        ''
    );
    snippetyHelperInstallation = # Required for snippety-helper
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          export PKG_CURL PKG_BASH
          PKG_BASH=${pkgs.bash}
          PKG_CURL=${pkgs.curl}
          if [ ! -d ~/Downloads/.snippety-helper ]; then
            cd ~/Downloads && "$PKG_BASH/bin/bash" -c "$("$PKG_CURL/bin/curl" -fsSL https://snippety.app/SnippetyHelper-Installer.sh)"
          fi
        '';
    checkBashPermissions = # Required for snippety-helper
      lib.mkIf isDarwin # bash
        ''
          YELLOW='\033[0;33m'
          NC='\033[0m' # No Color
          SQL="SELECT client,auth_value
                 FROM access
                WHERE client='/bin/bash'
                  AND auth_value='2'
                  AND service='kTCCServiceSystemPolicyAllFiles';"
          DB="/Library/Application Support/com.apple.TCC/TCC.db"
          if [ ! -f "$DB" ] || [ -z "$(${pkgs.sqlite}/bin/sqlite3 "$DB" "$SQL")" ]; then
            echo -e "''${YELLOW}To use snippety-helper LaunchAgent you need to grant bash shell Full Disk Access."
            echo "Please go to System Preferences -> Security & Privacy -> Full Disk Access and add bash shell."
            echo "You can find bash shell in"
            echo "/bin/bash"
            echo -e "After adding restart snippety-helper LaunchAgent or relogin to system.''${NC}"
          fi
        '';
    checkAppleSpellPermissions =
      lib.mkIf isDarwin # bash
        ''
          YELLOW='\033[0;33m'
          NC='\033[0m' # No Color
          SQL="SELECT client,auth_value
                 FROM access
                WHERE client='com.apple.AppleSpell'
                  AND auth_value='2'
                  AND service='kTCCServiceSystemPolicyAllFiles';"
          DB="/Library/Application Support/com.apple.TCC/TCC.db"
          if [ ! -f "$DB" ] || [ -z "$(${pkgs.sqlite}/bin/sqlite3 "$DB" "$SQL")" ]; then
            echo -e "''${YELLOW}To sync macOS's global spelling dictionary, you need to grant AppleSpell service Full Disk Access."
            echo "Please go to System Preferences -> Security & Privacy -> Full Disk Access and add AppleSpell service."
            echo "You can find AppleSpell service in"
            echo "/System/Library/Services/AppleSpell.service"
            echo -e "After adding restart AppleSpell service or relogin to system.''${NC}"
          fi
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
      st = "status";
      ci = "commit";
      br = "branch";
      co = "checkout";
      p = "push";
      pl = "pull";
      ignore = "update-index --assume-unchanged";
      unignore = "update-index --no-assume-unchanged";
      ignored = "git ls-files -v | grep \"^[[:lower:]]\"";
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
        # On macOS 1Password is used for signing using ssh key
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
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
    includes = [ ] ++ (lib.optionals isDarwin [ "conf.d/*" ]);
    matchBlocks = lib.mkIf isDarwin {
      # Have come first in config to set proper IdentityAgent
      # Checks if NO1P is set and if so, sets IdentityAgent to default
      "_no1p" = {
        match = "host * exec \"[ ! -z \$NO1P ]\"";
        identityFile = [
          ("~/.ssh/" + systemName)
          ("~/.ssh/EPDS")
          ("~/.ssh/CUTN")
        ];
        extraOptions = {
          IdentityAgent = "SSH_AUTH_SOCK";
        };
      };
      "all" = {
        host = "*";
        identityFile = [
          (toString ./ssh + "/${systemName}.pub")
          (toString ./ssh/EPDS.pub)
          (toString ./ssh/CUTN.pub)
        ];
        extraOptions = {
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
    };
  };

  programs.starship = {
    enable = true;
    settings = import ./starship.nix { inherit config pkgs systemName; };
  };

  programs.zsh = {
    enable = true;
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
    };
    envExtra =
      # bash
      ''
        # Extra commands in .zshenv
      '';
    profileExtra =
      # bash
      ''
        # Extra commands in .zprofile
      '';
    initExtraBeforeCompInit = # bash
      ''
        # Running before compinit
      '';
    initExtraFirst =
      # bash
      ''
        # This is before everything else (initExtraFirst)
      '';
    initExtra =
      # bash
      ''
        ${builtins.readFile ./zshrc}
      '';
  };

  #---------------------------------------------------------------------
  # Services and Modules
  #---------------------------------------------------------------------

  imports = [
    ./home-darwin.nix
    # ./services/home-fzf-theme.nix
    # ./services/home-nvim-background.nix
    (import ./services/home-snippety-helper.nix { inherit systemUser pkgs config; })
    ./services/home-theme.nix
  ];
}
