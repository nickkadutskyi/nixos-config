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

  targets.darwin.defaults."com.superlogical.rex" = {
    "Workspace.terminalPaddingX" = lib.mkForce 8.0;
    "Workspace.terminalPaddingY" = lib.mkForce 8.0;
    "rex.client.label" = "mini0";
    "rex.server.tailnet-hostname" = "mini0-rex";
  };

  # Tizen Development
  tools.development.tizen.enable = true;
}
