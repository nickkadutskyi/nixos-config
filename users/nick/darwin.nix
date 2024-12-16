{ inputs, pkgs, ... }:
{
  users.users.nick = {
    name = "nick";
    home = "/Users/nick";
    shell = pkgs.zsh;
  };

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
      "anydesk"
      "appcleaner"
      "betterzip"
      "bettertouchtool"
      "bibdesk"
      "calibre"
      # "chromium 66" # not present in any package manager so handle it directly
      "cleanshot"
      "clickup"
      # "core-tunnel"
      "daisydisk"
      "dash"
      "discord"
      "docker"
      "dropbox"
      "element"
      # "finicky"
      "firefox"
      "google-chrome"
      "google-drive"
      "gpg-suite"
      "hazel"
      "iina"
      "iterm2@beta"
      "jetbrains-toolbox"
      "karabiner-elements" # disabled to handle via nix-darwin
      # "little-snitch" # disabled because breaking ssh in LAN
      # "logi-options-plus" # deletes/installs on each switch so commenting this out for now
      "microsoft-edge"
      "microsoft-teams"
      "obsidian"
      "protonvpn"
      "rapidapi"
      "raycast"
      "sf-symbols"
      "sketch"
      # "sloth" # for monitoring network and disk usage; never user it
      "splashtop-business"
      "spotify"
      "teamviewer"
      "tor-browser"
      "transmission"
      "transmit"
      "tresorit"
      "typeface"
      # "upwork" # missing from any package managers so handling it directly
      "veracrypt"
      "webex"
      "wireshark"
      "zoom"

    ];
  };
}
