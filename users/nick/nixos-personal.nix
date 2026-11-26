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

  # Pushes every new store path to the Attic cache on x2400, so whatever one
  # machine builds the others can fetch. Needs a one-time login with a token
  # that can push to nick-main:
  #   attic login central https://cache.kdtsk.com/ <token>
  systemd.user.services.attic-watch-store = {
    Unit.Description = "Push new store paths to the nick-main Attic cache";
    Service = {
      ExecStart = "${pkgs.attic-client}/bin/attic watch-store nick-main";
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # button-layout = "close,maximize:menu";
      button-layout = "close:menu";
    };
  };
}
