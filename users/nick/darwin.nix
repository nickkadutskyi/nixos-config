{
  config,
  lib,
  pkgs,

  inputs,
  machine,
  system,
  user,
  isWSL,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir = config.home.homeDirectory;
  syncHomeDir = homeDir + "/Library/Mobile\ Documents/com\~apple\~CloudDocs/Sync/HOME";
  cfgSync = syncHomeDir + "/.config";
in
{
  #---------------------------------------------------------------------
  # Services and Modules
  #---------------------------------------------------------------------
  imports = [
    ./shared.nix
  ];

  # Tool Theme Switching
  targets.darwin.services.tool-theme.enable = true;
  # Snippety Helper
  targets.darwin.services.snippety-helper.enable = true;
  # Development
  tools.development.enable = true;
  # Web Development
  tools.development.web.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  home.packages = [
    # ----------------------------------------------------------------
    # Tooling
    # ----------------------------------------------------------------
    pkgs._1password-cli
    pkgs.blueutil # Control bluetooth
    pkgs.duti # Set default apps for doc types and URL schemes
    pkgs.lua-language-server
    # Reformats Lua code
    pkgs.stylua
    # Provides vscode-css-language-server vscode-eslint-language-server
    # vscode-html-language-server vscode-json-language-server
    # vscode-markdown-language-server
    pkgs.vscode-langservers-extracted
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------
  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  home.sessionPath = [
    "/Applications/FlashSpace.app/Contents/Resources"
  ];

  xdg.configFile = {
    "1Password/ssh/agent.toml".text = import ./1p/ssh/agent.nix { inherit machine; };
    "karabiner/karabiner.json".source = ./karabiner/karabiner.json;
    "flashspace/profiles.json".source = config.lib.file.mkOutOfStoreSymlink (cfgSync + "/flashspace/profiles.json");
    "flashspace/settings.json".source = config.lib.file.mkOutOfStoreSymlink (cfgSync + "/flashspace/settings.json");
    "nvim_spell".source = config.lib.file.mkOutOfStoreSymlink (cfgSync + "/nvim_spell");
    "ghostty/config".text = import ./ghostty/config.nix { inherit isDarwin; };
    "ghostty/themes" = {
      source = ./ghostty/themes;
      recursive = true;
    };
  };

  home.file = {
    # Adds custom BibTeX types and fields to BibDesk
    "Library/Application\ Support/BibDesk/TypeInfo.plist".source = ./bibdesk/TypeInfo.plist;
    # Adds my custom templates to BibDesk
    "Library/Application\ Support/BibDesk/Templates/mdApaTemplate.txt".source = ./bibdesk/Templates/mdApaTemplate.txt;
    ".local/scripts".source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/scripts");
    ".ssh/conf.d" = {
      recursive = true;
      source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.ssh/conf.d");
    };
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs.git = {
    settings = {
      gpg = {
        # On macOS 1Password is used for signing using ssh key
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  programs.ssh = {
    includes = [ ] ++ (lib.optionals isDarwin [ "conf.d/*" ]);
    matchBlocks = lib.mkIf isDarwin {
      # Have come first in config to set proper IdentityAgent
      # Checks if NO1P is set and if so, sets IdentityAgent to default
      "_no1p" = {
        match = "host * exec \"[ ! -z \\\"\$NO1P\\\" -o ! -z \\\"\$SSH_CONNECTION\\\" ]\"";
        identityFile = [
          ("${homeDir}/.ssh/" + machine)
          ("${homeDir}/.ssh/EPDS")
          ("${homeDir}/.ssh/CUTN")
        ];
        extraOptions = {
          IdentityAgent = "SSH_AUTH_SOCK";
        };
      };
      "all" = {
        host = "*";
        identityFile = [
          (toString ./ssh + "/${machine}.pub")
          (toString ./ssh/EPDS.pub)
          (toString ./ssh/CUTN.pub)
        ];
        extraOptions = {
          IdentityAgent = "${homeDir}/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
    };
  };

  programs.zsh = {
    initContent =
      # bash
      ''
        # 1Password plugins initialization
        if [ -f ~/.config/op/plugins.sh ]; then
          # shellcheck disable=SC1090
          source ~/.config/op/plugins.sh
        fi
      '';
  };

  #---------------------------------------------------------------------
  # System and UI
  #---------------------------------------------------------------------
  targets.darwin.currentHostDefaults = lib.mkIf isDarwin {
    "com.apple.controlcenter" = {
      FocusModes = 18;
    };
  };
  targets.darwin.defaults = lib.mkIf isDarwin {
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
        {
          GUID = 4012255982;
          "tile-data" = {
            "bundle-identifier" = "com.mitchellh.ghostty";
            "dock-extra" = 0;
            "file-data" = {
              "_CFURLString" = "file:///Applications/Ghostty.app/";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Ghostty";
            "file-mod-date" = 234079536063012;
            "file-type" = 1;
            "is-beta" = 0;
            "parent-mod-date" = 249760461660710;
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
      _HIHideMenuBar = true;
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
      NSDocumentSaveNewDocumentsToCloud = false;
      # Prefer tabs when opening documents (always|fullscreen|never)
      AppleWindowTabbingMode = "always";
      # To have consistent font rendering across all apps
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
      # TrackpadFourFingerHorizSwipeGesture = 0;
      # TrackpadThreeFingerHorizSwipeGesture = 2;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      # TrackpadFourFingerHorizSwipeGesture = 0;
      # TrackpadThreeFingerHorizSwipeGesture = 2;
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
      AlwaysRestoreSessionAtLaunch = false;
      AutoFillCreditCardData = false;
      AutoFillFromAddressBook = false;
      AutoFillMiscellaneousForms = false;
      AutoFillPasswords = false;
      AutoOpenSafeDownloads = true;
      CommandClickMakesTabs = true;
      EnableNarrowTabs = true;
      ExtensionsEnabled = true;
      FindOnPageMatchesWordStartsOnly = false;
      HomePage = "";
      IncludeDevelopMenu = true;
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Share…" = "@~s";
      };
      OpenNewTabsInFront = false;
      PreloadTopHit = true;
      SearchProviderIdentifier = "com.google.www";
      SearchProviderShortName = "Google";
      SendDoNotTrackHTTPHeader = true;
      "ShowFavoritesBar-v2" = false;
      ShowOverlayStatusBar = true;
      ShowStandaloneTabBar = false;
      SuppressSearchSuggestions = false;
      UniversalSearchEnabled = true;
      WebKitStorageBlockingPolicy = 1;
    };

    "com.apple.ActivityMonitor" = {
      # Applications in 12 hours
      ShowCategory = 109;
    };

    "com.apple.iCal" = {
      "number of hours displayed" = 6;
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
        # disabled because conflicts with native macOS shortcuts
        # "Mail Selection to Task" = "@$r";
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

    "com.mitchellh.ghostty" = {
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "New Term Tab in Home" = "@~t";
        "New Term Window in Home" = "@~n";
        "New Term Split Down in Home" = "@$~d";
      };
    };

    "com.apple.freeform" = {
      # @ = Cmd; ^ = Control; ~ = Option; $ = Shift
      NSUserKeyEquivalents = {
        "Text Box" = "@$t";
        "Sticky Note" = "@~s";
        "Rectangle" = "@r";
        "Rounded Rectangle" = "@$r";
        "Oval" = "@o";
        "Diamond" = "@$d";
        "Quote Bubble" = "@b";
        "Line" = "@$l";
        "Connection Line" = "@$~l";
      };
    };

    # Keyboard Shortucts
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Enables ^ + -> and ^ + <- to switch between spaces
        "79" = {
          enabled = true;
        };
        "81" = {
          enabled = true;
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
        # Changes `Show Spotlight Search` shortcut to `Command + Space`
        "64" = {
          enabled = true;
          value = {
            parameters = [
              32
              49
              # 524288 # option key
              1048576 # command key
            ];
            type = "standard";
          };
        };
      };
    };
  };
}
