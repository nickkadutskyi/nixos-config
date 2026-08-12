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
      ];
      substituters = [
        "https://devenv.cachix.org"
      ];
    };
  };
  sops = {
    defaultSopsFile = ../secrets/server/secrets.yaml;
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
    secrets = {
      "nick/hashed_password" = {
        owner = user;
        neededForUsers = true;
      };
    };
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
