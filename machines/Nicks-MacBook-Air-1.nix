# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware/Nicks-MacBook-Air-1.nix
      ./shared.nix
      ./nixos-personal.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    extra-experimental-features = ["nix-command" "flakes"];
  };


  boot.initrd.luks.devices."luks-3f43ec5d-e1b1-4e37-b8a5-3eef888b9d29".device = "/dev/disk/by-uuid/3f43ec5d-e1b1-4e37-b8a5-3eef888b9d29";

  # SSH into the initrd to unlock the disks remotely, like x2400:
  #   ssh mba1_initrd_lan_eth
  # Only over the Thunderbolt Ethernet adapter (tg3); the Wi-Fi card needs the
  # proprietary wl driver. Port 2221 keeps the initrd host key apart from the
  # system's in known_hosts. Create the host key once before switching:
  #   sudo mkdir -p /etc/secrets/initrd
  #   sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  boot.initrd = {
    availableKernelModules = [
      "thunderbolt"
      "tg3"
    ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2221;
        authorizedKeys = map (m: builtins.readFile ../users/nick/ssh/${m}.pub) [
          "Nicks-MacBook-Air-0"
          "Nicks-MacBook-Air-1"
          "Nicks-Mac-mini-0"
          "Nicks-iPhone-0"
        ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
    # NetworkManager doesn't run in the initrd, so get an address over Ethernet.
    systemd.network.networks."10-ethernet" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
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
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Publish this machine on the LAN as Nicks-MacBook-Air-1.local, like the
  # Macs, and resolve other machines' .local names. GNOME already runs Avahi.
  services.avahi = {
    nssmdns4 = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Sleep like macOS: on the charger, stay awake with the lid closed or when
  # idle, so SSH and Rex keep working; on battery, suspend on lid close and
  # after idle. logind rechecks a closed lid when the charger is unplugged.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };
  # Wake from suspend when the charger is plugged in (ADP1 in
  # /proc/acpi/wakeup, disabled by default), so a closed Air that slept on
  # battery comes back for SSH and Rex once it's charging.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="platform", KERNEL=="ACPI0003:00", ATTR{power/wakeup}="enabled"
  '';
  # GNOME keeps the only display on with the lid closed, so on the charger the
  # backlight (and the Apple logo, which it lights) stays on. Turn it off on
  # lid close and restore it on open, like macOS.
  services.acpid = {
    enable = true;
    lidEventCommands = # bash
      ''
        export PATH=$PATH:/run/current-system/sw/bin
        bl=/sys/class/backlight/intel_backlight
        saved=/run/lid-closed-brightness
        if grep -q closed /proc/acpi/button/lid/LID0/state; then
          cat $bl/brightness > $saved
          echo 0 > $bl/brightness
        elif [ -f $saved ]; then
          cat $saved > $bl/brightness
          rm $saved
        fi
      '';
  };
  # Turn the screen off after 2 minutes idle on battery and 10 on the charger,
  # like macOS on mba0. GNOME has one delay for both, so this sets it whenever
  # UPower reports a power change. GNOME locks as soon as the screen blanks.
  systemd.user.services.idle-delay-by-power = {
    description = "Screen-off delay by power source";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    # Not in the GDM greeter's session, which also reaches graphical-session.target.
    unitConfig.ConditionUser = "nick";
    path = [
      pkgs.glib
      pkgs.dconf
    ];
    script = ''
      key=/org/gnome/desktop/session/idle-delay
      set_delay() {
        if [ "$(cat /sys/class/power_supply/ADP1/online)" = 1 ]; then
          delay="uint32 600"
        else
          delay="uint32 120"
        fi
        if [ "$(dconf read $key)" != "$delay" ]; then
          dconf write $key "$delay"
        fi
      }
      set_delay
      gdbus monitor --system --dest org.freedesktop.UPower \
        --object-path /org/freedesktop/UPower | while read -r _; do set_delay; done
    '';
  };
  # GNOME's idle suspend runs both on the GDM login screen and in the session:
  # never on the charger, and on battery after 2 minutes, when the screen
  # turns off, like macOS on mba0.
  # mkBefore puts these ahead of GDM's greeter defaults, which take precedence
  # otherwise. A change in GNOME Settings > Power still overrides the user one.
  programs.dconf.profiles =
    let
      idleSuspend = {
        settings."org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "suspend";
          sleep-inactive-battery-timeout = lib.gvariant.mkInt32 120;
        };
      };
    in
    {
      gdm.databases = lib.mkBefore [ idleSuspend ];
      user.databases = lib.mkBefore [ idleSuspend ];
    };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."nick" = {
    isNormalUser = true;
    description = "Nick Kadutskyi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    neovim
    git
    jujutsu
    xclip
    tree-sitter
    clang
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}

