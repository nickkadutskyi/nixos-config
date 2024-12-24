{
  isWSL,
  inputs,
  currentSystemName,
  currentSystemUser,
  ...
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
      # Development Tooling (Can be moved to project specific flakes)
      # ----------------------------------------------------------------

      bash-language-server
      # Converts SASS to CSS (EPDS TODO make it project scoped)
      dart-sass
      # Emmet support based on LSP
      emmet-ls
      # Tunnel for socks5 proxy to http proxy (EPDS TODO make it project scoped)
      gost
      # PHP language server (closed source, requires license)
      intelephense
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
      # Lints Lua code
      selene
      # Reformats shell script
      shfmt
      # Reformats Lua code
      stylua
      # For testing Stripe API (UPWZ TODO make it project scoped)
      stripe-cli
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

      # ----------------------------------------------------------------
      # Other Packages
      # ----------------------------------------------------------------

      # Simple, modern and secure encryption tool
      age
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
      # Provides Nerd fonts for icons support
      nerd-fonts.jetbrains-mono
      # Searching PDF file contents (TODO check if I use this)
      pdfgrep
      # Faster alternative to grep
      ripgrep
      # Creates age encrypted file from ssh key
      ssh-to-age
      # Manages secrets
      sops
      speedtest-cli
      # Multiplexing
      tmux
      # Shows directory structure
      tree
      wget
      # Suggests entries from history with grey text
      zsh-autosuggestions
      # p10k prompt
      zsh-powerlevel10k
      # Highlights binaries in terminal emulator
      zsh-syntax-highlighting
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
      # Global mysql and mysqldump for IntelliJ/DataGrip db export/import
      mariadb
    ])
    ++ (lib.optionals (isLinux && !isWSL) [
      chromium
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
  };

  home.sessionPath = [
    # For now Tizen is installed only on Macs
    (if isDarwin then "$HOME/Tizen/tizen-studio/tools/ide/bin" else "")
    # User-specific executable files
    "$HOME/.local/bin"
    "$HOME/.local/scripts"
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
    # EPDS
    # List EPDS AWS EC2 Instances
    epds_ec2 = "aws ec2 describe-instances  --query 'Reservations[].Instances[?not_null(Tags[?Key==\`Name\`].Value)]|[].[State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Tags[?Key==\`Name\`].Value[]|[0]] | sort_by(@, &[3])'  --output text |  sed '$!N;s/ / /'";
  };

  xdg.configFile = {
    "karabiner/karabiner.json".text = builtins.readFile ./karabiner.json;
    "tmux/tmux.conf".text = builtins.readFile ./tmux.conf;
    "fzf/light.fzfrc".text = builtins.readFile ./fzf/light.fzfrc;
    "fzf/dark.fzfrc".text = builtins.readFile ./fzf/dark.fzfrc;
    # TODO clean up vimrc and ideavimrc config
    "vim/vimrc".text = builtins.readFile ./vimrc;
    "ideavim/ideavimrc".text = builtins.readFile ./ideavimrc;
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
          if currentSystemName == "Nicks-MacBook-Air" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-MacBook-Air"
            ''
          else if currentSystemName == "Nicks-Mac-mini" then
            # toml
            ''
              [[ssh-keys]]
              vault = "Nicks-Mac-mini"
            ''
          else
            ""
        }
      '';
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
      ".ssh/hosts" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.ssh/hosts");
      };
      ".aws/config".text = ''
        [default]
        region = us-west-2
        output = json
        [profile epicure-nimbi-staging]
        region = us-west-2
        output = json
        [profile epicure-nimbi-prod]
        region = us-west-2
        output = json
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
          CRM_ACCOUNTS=/Users/${currentSystemUser}/Library/Mobile\ Documents/com~apple~CloudDocs/Projects
          for acc_path in "$CRM_ACCOUNTS"/*/; do
            acc_name="$(basename "$acc_path")"
            for project_path in "$acc_path"/*/; do
              project_name="$(basename "$project_path" | cut -d' ' -f1)"
              if [[ $project_name =~ ^[0-9]+$ ]] && [ -f "$project_path/.project.json" ]; then
                mkdir -p "/Users/${currentSystemUser}/Developer/$acc_name/$project_name"
              fi
            done
          done
        ''
    );
    snippetyHelperInstallation = # Required for snippety-helper
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          if [ ! -d ~/Downloads/.snippety-helper ]; then
            cd ~/Downloads && ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://snippety.app/SnippetyHelper-Installer.sh)"
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

  # TODO fix scripts and ensure key bindings work properly or get rid of tmux
  programs.alacritty = {
    enable = !isWSL;
    settings = import ./alacritty/alacritty.nix { inherit lib pkgs; };
  };

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
        format = "ssh";
      };
      gpg = {
        # On macOS 1Password is used for signing using ssh key
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        followTags = true;
      };
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOOm/kpbXdO0Zg7XzDK3W67QUCZ/jutXK8w+pgoZqq";
      signByDefault = true;
    };
  };
  programs.ssh = {
    enable = true;
    includes = [ "hosts" ];
    matchBlocks = lib.mkIf isDarwin {
      "*" = {
        identityFile = [
          (toString ./ssh + "/${currentSystemName}.pub")
          (toString ./ssh/EPDS.pub)
          (toString ./ssh/CUTN.pub)
        ];
        extraOptions = {
          IdentityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "zsh-window-title";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/git-extras/git-extras.plugin.zsh";
      }
    ];
    history = {
      save = 1000000000;
      size = 1000000000;
      ignoreAllDups = false;
    };
    initExtraFirst =
      # bash
      ''
        # This is before everything else (initExtraFirst)
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
    initExtra =
      # bash
      ''
        ${builtins.readFile ./zshrc}
        ${builtins.readFile ./p10k.zsh}
      ''
      + (
        if config.programs.zsh.oh-my-zsh.enable then
          # bash
          ''
            # tmux title start
            # Uses OMZ theme terminal title directives for tmux
            function omz_termsupport_precmd_tmux_extended() {
              if [[ "$TERM" =~ "tmux*"  ]]; then
                print -Pn "\e]2;''${ZSH_THEME_TERM_TITLE_IDLE:q}\e\\"
              fi
            }
            add-zsh-hook precmd omz_termsupport_precmd_tmux_extended
            # tmux title end
          ''
        else
          ""
      );
  };

  #---------------------------------------------------------------------
  # Services
  #---------------------------------------------------------------------

  imports = [
    ./services/home-fzf-theme.nix
    (import ./services/home-snippety-helper.nix { inherit currentSystemUser pkgs config; })
    (import ./services/home-alacritty-theme.nix {
      inherit pkgs config;
      alacritty = toString ./alacritty;
    })
    ./services/home-nvim-background.nix
  ];

  #---------------------------------------------------------------------
  # System and UI
  #---------------------------------------------------------------------
  targets.darwin.defaults = {
    "com.hegenberg.BetterTouchTool" = {
      BTTAutoLoadPath = "~/.config/btt/btt.json";
      launchOnStartup = true;
      showicon = false;
      borderWidth = 2;
      previewWindowAnimationDuration = "0.09013051637789098";
    };
    "com.apple.driver.AppleBluetoothMultitouch.mouse" = {
      MouseButtonDivision = 55;
      MouseButtonMode = "TwoButton";
      MouseHorizontalScroll = 1;
      MouseMomentumScroll = 1;
      MouseOneFingerDoubleTapGesture = 1;
      MouseTwoFingerDoubleTapGesture = 3;
      MouseTwoFingerHorizSwipeGesture = 2;
      MouseVerticalScroll = 1;
      UserPreferences = 1;
    };
    # Dock configurations
    "com.apple.dock" = {
      autohide = true;
      "mru-spaces" = false;
      # For better Mission Control view when using Aerospace
      "expose-group-apps" = true;
      # Persistent Dock items on the left (using for frequently used apps)
      "persistent-apps" = [
        {
          GUID = 3016036810;
          "tile-data" = {
            "bundle-identifier" = "com.apple.iCal";
            "dock-extra" = 1;
            "file-data" = {
              "_CFURLString" = "file:///System/Applications/Calendar.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Calendar";
            "file-mod-date" = 3807236824;
            "file-type" = 41;
            "is-beta" = 0;
            "parent-mod-date" = 3807236824;
          };
          "tile-type" = "file-tile";
        }
        {
          GUID = 3983927002;
          "tile-data" = {
            "bundle-identifier" = "pro.writer.mac";
            "dock-extra" = 0;
            "file-data" = {
              "_CFURLString" = "file:///Applications/iA%20Writer.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "iA Writer";
            "file-mod-date" = 156628376039959;
            "file-type" = 41;
            "is-beta" = 0;
            "parent-mod-date" = 248111184366845;
          };
          "tile-type" = "file-tile";
        }
        {
          GUID = 2502778024;
          "tile-data" = {
            "bundle-identifier" = "com.apple.mail";
            "dock-extra" = 0;
            "file-data" = {
              "_CFURLString" = "file:///System/Applications/Mail.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Mail";
            "file-mod-date" = 3808414457;
            "file-type" = 41;
            "is-beta" = 0;
            "parent-mod-date" = 3808414457;
          };
          "tile-type" = "file-tile";
        }
        {
          GUID = 714452850;
          "tile-data" = {
            "bundle-identifier" = "ru.keepcoder.Telegram";
            "dock-extra" = 0;
            "file-data" = {
              "_CFURLString" = "file:///Applications/Telegram.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Telegram";
            "file-mod-date" = 114026600348085;
            "file-type" = 41;
            "is-beta" = 0;
            "parent-mod-date" = 136841467249233;
          };
          "tile-type" = "file-tile";
        }
        {
          GUID = 3001694762;
          "tile-data" = {
            "bundle-identifier" = "com.upwork.Upwork";
            "dock-extra" = 0;
            "file-data" = {
              "_CFURLString" = "file:///Applications/Upwork.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Upwork";
            "file-mod-date" = 31485927583175;
            "file-type" = 1;
            "is-beta" = 0;
            "parent-mod-date" = 49486135520711;
          };
          "tile-type" = "file-tile";
        }
        {
          GUID = 1305831930;
          "tile-data" = {
            "bundle-identifier" = "com.apple.ScreenContinuity";
            "dock-extra" = 1;
            "file-data" = {
              "_CFURLString" = "file:///System/Applications/iPhone%20Mirroring.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "iPhone Mirroring";
            "file-mod-date" = 3807236824;
            "file-type" = 41;
            "is-beta" = 0;
            "parent-mod-date" = 3807236824;
          };
          "tile-type" = "file-tile";
        }
      ];
      # Persistent Dock items on the right (using for quick access folders)
      "persistent-others" = [
        {
          GUID = 354663587;
          "tile-data" = {
            arrangement = 2;
            displayas = 0;
            "file-data" = {
              "_CFURLString" = "file:///Users/nick/Desktop/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Desktop";
            "file-mod-date" = 3807722698;
            "file-type" = 2;
            "is-beta" = 0;
            "parent-mod-date" = 261124935269833;
            preferreditemsize = "-1";
            showas = 0;
          };
          "tile-type" = "directory-tile";
        }
        {
          GUID = 3715713668;
          "tile-data" = {
            arrangement = 2;
            displayas = 0;
            "file-data" = {
              "_CFURLString" = "file:///Users/nick/Documents/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Documents";
            "file-mod-date" = 3808363796;
            "file-type" = 2;
            "is-beta" = 0;
            "parent-mod-date" = 261124935269833;
            preferreditemsize = "-1";
            showas = 0;
          };
          "tile-type" = "directory-tile";
        }
        {
          GUID = 2502778041;
          "tile-data" = {
            arrangement = 2;
            displayas = 0;
            "file-data" = {
              "_CFURLString" = "file:///Users/nick/Downloads/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Downloads";
            "file-mod-date" = 176612863732546;
            "file-type" = 2;
            "is-beta" = 0;
            "parent-mod-date" = 261124935269833;
            preferreditemsize = "-1";
            showas = 1;
          };
          "tile-type" = "directory-tile";
        }
        {
          GUID = 3715713667;
          "tile-data" = {
            arrangement = 4;
            displayas = 0;
            "file-data" = {
              "_CFURLString" = "file:///Users/nick/Library/Mobile%20Documents/com~apple~CloudDocs/Screenshots/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Screenshots";
            "file-mod-date" = 3808512343;
            "file-type" = 2;
            "is-beta" = 0;
            "parent-mod-date" = 246848453805355;
            preferreditemsize = "-1";
            showas = 1;
          };
          "tile-type" = "directory-tile";
        }
      ];
    };

    NSGlobalDomain = {
      # Enable full keyboard access for all controls (Keyboard navigation)
      AppleKeyboardUIMode = 3;
      # Instead of special char menu repeat the character
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      # Appearance to auto
      AppleInterfaceStyleSwitchesAutomatically = true;
      # Languages in Regional Settings
      AppleLanguages = [
        "en-US"
        "ru-US"
        "uk-US"
      ];
      AppleLocale = "en_US";
      # "com.apple.mouse.tapBehavior" = 1;
      # Delay before starting key repeat
      InitialKeyRepeat = 15;
      # Frequency of key repeat
      KeyRepeat = 2;
      # Save to iCloud (Desktop & Documents Folders)
      NSDocumentSaveNewDocumentsToCloud = true;
      # Prefer tabs when opening documents (always|fullscreen|never)
      AppleWindowTabbingMode = "always";
      # To have consistent font rendering across all apps (Alacritty, iTerm)
      AppleFontSmoothing = 0;
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Move Tab to New Window" = "~$n";
        # "Left" = "~^←";
        # "Right" = "~^→";
        # "Up" = "~^↑";
        # "Down" = "~^↓";
        # "Center" = "~^c";
        # "Fill" = "~^m";
      };
      # Use F1, F2, etc. keys as standard function keys
      "com.apple.keyboard.fnState" = true;
    };

    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    # Stage Manager
    "com.apple.WindowManager" = {
      GloballyEnabled = false;
      EnableStandardClickToShowDesktop = 1;
      StandardHideDesktopIcons = 1;
      HideDesktop = 1;
      StageManagerHideWidgets = 0;
      StandardHideWidgets = 1;
      AutoHide = true;
      EnableTiledWindowMargins = 0;
    };

    # Adds Input Sources
    "com.apple.HIToolbox" = {
      AppleFnUsageType = 3;
      AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 12825;
          "KeyboardLayout Name" = "Colemak";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 19458;
          "KeyboardLayout Name" = "RussianWin";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = -2354;
          "KeyboardLayout Name" = "Ukrainian-PC";
        }
        {
          "Bundle ID" = "com.apple.CharacterPaletteIM";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.PressAndHold";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.inputmethod.ironwood";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 0;
          "KeyboardLayout Name" = "U.S.";
        }
      ];
    };

    "com.apple.Safari" = {
      IncludeDevelopMenu = true;
      AutoFillCreditCardData = false;
      AutoFillPasswords = false;
      AutoFillMiscellaneousForms = false;
      AutoFillFromAddressBook = false;
      AutoOpenSafeDownloads = true;
      ShowOverlayStatusBar = true;
      "ShowFavoritesBar-v2" = false;
      AlwaysRestoreSessionAtLaunch = false;
      HomePage = "";
      ShowStandaloneTabBar = false;
      EnableNarrowTabs = true;
      SuppressSearchSuggestions = false;
      CommandClickMakesTabs = true;
      OpenNewTabsInFront = false;
      UniversalSearchEnabled = true;
      SendDoNotTrackHTTPHeader = true;
      WebKitStorageBlockingPolicy = 1;
      PreloadTopHit = true;
      ExtensionsEnabled = true;
      FindOnPageMatchesWordStartsOnly = false;
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Share…" = "@~s";
      };
    };

    "com.apple.ActivityMonitor" = {
      ShowCategory = 100;
    };

    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
      FXICloudDriveEnabled = true;
      FXICloudDriveDesktop = true;
      FXICloudDriveDocuments = true;
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Tags…" = "~$t";
      };
    };

    "com.apple.mail" = {
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Mail Selection to Task" = "@$t";
        "Navigate to Mailbox" = "@^n";
        "Move to Mailbox" = "@^m";
        "Get deep links for selected messages" = "@^~d";
        "Markdown to RTF" = "@^r";
        "Paste as Quotation" = "@^v";
        "Take All Accounts Offline" = "@$m";
        "Take All Accounts Online" = "@$o";
      };
      ConversationViewSortDescending = true;
      ShowBccHeader = true;
      ShowCcHeader = true;
      ShouldShowUnreadMessagesInBold = true;
      ShowComposeFormatInspectorBar = true;
      ShowPriorityControl = true;
      ShowReplyToHeader = false;
      SignaturePlacedAboveQuotedText = false;
    };

    # Keyboard Shortucts
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Option + 1 to Switch to Desktop 1
        "118" = {
          enabled = true;
          value = {
            parameters = [
              49
              18
              524288
            ];
            type = "standard";
          };
        };
        # Option + 2 to Switch to Desktop 2
        "119" = {
          enabled = true;
          value = {
            parameters = [
              50
              19
              524288
            ];
            type = "standard";
          };
        };
        # Option + 3 to Switch to Desktop 3
        "120" = {
          enabled = true;
          value = {
            parameters = [
              51
              20
              524288
            ];
            type = "standard";
          };
        };

        # Screenshot related shortcuts
        # Save picture of screen as a file (Shift + Command + 3)
        "28" = {
          enabled = false;
        };
        # Copy picture of screen to clipboard (Shift + Command + Control + 3)
        "29" = {
          enabled = false;
        };
        # Save picture of selected area as a file (Shift + Command + 4)
        "30" = {
          enabled = false;
        };
        # Copy picture of selected area to clipboard (Shift + Command + Control + 4)
        "31" = {
          enabled = false;
        };
        # Screenshot and recording options (Shift + Command + 5)
        "184" = {
          enabled = false;
        };
        # Changes `Show Spotlight Search` shortcut to `⌥ + Space`
        "64" = {
          enabled = true;
          value = {
            parameters = [
              32
              49
              524288
            ];
            type = "standard";
          };
        };
      };
    };
  };
}
