{
  config,
  pkgs,
  lib,

  system,
  machine,
  user,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.btop
  ];
}
