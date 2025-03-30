{ inputs, pkgs, ... }:
{
  imports = [
    ./darwin.nix
  ];

  users.users.nick = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/Nicks-Mac-mini-0.pub)
    ];
  };

  homebrew = {
    casks = [
      # Manages reading materials and e-books
      "calibre"
      "dash"
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
      # Upwork may return 403 error sometimes so run switch again.
      "nickkadutskyi/homebrew-cask/upwork"
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
