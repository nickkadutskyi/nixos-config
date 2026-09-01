{
  config,
  pkgs,
  lib,

  inputs,
  machine,
  system,
  isWSL,
  user,
  ...
}:
{
  imports = [
    ./shared.nix
    ./nixos-personal.nix
  ];

  programs.steam.enable = true;
}
