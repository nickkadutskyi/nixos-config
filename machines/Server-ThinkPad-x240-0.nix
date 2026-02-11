{
  config,
  pkgs,
  lib,

  system,
  machine,
  user,
  inputs,
  ...
}:
{
  imports = [
    ./hardware/Server-ThinkPad-x240-0.nix
    ./server-shared.nix
  ];

  boot.initrd.luks = {
    devices = {
      rootfs = {
        name = "rootfs";
        device = "/dev/sda1";
        preLVM = true;
      };
    };
    forceLuksSupportInInitrd = true;
  };
  boot.loader.grub = {
    device = "/dev/sda";
  };

  # Prevent suspend and hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Prevent lid switch from suspending
  # services.logind = {
  #   lidSwitch = "ignore";
  #   extraConfig = ''
  #     HandlePowerKey=ignore
  #   '';
  # };
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandlePowerKey = "ignore";
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

  boot.initrd = {
    availableKernelModules = [
      "e1000e"
      "ccm"
      "ctr"
      "iwlmvm"
      "iwlwifi"
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = [
          (builtins.readFile ../users/${user}/ssh/Nicks-MacBook-Air-0.pub)
          (builtins.readFile ../users/${user}/ssh/Nicks-Mac-mini-0.pub)
          (builtins.readFile ../users/${user}/ssh/Nicks-iPhone-0.pub)
        ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        # Automatically ask for the password on SSH login
        echo 'cryptsetup-askpass || echo "Unlock was successful; exiting SSH session" && exit 1' >> /root/.profile
      '';
    };
  };

  # Ensure enp0s25 name persists by tying it to the MAC address
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="28:d2:44:c9:08:04", NAME="enp0s25"
  '';

  networking = {
    interfaces = {
      enp0s25 = {
        # Enable DHCP for enp0s25
        useDHCP = true;
      };
    };
  };
}
