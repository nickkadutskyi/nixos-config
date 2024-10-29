{ config, pkgs, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages =
    with pkgs;
    [
      # Development
      devenv # development environment
      go # Probably for gcloud
      dart-sass # for sass to css conversion
      stripe-cli
      mariadb # global db execs mysql and mysqldump for Intellij export/import
      tree-sitter # for tree-sitter-cli for neovim

      # PHP Develpoment
      php83 # PHP 8.3 (currently latest) to run symfony console completion
      php83Packages.composer # package manager for PHP (to init PHP projects)
      symfony-cli # for Symfony dev
      # Linters 
      php83Packages.phpstan
      php83Packages.psalm
      php83Packages.php-codesniffer
      # Fixers
      php83Packages.php-cs-fixer
      # Language Servers
      nodePackages_latest.intelephense

      # JavaScript Development
      pnpm # package manager for JavaScript
      nodePackages_latest.nodejs
      # dart # disabled due to conflict with composer

      # Lua Development
      lua54Packages.lua # For lua development and neovim configs
      lua54Packages.luarocks # lua package manager
      stylua # lua formatter
      # lua-language-server # lua_ls

      # Tools
      awscli2 # AWS CLI
      google-cloud-sdk # Google Cloud SDK
      ffmpeg # for video conversion
      dos2unix # convert text files with different line breaks
      imagemagick # for image conversion and neovim plugin dependency
      pandoc # for markdown conversion
      # ueberzugpp # for image preview in terminal
      # chafa # for image preview in terminal
      # viu # for image preview in terminal

      # Nix
      nixfmt-rfc-style # formatter, nixfmt package with maintainers
      nil # nix language server
      nixd # nix language server

      # Misc
      exercism # for coding exercises
      mas # cli tool for Mac App Store apps to install via homebrew

      # Zsh
      zsh-completions # don't why I need this?
      zsh-powerlevel10k # prompt style
      zsh-autosuggestions # autosuggests with grey text from history
      zsh-syntax-highlighting # highglits binaries in terminal

      # Fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # Configures main font

    ]
    ++ (pkgs.lib.optionals (pkgs.lib.strings.hasInfix "linux" system) [
      git
    ])
    ++ (pkgs.lib.optionals (pkgs.lib.strings.hasInfix "darwin" system) [
      blueutil # control bluetooth (probably use in some script)
      duti # set default applications for document types and URL schemes
      perl # updating built-in perl
    ]);

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  home.file =
    let
      gitIgnoreGlobal = import ./home-files/gitignore_global.nix { inherit pkgs; };
    in
    {
      ".gitconfig" = {
        enable = true;
        executable = false;
        source = import ./home-files/gitconfig.nix {
          inherit pkgs;
          gitignore = gitIgnoreGlobal;
        };
      };
      ".hushlogin" = {
        enable = true;
        text = "";
      };
      ".tmux.conf" = {
        enable = true;
        text = ''
          set -sg escape-time 10
          # Changed to xterm-256color to support italics because tmux-256color doesn't support
          set -g default-terminal "xterm-256color"
          set -a terminal-overrides ",*256col*:RGB"
        '';
      };
      ".intelephense_license.txt" = {
        enable = true;
        target = ".config/php/intelephense_license.txt";
        # source = ~/Library/Mobile Documents/com~apple~CloudDocs/Sync/HOME/.config/php/intelephense_license.txt;
        source = config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/Library/Mobile\ Documents/com\~apple\~CloudDocs/Sync/HOME/.config/php/intelephense_license.txt");
      };
    };

  programs.zsh =
    let
      # is embedded into zshenv and zprofile for different kinds of shells
      zpath = # bash
        ''
          # Paths
          # Homebrew
          # HOMEBREW_PREFIX=$([ -d "/opt/homebrew" ] && echo /opt/homebrew || echo /usr/local)
          # Set PATH, MANPATH, etc., for Homebrew.
          # [ -d $HOMEBREW_PREFIX ] && eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
          #zpath User's private binaries and scripts
          export PATH="$PATH:$HOME/bin"
          # Tizen CLI
          export PATH=/Users/nick/Tizen/tizen-studio/tools/ide/bin:$PATH
          # Rust related
          [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
          # Composer vendor binaries
          export PATH="$HOME/.composer/vendor/bin:$PATH"
        '';
    in
    {
      enable = true;
      enableCompletion = true;
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ./p10k-config;
          file = "p10k.zsh";
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
      ];
      history = {
        save = 1000000000;
        size = 1000000000;
        ignoreAllDups = false;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "git-extras"
        ];
      };
      initExtraFirst = # bash
        ''
          # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
          # Initialization code that may require console input (password prompts, [y/n]
          # confirmations, etc.) must go above this block; everything else may go below.
          if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '';
      initExtraBeforeCompInit = # bash
        ''

        '';
      initExtra = # bash
        ''
          HISTSIZE=1000000

          # INIT
          # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
          # [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
          # Fuzzy search
          [ -x "$(command -v fzf)" ] && eval "$(fzf --zsh)"

          # FUNCTIONS
          # Fuzzy search functions
          # fd - cd to selected directory
          fd() {
            local dir
            dir=''$(find ''${1:-.} -path '*/\.*' -prune \
                            -o -type d -print 2> /dev/null | fzf +m) &&
            cd "''$dir"
          }
          # fh - search in your command history and execute selected command
          fh() {
            eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
          }

          # pnpm
          export PNPM_HOME="/Users/nick/Library/pnpm"
          case ":$PATH:" in
            *":$PNPM_HOME:"*) ;;
            *) export PATH="$PNPM_HOME:$PATH" ;;
          esac
          # pnpm end

        '';
      envExtra = # bash
        ''
          # Configure paths before loading the shell
          if [[ $SHLVL == 1 && ! -o LOGIN ]]; then
            ${zpath}
          fi

          # Default editor
          export EDITOR=nvim
          export VISUAL="$EDITOR"
          # GPG
          GPG_TTY=$(tty)
          export GPG_TTY
          # Lang settings
          export LC_ALL=en_US.UTF-8
          export LANG=en_US.UTF-8
        '';
      profileExtra = # bash
        ''
          if [[ $SHLVL == 1 ]]; then
            ${zpath}
          fi
        '';
      shellAliases = {
        sc = "symfony console";
        sym = "symfony";
        mfs = # bash
          "php artisan migrate:fresh --seed";
        mfss = # bash
          "mfs && php artisan db:seed --class=DevSeeder";
        ip = # bash
          "curl -4 icanhazip.com";
        ip4 = # bash
          "curl -4 icanhazip.com";
        ip6 = # bash
          "curl -6 icanhazip.com";
        iplan = # bash
          "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
        ips = # bash
          "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
        ip4a = # bash
          "dig +short -4 myip.opendns.com @resolver4.opendns.com";
        ip6a = # bash
          "dig +short -6 myip.opendns.com @resolver1.ipv6-sandbox.opendns.com AAAA";
        # TERM=tmux-256color adds support for undercurl in neovim
        vi = "TERM=tmux-256color nvim";
        vim = "TERM=tmux-256color nvim";
        view = "TERM=tmux-256color nvim -R";
        vimdiff = "TERM=tmux-256color nvim -d";
        # EPDS
        # List EPDS AWS EC2 Instances
        epds_ec2 = "aws ec2 describe-instances  --query 'Reservations[].Instances[?not_null(Tags[?Key==\`Name\`].Value)]|[].[State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Tags[?Key==\`Name\`].Value[]|[0]] | sort_by(@, &[3])'  --output text |  sed '$!N;s/ / /'";
      };
    };

  # programs.zsh.oh-my-zsh.enable = true;

  targets.darwin.defaults = {
    "com.apple.dock" = {
      autohide = true;
      "mru-spaces" = false;
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
      # Instead of specia char menu repeat the character
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
      # Prefer tabs when opening documents (always|fullscreen|never)
      AppleWindowTabbingMode = "always";
    };

    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    "com.apple.WindowManager" = {
      GloballyEnabled = true;
      EnableStandardClickToShowDesktop = 0;
      StandardHideDesktopIcons = 0;
      HideDesktop = 1;
      StageManagerHideWidgets = 0;
      StandardHideWidgets = 1;
      AutoHide = true;
      EnableTiledWindowMargins = 0;
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
    };

    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
      # NSUserKeyEquivalents = {
      #   "Tags..." = "~$t";
      #   "Tags…" = "~$t";
      # };
    };

    "com.apple.mail" = { };

    # Keyboard Shortucts
    "com.apple.symbolichotkeys" = {
      # Option + 1/2/3 to switch between Desktops
      AppleSymbolicHotKeys = {
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
      };
    };

  };
}
