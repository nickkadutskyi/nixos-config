{
  inputs,
  pkgs,
  config,
  systemName,
  ...
}:
{
  users.users.nick = {
    name = "nick";
    home = "/Users/nick";
    shell = pkgs.zsh;
  };

  imports = [
    ./aerospace.nix
    # Using custom dnsmasq config because launchd ensures
    # that /nix/store is in path before running the command
    ./services/darwin-dnsmasq.nix
    # Configures Mac's built-in Apache server as reverse proxy
    ./darwin-httpd.nix
  ];

  homebrew = {
    enable = true;
    masApps = {
      "1Blocker - Ad Blocker" = 1365531024;
      "1Password for Safari" = 1569813296;
      "Amazon Kindle" = 302584613;
      "BetterJSON for Safari" = 1511935951;
      "Core Tunnel" = 1354318707;
      "Easy CSV Editor" = 1171346381;
      "Fonts Ninja" = 1480227114;
      "iA Writer" = 775737590;
      "Kagi for Safari" = 1622835804;
      "Keynote" = 409183694;
      "Windows App" = 1295203466; # Microsoft Remote Desktop
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Parcel - Delivery Tracking" = 639968404;
      "Reeder Classic" = 1529448980;
      "Slack for Desktop" = 803453959;
      "Snippety - Snippets Manager" = 1530751461;
      "Telegram" = 747648890;
      "Xcode" = 497799835;
      "Xdebug Key" = 1441712067;
    };
    casks = [
      "1password"
      "bettertouchtool"
      "betterzip"
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
      "finicky"
      "nickkadutskyi/homebrew-cask/ghostty@tip"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hazel"
      "iina"
      "iterm2@beta"
      "jetbrains-toolbox"
      "karabiner-elements"
      "little-snitch"
      "logi-options+"
      "maccy"
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
      # Graphical user interface for the 'defaults' command
      "prefs-editor"
      "protonvpn"
      "raycast"
      "rapidapi"
      "sketch"
      "splashtop-business"
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
        path = "/Applications/Upwork.app";
        icon = ./icons/upwork.icns;
      }
      {
        path = "/Users/nick/Tizen/tizen-studio/TizenStudio.app";
        icon = ./icons/tizen.icns;
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
