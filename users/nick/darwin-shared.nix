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
    # Commented out due to mas not working on macOS 15.4 https://github.com/mas-cli/mas/issues/724
    masApps = {
      # "1Blocker - Ad Blocker" = 1365531024;
      # "1Password for Safari" = 1569813296; # 1Password Safari extension only
      # "BetterJSON for Safari" = 1511935951;
      # "Easy CSV Editor" = 1171346381;
      # "iA Writer" = 775737590;
      # "Kagi for Safari" = 1622835804;
      # "Keynote" = 409183694;
      # "Magnet" = 441258766; # Window manager with iCloud sync
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
      # "Parcel - Delivery Tracking" = 639968404;
      # "Reeder Classic" = 1529448980;
      # "Snippety - Snippets Manager" = 1530751461;
      # "Xcode" = 497799835;
      # "Xdebug Key" = 1441712067;
    };
    casks = [
      "1password" # 1Password 8 main app
      "betterzip"
      "bibdesk" # reference manager
      "cleanshot"
      "clickup"
      "datagrip" # commercial IDE for database management
      "discord"
      "flashspace"
      "nickkadutskyi/homebrew-cask/ghostty@tip" # using mine because official doesn't add terminfo
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hazel"
      "iina"
      "jetbrains-toolbox"
      "karabiner-elements"
      "little-snitch"
      "logi-options+"
      "maccy" # clipboard manager
      "protonvpn"
      "rapidapi"
      "sketch"
      "slack"
      "splashtop-business"
      "teamviewer"
      "telegram"
      "transmission"
      "transmit"
      "typeface"
      "windows-app"
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

  # Enable the touch-id authentication for sudo via tmux reattach and in proper file
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix-Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';
}
