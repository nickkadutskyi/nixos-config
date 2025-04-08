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

  # Prevent suspend and hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Prevent lid switch from suspending
  services.logind = {
    lidSwitch = "ignore";
    extraConfig = ''
      HandlePowerKey=ignore
    '';
  };

  services.acpid = {
    enable = true;
    lidEventCommands = # bash
      ''
        export PATH=$PATH:/run/current-system/sw/bin

        lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
        if [ $lid_state = "closed" ]; then
          # Set brightness to 0
          echo 0 > /sys/class/backlight/acpi_video0/brightness
        else
          # Reset the brightness to 100
          echo 100 > /sys/class/backlight/acpi_video0/brightness
        fi
      '';
    powerEventCommands = # bash
      ''systemctl suspend'';
  };
}
