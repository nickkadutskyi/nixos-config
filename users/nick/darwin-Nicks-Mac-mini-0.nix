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
      # Manages reading materials and e-books
      "calibre"
      "crossover"
      "dash"
      "dropbox"
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      "hhkb"
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
      # is not supported on macOS 15+
      # "nickkadutskyi/homebrew-cask/paragon-ntfs@15"
      "steam"
      # Upwork may return 403 error sometimes so run switch again.
      "nickkadutskyi/homebrew-cask/upwork"
      "veracrypt-fuse-t"
      "vmware-fusion"
    ];
  };

  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "/Applications/Upwork.app";
        icon = ./icons/upwork.icns;
      }
      {
        path = "/Users/nick/Tizen/tizen-studio/TizenStudio.app";
        icon = ./icons/tizen.icns;
      }
      {
        path = "/Users/nick/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app";
        icon = ./icons/certificate_manager.icns;
      }
      {
        path = "/Users/nick/Tizen/tizen-studio/tools/device-manager/bin/device-manager.app";
        icon = ./icons/device_manager.icns;
      }
    ];
  };
}
