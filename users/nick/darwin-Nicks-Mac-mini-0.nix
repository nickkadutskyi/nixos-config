{ inputs, pkgs, ... }:
{
  imports = [
    ./darwin.nix
  ];

  # Nicks-Mac-mini specific configuration

  users.users.nick = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/Nicks-MacBook-Air-0.pub)
    ];
  };

  homebrew = {
    casks = [
      "adobe-creative-cloud"
      "crossover"
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      "hhkb"
      # is not supported on macOS 15+
      # "nickkadutskyi/homebrew-cask/paragon-ntfs@15"
      "steam"
      "veracrypt-fuse-t"
      "vmware-fusion"
    ];
  };
}
