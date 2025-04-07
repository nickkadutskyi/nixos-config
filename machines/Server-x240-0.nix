{ config, pkgs, ... }:
{
  imports = [
    ./hardware/Server-x240-0.nix
    ./x86_64-linux-shared.nix
  ];

  boot.initrd.luks.devices = {
    rootfs = {
      name = "rootfs";
      device = "/dev/sda1";
      preLVM = true;
    };
  };
  boot.loader.grub = {
    device = "/dev/sda";
  };
}
