{ config, pkgs, ... }:
{
  imports = [
    ./aarch64-darwin-shared.nix
  ];
  networking.computerName = "Nick's Mac mini";
  networking.hostName = "Nicks-Mac-mini";
}
