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
      (builtins.readFile ../users/${user}/ssh/Nicks-iPhone-0.pub)
    ];
  };

  homebrew = {
    casks = [
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      "veracrypt-fuse-t"
    ];
  };
}
