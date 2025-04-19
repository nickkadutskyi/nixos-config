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
  nixpkgs.overlays = import ../lib/overlays.nix ++ [ ];
}
