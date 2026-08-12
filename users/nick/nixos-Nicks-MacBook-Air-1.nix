{
  config,
  lib,
  pkgs,

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
}
