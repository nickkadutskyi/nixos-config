{ inputs, pkgs, ... }:
{
  imports = [
    ./darwin.nix
  ];

  # Nicks-Mac-mini specific configuration

  users.users.nick = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/Nicks-MacBook-Air.pub)
    ];
  };

  homebrew = {
    casks = [
      # "paragon-ntfs" # brew only provides v16 and no v15 so install manually
      "steam"
      # "vmware-fusion" #
      "crossover"
      "hhkb"
      "adobe-creative-cloud"
    ];
  };
}
