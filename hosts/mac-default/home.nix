{ config, pkgs, ... }:
{
  launchd.enable = true;

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

      # JavaScript Development
      pnpm # package manager for JavaScript
      nodePackages_latest.nodejs
      # dart # disabled due to conflict with composer

      # Lua Development
      lua54Packages.lua # For lua development and neovim configs
      lua54Packages.luarocks # lua package manager
      stylua # lua formatter
      # lua-language-server # lua_ls
      # Linters
      luajitPackages.luacheck
      selene

      # TOML
      taplo # formatter

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
      zsh-autocomplete # autocomplete
      zsh-syntax-highlighting # highglits binaries in terminal
      oh-my-zsh # zsh framework

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
      syncHomeDir = config.home.homeDirectory + "/Library/Mobile\ Documents/com\~apple\~CloudDocs/Sync/HOME";
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
        text = # tmux
          ''
            set -g status-left-length 14
            set -sg escape-time 10
            bind-key & kill-window
            bind-key x kill-pane
            set -g set-titles-string "#T"
            set -g set-titles on

            # Fixes colors in tmux
            set -g default-terminal "tmux-256color"
            set -ag terminal-overrides ",$TERM:RGB"
            # Enables undercurl in tmux
            set -ga terminal-features ",$TERM:usstyle"

            # Neovim requested
            set -g focus-events on

            # Enables mouse mode
            set -g mouse on
            set -g history-limit 100000

            # Color Scheme dark and light modes
            if-shell "echo $(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null) | grep Dark" \
              "set -g pane-border-style fg='#393B40'; \
               set -g pane-active-border-style fg='#393B40' \
              " \
              "set -g pane-border-style fg='#EBECF0'; \
               set -g pane-active-border-style fg='#EBECF0' \
              "
          '';
      };
      ".config/alacritty" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/alacritty");
      };
      ".config/private_php/intelephense_license.txt" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/private_php/intelephense_license.txt");
      };
      ".config/private_clickup/key.txt" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/private_php/key.txt");
      };
      ".config/nvim" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/nvim");
      };
      ".config/nvim_spell" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/nvim_spell");
      };
      ".config/nixpkgs" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/nixpkgs");
      };
      ".config/karabiner" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/karabiner");
      };
      "bin" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/bin");
      };
      ".vimrc" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.vimrc");
      };
      ".ideavimrc" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.ideavimrc");
      };
      ".scss-lint.yml" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.scss-lint.yml");
      };
      "Library/Application\ Support/BibDesk/TypeInfo.plist" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/Library/Application\ Support/BibDesk/TypeInfo.plist");
      };
      "Library/Application\ Support/BibDesk/Templates/mdApaTemplate.txt" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (
          syncHomeDir + "/Library/Application\ Support/BibDesk/Templates/mdApaTemplate.txt"
        );
      };
      "Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary" = {
        enable = true;
        source = config.lib.file.mkOutOfStoreSymlink (
          syncHomeDir + "/Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary"
        );
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
        # {
        #   name = "zsh-autocomplete";
        #   src = pkgs.zsh-autocomplete;
        #   file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        # }
        {
          name = "git";
          src = pkgs.oh-my-zsh;
          file = "share/oh-my-zsh/plugins/git/git.plugin.zsh";
        }
        {
          name = "git-extras";
          src = pkgs.oh-my-zsh;
          file = "share/oh-my-zsh/plugins/git-extras/git-extras.plugin.zsh";
        }
      ];
      history = {
        save = 1000000000;
        size = 1000000000;
        ignoreAllDups = false;
      };
      # need this just for the theme
      oh-my-zsh = {
        enable = true;
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
      initExtraBeforeCompInit =
        # bash
        ''
          # This is before compinit (initExtraBeforeCompInit)
        '';
      initExtra =
        let
          tmuxTitleConfig = # bash
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
            '';
        in
        # bash
        ''
          # zsh-autocomplete start
          # TOOD decide how to better bind keys to mimic original experience or remove zsh-autocomplete
          # Make Tab and ShiftTab cycle completions on the command line
          # bindkey              '^I'         menu-complete
          # bindkey "$terminfo[kcbt]" reverse-menu-complete
          # Make Tab and ShiftTab change the selection in the menu
          # bindkey -M menuselect              '^I'         menu-complete
          # bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
          # # Make Tab and ShiftTab go to the menu
          # bindkey              '^I' menu-select
          # bindkey "$terminfo[kcbt]" menu-select
          # # Make Enter always submit the command line
          # bindkey -M menuselect '^M' .accept-line
          # zsh-autocomplete end

          # This is after compinit (initExtra)
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


          # zoxide start
          [ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
          # zoxide end

          ${if config.programs.zsh.oh-my-zsh.enable then tmuxTitleConfig else ""}

          # ls color start
          export LSCOLORS="exfxcxdxbxAxAxBxBxExEx"
          export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=1;30:cd=1;30:su=1;31:sg=1;31:tw=1;34:ow=1;34"
          # ls color end
        '';
      envExtra =
        # bash
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
        # Navigation
        ll = "ls -lah";
        # Tooling
        sc = # bash
          "symfony console";
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
        vi = "nvim";
        vim = "nvim";
        view = "nvim";
        vimdiff = "nvim";
        # EPDS
        # List EPDS AWS EC2 Instances
        epds_ec2 = "aws ec2 describe-instances  --query 'Reservations[].Instances[?not_null(Tags[?Key==\`Name\`].Value)]|[].[State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Tags[?Key==\`Name\`].Value[]|[0]] | sort_by(@, &[3])'  --output text |  sed '$!N;s/ / /'";
      };
    };

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
      # To have consistent font rendering across all apps (Alacritty, iTerm)
      AppleFontSmoothing = 0;
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
        # Disables Mission Control: Move left a space
        "79" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Disables Mission Control: Move right a space
        "81" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Screenshot related shortcuts
        # Save picture of screen as a file (Shift + Command + 3)
        "28" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Copy picture of screen to clipboard (Shift + Command + Control + 3)
        "29" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Save picture of selected area as a file (Shift + Command + 4)
        "30" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Copy picture of selected area to clipboard (Shift + Command + Control + 4)
        "31" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
        # Screenshot and recording options (Shift + Command + 5)
        "184" = {
          enabled = 0;
          value = {
            type = 65536;
            parameters = [ ];
          };
        };
      };
    };
  };
}
