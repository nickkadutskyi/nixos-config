{ config, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./darwin-personal.nix
  ];
  networking.computerName = "Nick's MacBook Air 0";
}
