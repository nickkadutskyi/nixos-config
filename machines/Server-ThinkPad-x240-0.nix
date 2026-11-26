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
    ./shared.nix
    ./server.nix
  ];

  boot.initrd.luks = {
    devices = {
      rootfs = {
        name = "rootfs";
        device = "/dev/sda1";
        # Pass TRIM through to the SSD so fstrim.timer reaches it; without it
        # the drive's write amplification and write latency climb.
        allowDiscards = true;
      };
    };
    forceLuksSupportInInitrd = true;
  };
  # Root lives on LVM inside LUKS, so it only appears after the passphrase is
  # entered. Wait for it indefinitely instead of failing into emergency mode
  # after the default 90 seconds.
  fileSystems."/".options = [ "x-systemd.device-timeout=0" ];
  boot.loader.grub = {
    device = "/dev/sda";
  };
  # The ESP is only 487 MB and each generation's kernel and initrd take about
  # 75 MB, so keep only a few boot entries.
  boot.loader.systemd-boot.configurationLimit = 3;

  # Prevent suspend and hibernate
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

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
      "systemctl suspend";
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
          (builtins.readFile ../users/${user}/ssh/Nicks-MacBook-Air-1.pub)
          (builtins.readFile ../users/${user}/ssh/Nicks-Mac-mini-0.pub)
          (builtins.readFile ../users/${user}/ssh/Nicks-iPhone-0.pub)
        ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
    # Answer pending disk-unlock prompts on SSH login, then leave a shell for
    # rescue. Uses /etc/profile because root's home in the systemd initrd is
    # /var/empty, so /root/.profile is never read.
    systemd.contents."/etc/profile".text = ''
      if [ -n "$SSH_CONNECTION" ]; then
        systemd-tty-ask-password-agent
      fi
    '';
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
