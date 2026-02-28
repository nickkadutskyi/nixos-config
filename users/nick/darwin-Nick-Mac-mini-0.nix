{
  config,
  lib,
  pkgs,

  inputs,
  machine,
  system,
  isWSL,
  user,
  ...
}:
{
  imports = [
    ./darwin.nix
  ];

  # Tizen Development
  tools.development.tizen.enable = true;
}
