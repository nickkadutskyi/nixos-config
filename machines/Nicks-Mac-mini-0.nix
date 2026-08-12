{ config, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./darwin-personal.nix
  ];
  networking.computerName = "Nick's Mac mini 0";
}
