{ ... }:
{
  imports = [
    ./darwin.nix
  ];

  targets.darwin.defaults."com.superlogical.rex" = {
    "rex.client.label" = "mba0";
    "rex.server.tailnet-hostname" = "mba0-rex";
  };
}
