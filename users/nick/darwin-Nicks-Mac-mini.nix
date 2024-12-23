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
      "adobe-creative-cloud"
      "crossover"
      "hhkb"
      # is not supported on macOS 15+
      # "nickkadutskyi/homebrew-cask/paragon-ntfs@15"
      "steam"
      "vmware-fusion"
    ];
  };
}
