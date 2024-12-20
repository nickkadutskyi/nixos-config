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

  imports = [
    ./aerospace.nix
  ];

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
      # Upwork may return 403 error sometimes so run switch again.
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
}
