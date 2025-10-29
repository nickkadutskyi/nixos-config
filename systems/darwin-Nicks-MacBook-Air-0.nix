{
  config,
  pkgs,
  lib,

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

  users.users.${user} = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../users/${user}/ssh/Nicks-Mac-mini-0.pub)
    ];
  };

  homebrew = {
    casks = [
      # Manages reading materials and e-books
      "calibre"
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
      "veracrypt-fuse-t"
    ];
  };

  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "/Applications/Upwork.app";
        icon = ./icons/upwork.icns;
      }
    ];
  };
}
