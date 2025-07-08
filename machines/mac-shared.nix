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
    # Handle Nix via Determinate Systems Installer
    enable = false;
  };
  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
    # pkgs.nushell
  ];
  # Packages for all users on the system
  environment.systemPackages = [
    pkgs.dnsmasq # wildcard *.test for local development
    # pkgs.nushell
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
