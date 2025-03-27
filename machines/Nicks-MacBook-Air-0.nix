{ config, pkgs, ... }:
{
  imports = [
    ./aarch64-darwin-shared.nix
  ];
  networking.computerName = "Nick's MacBook Air 0";
  networking.hostName = "Nicks-MacBook-Air-0";
  networking.dns = [ ];
}
