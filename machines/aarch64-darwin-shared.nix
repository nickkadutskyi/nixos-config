{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Needed for macOS Sequoia
  system.stateVersion = 5;

  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix = {
    package = pkgs.nixVersions.nix_2_25;
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
    };
    channel.enable = false;
    extraOptions = # bash
      ''
        keep-outputs = false
        keep-derivations = true
      '';
  };
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];
  # Packages for all users on the system
  environment.systemPackages = with pkgs; [
    # For wildecard *.test for local development (TODO configure it with nix-darwin)
    dnsmasq
  ];
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
