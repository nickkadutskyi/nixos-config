{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  homeDir = config.home.homeDirectory;
  cfg = config.tools.development.web;
in
{
  options.tools.development.web = {
    enable = mkEnableOption "Web development environment with tools and services for web development.";
  };

  config = mkIf cfg.enable {
    #------------------------------------------------------------------------
    # General
    #------------------------------------------------------------------------
    home.packages = [
      pkgs.imagemagick
      pkgs.sourcemapper # Extract JS source maps
    ];

    #-------------------------------------------------------------------------
    # PHP
    #-------------------------------------------------------------------------
    home.activation.initIntelephense =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          # prepare intelephense directory
          /bin/mkdir -p ${homeDir}/intelephense
          # and hide it
          /usr/bin/chflags hidden ${homeDir}/intelephense
        '';
  };
}
