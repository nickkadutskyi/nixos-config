{
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  #---------------------------------------------------------------------
  # Apps
  #---------------------------------------------------------------------

  # Tizen Studio
  home.activation = {
    tizenStudioIcons = lib.mkIf isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          TIZEN_ICONS_PATH="$HOME/Tizen/tizen-studio/TizenStudio.app/Contents/Eclipse/plugins/org.tizen.product.plugin_*/icons/branding"
          DEVICE_MANAGER_ICONS_PATH="$HOME/Tizen/tizen-studio/tools/device-manager/icons"
          DEVICE_MANAGER_PATH="$HOME/Tizen/tizen-studio/tools/device-manager"
          CERTIFICATE_MANAGER_ICONS_PATH="$HOME/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app/Contents/Eclipse/plugins/org.tizen.cert.product.plugin_*/icons"

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
            # ${pkgs.zip}/bin/zip -u $DEVICE_MANAGER_PATH/bin/device-ui-3.0.jar res/device-256.png -j "${./icons}/device-256.png"
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
        "Mail Selection to Task" = "@$r";
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
        # Option + 4 to Switch to Desktop 4
        "121" = {
          enabled = true;
          value = {
            parameters = [
              52
              21
              524288
            ];
            type = "standard";
          };
        };
        # Option + 5 to Switch to Desktop 5
        "122" = {
          enabled = true;
          value = {
            parameters = [
              53
              23
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
