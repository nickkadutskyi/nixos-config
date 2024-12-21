{
  inputs,
  pkgs,
  config,
  currentSystemName,
  ...
}:
{
  users.users.nick = {
    name = "nick";
    home = "/Users/nick";
    shell = pkgs.zsh;
  };
  services.dnsmasq = {
    enable = true;
    bind = "127.0.0.1";
    port = 53;
    addresses = {
      test = "127.0.0.1";
    };
  };

  # imports = [
  #   ./services/darwin-dnsmasq.nix
  # ];

  homebrew = {
    enable = true;
    masApps = {
      "1Blocker - Ad Blocker" = 1365531024;
      "1Password for Safari" = 1569813296;
      "BetterJSON for Safari" = 1511935951;
      "Core Tunnel" = 1354318707;
      "Easy CSV Editor" = 1171346381;
      "Fonts Ninja" = 1480227114;
      "iA Writer" = 775737590;
      "Keynote" = 409183694;
      "Microsoft Remote Desktop" = 1295203466;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Parcel - Delivery Tracking" = 639968404;
      "Paste - Endless Clipboard" = 967805235;
      "Redirect Web for Safari" = 1571283503;
      "Reeder Classic" = 1529448980;
      "Slack for Desktop" = 803453959;
      "Snippety - Snippets Manager" = 1530751461;
      "Telegram" = 747648890;
      "Xdebug Key" = 1441712067;
    };
    casks = [
      "1password"
      {
        name = "alacritty";
        args = {
          no_quarantine = true;
        };
      }
      "betterzip"
      # Using for window snapping (trying aerospace now)
      "bettertouchtool"
      # BibDesk is a reference manager for LaTeX
      "bibdesk"
      # Manages reading materials and e-books
      "calibre"
      "cleanshot"
      "clickup"
      "dash"
      # DataGrip is a commercial IDE for database management
      "datagrip"
      "discord"
      "dropbox"
      # A cross-platform, open-source messenger app for matrix-based chats
      "element"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hazel"
      "iina"
      # TODO remove this when I fully move to Alacritty
      "iterm2@beta"
      "jetbrains-toolbox"
      "karabiner-elements"
      "little-snitch"
      # Graphical user interface for the 'defaults' command
      "prefs-editor"
      "protonvpn"
      "raycast"
      "rapidapi"
      "sketch"
      "splashtop-business"
      "spotify"
      "teamviewer"
      "transmission"
      "transmit"
      "tresorit"
      "typeface"
      # Upwork may return 403 error depending on your network.
      "nickkadutskyi/homebrew-cask/upwork"
      "zoom"
    ];
    brews = [ ];
    global.autoUpdate = false;
    onActivation = {
      # Removes unlisted casks and brews.
      cleanup = "zap";
      # Updates Homebrew and all formulae.
      autoUpdate = true;
      # Upgrades outdated packages.
      upgrade = true;
      extraFlags = [
        "--verbose"
        "--force"
      ];
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
  };
  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "/Applications/Alacritty.app";
        icon = ./alacritty/alacritty.icns;
      }
      {
        path = "/Applications/Upwork.app";
        icon = ./upwork.icns;
      }
    ];
  };
  # Enable the touch-id authentication for sudo via tmux reattach and in proper file
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix-Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';

  # i3-like tiling window manager for macOS
  services.aerospace = {
    enable = true;
    settings =
      let
        defaultLayout = if currentSystemName == "Nicks-MacBook-Air" then "accordion" else "tiles";
      in
      {
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        default-root-container-layout = "${defaultLayout}";
        accordion-padding = 0;
        after-startup-command = [ "layout ${defaultLayout}" ];
        gaps = {
          inner.horizontal = 1;
          inner.vertical = 1;
          outer.left = 0;
          outer.bottom = 0;
          outer.top = 0;
          outer.right = 0;
        };
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";
          alt-h = "focus --boundaries-action wrap-around-the-workspace left";
          alt-j = "focus --boundaries-action wrap-around-the-workspace down";
          alt-k = "focus --boundaries-action wrap-around-the-workspace up";
          alt-l = "focus --boundaries-action wrap-around-the-workspace right";
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-shift-minus = "resize smart -50";
          alt-shift-equal = "resize smart +50";
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-semicolon = "mode service";
        };
        mode.service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ]; # reset layout
          f = [
            "layout floating tiling"
            "mode main"
          ]; # Toggle between floating and tiling layout
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
        };
        key-mapping.key-notation-to-key-code = {
          # q = "q";
          # w = "w";
          # f = "e";
          # p = "r";
          # g = "t";
          # j = "y";
          # l = "u";
          # u = "i";
          # y = "o";
          # semicolon = "p";
          # leftSquareBracket = "leftSquareBracket";
          # rightSquareBracket = "rightSquareBracket";
          # backslash = "backslash";

          # a = "a";
          # r = "s";
          # s = "d";
          # t = "f";
          # d = "g";
          # h = "h";
          # n = "j";
          # e = "k";
          # i = "l";
          # o = "semicolon";
          # quote = "quote";

          # z = "z";
          # x = "x";
          # c = "c";
          # v = "v";
          # b = "b";
          # k = "n";
          # m = "m";
          # comma = "comma";
          # period = "period";
          # slash = "slash";
        };
      };
  };
}
