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
    # Faster alternative to find
    pkgs.fd
    # GNU find, xargs, locate, updatedb utilities
    pkgs.findutils
    pkgs.git
    # GNU Tools for consistency across systems
    pkgs.gnutar
    pkgs.gnused
    pkgs.gnugrep
    # Faster alternative to grep
    pkgs.ripgrep
    # Multiplexing
    pkgs.tmux
    # Shows directory structure
    pkgs.tree
    pkgs.wget
  ];
}
