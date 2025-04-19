{ config, pkgs, ... }:
{
  imports = [
    ./mac-shared.nix
  ];
  networking.computerName = "Nick's MacBook Air 0";
}
