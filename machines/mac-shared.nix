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
  # Needed for macOS Sequoia
  system.stateVersion = 6;

  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      # Enables flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      substituters = [
        "https://devenv.cachix.org"
      ];
      extra-trusted-users = [
        "@admin"
        user
      ];
    };
    channel.enable = false;
    extraOptions = # bash
      ''
        keep-outputs = false
        keep-derivations = true
      '';

    # Store optimization—hard-link files with the same content to reduce storage
    optimise.automatic = true;
    optimise.interval = [
      # Default config
      {
        Hour = 4;
        Minute = 15;
        Weekday = 7; # Sunday is 0 and 7
      }
    ];

    # Store optimization—clears unneeded store paths
    gc.automatic = true;
    gc.interval = [
      # Default config
      {
        Hour = 3;
        Minute = 15;
        Weekday = 7;
      }
    ];
    gc.options = "--delete-older-than 30d";
  };
  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
  ];
  # Packages for all users on the system
  environment.systemPackages = [
    pkgs.dnsmasq # wildcard *.test for local development
  ];
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  networking.hostName = machine;

  networking.dns = [
    "1.1.1.1"
    "9.9.9.9"
    "8.8.8.8"
  ];
  networking.knownNetworkServices = [
    "Ethernet"
    "Wi-Fi"
  ];

  sops = {
    defaultSopsFile = ../secrets/mac/secrets.yaml;
    age.keyFile = "/Users/${user}/.config/sops/age/keys.txt";
    secrets = {
      "php/intelephense_license" = {
        owner = user;
      };
      "clickup/api_key" = {
        owner = user;
      };
      "anthropic/api_key" = {
        owner = user;
      };
      "tavily/api_key" = {
        owner = user;
      };
    };
  };
}
