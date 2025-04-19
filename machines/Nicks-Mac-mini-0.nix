{ config, pkgs, ... }:
{
  imports = [
    ./mac-shared.nix
  ];
  networking.computerName = "Nick's Mac mini 0";
}
