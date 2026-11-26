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
  imports = [ ./personal.nix ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.
    settings = {
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nick-main:KJl06cjrR1bMsPGdP58LxjQNe+CHHibEt5ik/qxF3m0="
      ];
      substituters = [
        "https://devenv.cachix.org"
        # Private Attic cache on x2400; netrc-file below holds its token.
        "https://cache.kdtsk.com/nick-main"
      ];
      # The secret is declared in machines/personal.nix.
      netrc-file = config.sops.secrets."attic/netrc".path;
    };
  };
  # Joins the tailnet, which is how this machine reaches the Attic cache on
  # x2400 at home and away. After the first switch run once:
  #   sudo tailscale up
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP port for direct (non-relayed) connections
  };

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;

    packages = [
      pkgs.jetbrains-mono
    ];
  };

  # NOTE: if changing this reset cache in GNOME:
  # `gsettings reset org.gnome.desktop.input-sources xkb-options`
  # `gsettings reset org.gnome.desktop.input-sources sources`
  services.xserver.xkb.options = "ctrl:nocaps";
  console.useXkbConfig = true;
}
