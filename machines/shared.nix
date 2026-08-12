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
  # Set hostname based on output name
  networking.hostName = lib.mkDefault machine;

  nix = {
    package = lib.mkDefault pkgs.nixVersions.latest;

    settings = {
    };
  };
}
