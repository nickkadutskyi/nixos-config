{
  config,
  lib,
  pkgs,
  systemUser,
  systemName,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir = config.home.homeDirectory;
in
{
  #---------------------------------------------------------------------
  # Services and Modules
  #---------------------------------------------------------------------
  imports = [
    (import ./services/home-snippety-helper.nix { inherit systemUser pkgs config; })
    ./services/home-theme.nix
  ];

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  home.packages =
    [ ]
    ++ (lib.optionals isDarwin [
      pkgs._1password-cli
      # Control bluetooth
      pkgs.blueutil
      # GNU Coreutils (gtimeout is required by snippety-helper)
      pkgs.coreutils-prefixed
      # Set default applications for doc types and URL schemes
      pkgs.duti
      # Monitors a directory for changes (required by snippety-helper)
      pkgs.fswatch
    ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------
  home.shellAliases = {
    iplan = # bash
      lib.mkIf isDarwin "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
    ips = # bash
      lib.mkIf isDarwin "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
  };
  xdg.configFile = {
    "ideavim/ideavimrc" = {
      enable = isDarwin;
      text = ''
        source ${./vim/vimrc}
        ${builtins.readFile ./vim/ideavimrc}
      '';
    };
    "karabiner/karabiner.json" = {
      enable = isDarwin;
      text = builtins.readFile ./karabiner/karabiner.json;
    };
  };

  home.file =
    let
      syncHomeDir = homeDir + "/Library/Mobile\ Documents/com\~apple\~CloudDocs/Sync/HOME";
    in
    {
      ".config/btt/btt.json" = {
        enable = isDarwin;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/btt/btt.json");
      };
      ".config/flashspace/profiles.json" = {
        enable = isDarwin;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/flashspace/profiles.json");
      };
      ".config/flashspace/settings.json" = {
        enable = isDarwin;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/flashspace/settings.json");
      };
      # Synchronizes macOS's global spelling dictionary (Requires giving AppleSpell service Full Disk Access)
      "Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary" = lib.mkIf isDarwin {
        source = config.lib.file.mkOutOfStoreSymlink (
          syncHomeDir + "/Library/Group\ Containers/group.com.apple.AppleSpell/Library/Spelling/LocalDictionary"
        );
      };
      # Adds custom BibTeX types and fields to BibDesk
      "Library/Application\ Support/BibDesk/TypeInfo.plist" = {
        enable = isDarwin;
        source = ./bibdesk/TypeInfo.plist;
      };
      # Adds my custom templates to BibDesk
      "Library/Application\ Support/BibDesk/Templates/mdApaTemplate.txt" = {
        enable = isDarwin;
        source = ./bibdesk/Templates/mdApaTemplate.txt;
      };
      ".local/scripts" = {
        enable = isDarwin;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/scripts");
      };
      ".ssh/conf.d" = {
        enable = isDarwin;
        recursive = true;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.ssh/conf.d");
      };
      ".config/nvim_spell" = {
        enable = isDarwin;
        source = config.lib.file.mkOutOfStoreSymlink (syncHomeDir + "/.config/nvim_spell");
      };
    };

  #---------------------------------------------------------------------
  # Workspace
  #---------------------------------------------------------------------

  home.activation = {
    initDarwin = lib.mkIf isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          export CRM_ACCOUNTS

          # Create dev directories for CRM accounts and projects
          CRM_ACCOUNTS=${homeDir}/Library/Mobile\ Documents/com~apple~CloudDocs/Projects
          for acc_path in "$CRM_ACCOUNTS"/*/; do
            acc_name="$(basename "$acc_path")"
            for project_path in "$acc_path"/*/; do
              project_name="$(basename "$project_path" | cut -d' ' -f1)"
              if [[ $project_name =~ ^[0-9]+$ ]] && [ -f "$project_path/.project.json" ]; then
                mkdir -p "${homeDir}/Developer/$acc_name/$project_name"
              fi
            done
          done

          # prepare intelephense directory
          /bin/mkdir -p ${homeDir}/intelephense
          # and hide it
          /usr/bin/chflags hidden ${homeDir}/intelephense
        ''
    );
    # Required for snippety-helper
    snippetyHelperInstallation = lib.mkIf isDarwin (
      let
        installerScript = import ./snippety/snippety-helper-installer.nix { inherit pkgs config; };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          export PKG_CURL PKG_BASH
          PKG_BASH=${pkgs.bash}
          PKG_CURL=${pkgs.curl}
          if [ ! -d ${homeDir}/Downloads/.snippety-helper ]; then
            cd ${homeDir}/Downloads && "$PKG_BASH/bin/bash" ${installerScript}
          fi
        ''
    );
    # Required for snippety-helper
    checkBashPermissions =
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
  programs.git = {
    extraConfig = {
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
        match = "host * exec \"[ ! -z \$NO1P ]\"";
        identityFile = [
          ("${homeDir}/.ssh/" + systemName)
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
          (toString ./ssh + "/${systemName}.pub")
          (toString ./ssh/EPDS.pub)
          (toString ./ssh/CUTN.pub)
        ];
        extraOptions = {
          IdentityAgent = "${homeDir}/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
    };
  };

  #---------------------------------------------------------------------
  # Apps
  #---------------------------------------------------------------------

  # Tizen Studio
  home.activation = {
    tizenStudioIcons = lib.mkIf isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          TIZEN_ICONS_PATH="${homeDir}/Tizen/tizen-studio/TizenStudio.app/Contents/Eclipse/plugins/org.tizen.product.plugin_*/icons/branding"
          DEVICE_MANAGER_ICONS_PATH="${homeDir}/Tizen/tizen-studio/tools/device-manager/icons"
          DEVICE_MANAGER_PATH="${homeDir}/Tizen/tizen-studio/tools/device-manager"
          CERTIFICATE_MANAGER_ICONS_PATH="${homeDir}/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app/Contents/Eclipse/plugins/org.tizen.cert.product.plugin_*/icons"

          SIZES="16 32 64 128 256 512"
          if [ -d $TIZEN_ICONS_PATH ]; then
            cp -f "${./icons}/tizen_studio_64.png" $TIZEN_ICONS_PATH/"tizen_studio_48.png"
            for size in $SIZES; do
              cp -f "${./icons}/tizen_studio_''${size}.png" $TIZEN_ICONS_PATH/"tizen_studio_''${size}.png"
            done
          else
            echo "Missing Tizen Studio icons path: $TIZEN_ICONS_PATH"
          fi
          SIZES="128 256"
          if [ -d $DEVICE_MANAGER_ICONS_PATH ]; then
            mkdir -p temp_dir/res
            cp "${./icons}/device-256.png" temp_dir/res/
            (cd temp_dir && ${pkgs.zip}/bin/zip -u $DEVICE_MANAGER_PATH/bin/device-ui-3.0.jar res/device-256.png)
            rm -rf temp_dir
            cp -f "${./icons}/device_manager.icns" $DEVICE_MANAGER_ICONS_PATH/"device_manager.icns"
            cp -f "${./icons}/device_manager.ico" $DEVICE_MANAGER_ICONS_PATH/"device_manager.ico"
            for size in $SIZES; do
              cp -f "${./icons}/device_manager_''${size}.png" $DEVICE_MANAGER_ICONS_PATH/"device_manager_''${size}.png"
            done
          else
            echo "Missing Device Manager icons path: $DEVICE_MANAGER_ICONS_PATH"
          fi
          SIZES="16 32"
          if [ -d $CERTIFICATE_MANAGER_ICONS_PATH ]; then
            cp -f "${./icons}/icon_certificate_512.png" $CERTIFICATE_MANAGER_ICONS_PATH/"icon_certificate_48.png"
            for size in $SIZES; do
              cp -f "${./icons}/icon_certificate_''${size}.png" $CERTIFICATE_MANAGER_ICONS_PATH/"icon_certificate_''${size}.png"
            done
          else
            echo "Missing  Certificate Manager icons path: $CERTIFICATE_MANAGER_ICONS_PATH"
          fi
        ''
    );
  };

  #---------------------------------------------------------------------
  # System and UI
  #---------------------------------------------------------------------
  targets.darwin.defaults = {
    "com.hegenberg.BetterTouchTool" = {
      BTTAutoLoadPath = "${homeDir}/.config/btt/btt.json";
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
          GUID = 1478090452;
          "tile-data" = {
            arrangement = 2;
            displayas = 0;
            "file-data" = {
              "_CFURLString" = "file:///Users/nick/Library/Mobile%20Documents/27N4MQEA55~pro~writer/Documents/Notes/Notepad.md";
              "_CFURLStringType" = 15;
            };
            "file-label" = "Notepad.md";
            "file-mod-date" = 58376725448597;
            "file-type" = 40;
            "is-beta" = 0;
            "parent-mod-date" = 3824928666;
            preferreditemsize = "-1";
            showas = 0;
          };
          "tile-type" = "file-tile";
        }
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
        # {
        #   GUID = 3715713668;
        #   "tile-data" = {
        #     arrangement = 2;
        #     displayas = 0;
        #     "file-data" = {
        #       "_CFURLString" = "file:///Users/nick/Documents/";
        #       "_CFURLStringType" = 15;
        #     };
        #     "file-label" = "Documents";
        #     "file-mod-date" = 3808363796;
        #     "file-type" = 2;
        #     "is-beta" = 0;
        #     "parent-mod-date" = 261124935269833;
        #     preferreditemsize = "-1";
        #     showas = 0;
        #   };
        #   "tile-type" = "directory-tile";
        # }
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
      SearchProviderIdentifier = "org.ecosia.www";
      SendDoNotTrackHTTPHeader = true;
      "ShowFavoritesBar-v2" = false;
      ShowOverlayStatusBar = true;
      ShowStandaloneTabBar = false;
      SuppressSearchSuggestions = false;
      UniversalSearchEnabled = true;
      WebKitStorageBlockingPolicy = 1;
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
