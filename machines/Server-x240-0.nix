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

  # Enable DHCP for enp0s25
  networking.interfaces.enp0s25.useDHCP = true;

  # Ensure enp0s25 name persists by tying it to the MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="28:d2:44:c9:08:04", NAME="enp0s25"
  '';
}
