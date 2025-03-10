{ config, pkgs, ... }:
{
  imports = [
    ./aarch64-darwin-shared.nix
  ];
  networking.computerName = "Nick's MacBook Air";
  networking.hostName = "Nicks-MacBook-Air";
  networking.dns = [ ];
}
