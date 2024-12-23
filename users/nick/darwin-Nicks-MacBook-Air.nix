{ inputs, pkgs, ... }:
{
  imports = [
    ./darwin.nix
  ];

  users.users.nick = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/Nicks-MacBook-Air.pub)
    ];
  };
}
