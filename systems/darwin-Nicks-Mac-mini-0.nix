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

  # Nicks-Mac-mini specific configuration

  nix = {
    linux-builder = {
      enable = false;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 30 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
  };

  users.users.${user} = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../users/${user}/ssh/Nicks-MacBook-Air-0.pub)
    ];
  };

  homebrew = {
    casks = [
      "adobe-creative-cloud"
      # Manages reading materials and e-books
      "calibre"
      "crossover"
      "dropbox"
      # Required by VeraCrypt on Apple Silicon to mount encrypted volumes
      "fuse-t"
      "hhkb"
      # Parallels Desktop for Mac for running Windows and other VMs
      "parallels"
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
        path = "/Users/${user}/Tizen/tizen-studio/TizenStudio.app";
        icon = ../users/${user}/icons/tizen.icns;
      }
      {
        path = "/Users/${user}/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app";
        icon = ../users/${user}/icons/certificate_manager.icns;
      }
      {
        path = "/Users/${user}/Tizen/tizen-studio/tools/device-manager/bin/device-manager.app";
        icon = ../users/${user}/icons/device_manager.icns;
      }
    ];
  };
}
