{
  config,
  pkgs,
  lib,

  system,
  machine,
  user,
  inputs,
  ...
}:
{
  imports = [
    ./shared.nix
  ];

  # Enable macOS built-in Apache
  services.httpd-darwin.enable = true;
  services.httpd-darwin.listen = [
    81
    444
  ];

  system.primaryUser = "nick";

  users.users.nick = {
    name = "nick";
    home = "/Users/nick";
    shell = pkgs.zsh;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    # User owning the Homebrew prefix
    user = user;
    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "nickkadutskyi/homebrew-cask" = inputs.nickkadutskyi-homebrew-cask;
    };
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    masApps = {
      "#blockit: Block distractions" = 1492879257;
      "1Blocker - Ad Blocker" = 1365531024;
      "1Password for Safari" = 1569813296; # 1Password Safari extension only
      "BetterJSON for Safari" = 1511935951;
      "Easy CSV Editor" = 1171346381;
      "iA Writer" = 775737590;
      "Keynote" = 409183694;
      "Magnet" = 441258766; # Window manager with iCloud sync
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Parcel - Delivery Tracking" = 375589283;
      "Redirect Web for Safari" = 1571283503;
      "Reeder" = 6475002485;
      "Snippety - Snippets Manager" = 1530751461;
    };
    casks = [
      "1password" # 1Password 8 main app
      "betterzip"
      "bibdesk" # reference manager
      "cleanshot"
      "clickup"
      "dash"
      "datagrip" # commercial IDE for database management
      "discord"
      "dropbox"
      "flashspace"
      # "nickkadutskyi/homebrew-cask/ghostty@tip" # using mine because official doesn't add terminfo
      "ghostty@tip"
      "google-chrome"
      "gpg-suite"
      "hazel"
      "iina"
      "jetbrains-toolbox"
      "karabiner-elements"
      "little-snitch"
      "logi-options+"
      "rapidapi"
      "slack"
      "splashtop-business"
      "teamviewer"
      "telegram"
      "transmission"
      "transmit"
      "typeface"
      "ungoogled-chromium"
      # Upwork may return 403 error sometimes so run switch again.
      "nickkadutskyi/homebrew-cask/upwork"
      "windows-app"
      "zoom"
    ];
    brews = [
      {
        name = "caddy";
        restart_service = true;
      }
      "mas"
      "ncurses"
    ];
    global.autoUpdate = false;
    onActivation = {
      # Removes unlisted casks and brews.
      cleanup = "zap";
      # Updates Homebrew and all formulae. (taps are flake inputs so update them manually)
      autoUpdate = false;
      # Upgrades outdated packages.
      upgrade = false;
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
    ];
  };

  # Enable the touch-id authentication for sudo via tmux reattach and in proper file
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix-Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';

  services.dnsmasq = {
    enable = true;
    addresses = {
      test = "127.0.0.1";
      "kdtsk.com" = "192.168.1.43";
    };
  };

  # Overriding dnsmasq to use /bin/wait4path
  launchd.daemons.dnsmasq.serviceConfig.ProgramArguments = lib.mkIf config.services.dnsmasq.enable (
    let
      mapA = f: attrs: with builtins; attrValues (mapAttrs f attrs);
      command =
        "${config.services.dnsmasq.package}/bin/dnsmasq "
        + "--listen-address=${config.services.dnsmasq.bind} "
        + "--port=${toString config.services.dnsmasq.port} "
        + "--keep-in-foreground "
        + pkgs.lib.strings.concatMapStrings (x: " " + x) (
          mapA (domain: addr: "--address=/${domain}/${addr} ") config.services.dnsmasq.addresses
        );
    in
    lib.mkForce [
      "/bin/sh"
      "-c"
      "/bin/wait4path /nix/store && exec ${command}"
    ]
  );
}
