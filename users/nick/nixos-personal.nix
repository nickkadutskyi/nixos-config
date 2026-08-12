{
  config,
  lib,
  pkgs,

  inputs,
  machine,
  system,
  user,
  isWSL,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    ./personal.nix
  ];

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs.git = {
    settings = {
      gpg = {
        # On macOS 1Password is used for signing using ssh key
        ssh.program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # button-layout = "close,maximize:menu";
      button-layout = "close:menu";
    };
  };
}
