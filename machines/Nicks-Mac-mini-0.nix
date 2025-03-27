{ config, pkgs, ... }:
{
  imports = [
    ./aarch64-darwin-shared.nix
  ];
  networking.computerName = "Nick's Mac mini 0";
  networking.hostName = "Nicks-Mac-mini-0";
}
