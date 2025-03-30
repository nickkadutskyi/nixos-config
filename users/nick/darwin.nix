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
      "1Password for Safari" = 1569813296; # 1Password Safari extension only
      "BetterJSON for Safari" = 1511935951;
      # TODO replace core tunnel with SSH command
      "Core Tunnel" = 1354318707;
      "Easy CSV Editor" = 1171346381;
      "iA Writer" = 775737590;
      "Kagi for Safari" = 1622835804;
      "Keynote" = 409183694;
      "Magnet" = 441258766; # Window manager with iCloud sync
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
      "1password" # 1Password 8 main app
      "betterzip"
      # BibDesk is a reference manager for LaTeX
      "bibdesk"
      # Manages reading materials and e-books
      "calibre"
      "cleanshot"
      "dash"
      # DataGrip is a commercial IDE for database management
      "datagrip"
      "discord"
      "dropbox"
      "flashspace"
      "nickkadutskyi/homebrew-cask/ghostty@tip"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hazel"
      "iina"
      "jetbrains-toolbox"
      "karabiner-elements"
      "little-snitch"
      "logi-options+"
      "maccy" # Clipboard manager
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
      "protonvpn"
      "raycast"
      "rapidapi"
      "sketch"
      "splashtop-business"
      "teamviewer"
      "transmission"
      "transmit"
      "typeface"
      # Upwork may return 403 error sometimes so run switch again.
      "nickkadutskyi/homebrew-cask/upwork"
      "veracrypt-fuse-t"
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
      {
        path = "/Users/nick/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app";
        icon = ./icons/certificate_manager.icns;
      }
      {
        path = "/Users/nick/Tizen/tizen-studio/tools/device-manager/bin/device-manager.app";
        icon = ./icons/device_manager.icns;
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
