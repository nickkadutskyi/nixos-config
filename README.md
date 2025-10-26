# System Configurations via Nix
This repository contains my system configurations based on Nix.
Originally my intention was to configure NixOS, I still haven't got to it
and currently this repository only provides configurations for macOS (Darwin).

# Setup macOS (Darwin)
If you are interested in setting up macOS via Nix feel free to use this
repository but keep in mind that it highly specific to my setup and may not
perfectly suit your needs.

1. Install Apple Developer Tools by running `xcode-select --install`
if you haven't done it yet.
2. Install Nix with some Nix installer
([nix-installer](https://nixos.org/download/),
[Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer), etc.)
to get `nix` CLI with Flake support.
3. Clone this repository
4. Run `nix run nix-darwin -- switch --flake .` to build and switch to the configuration

# Structure

Configurations are split into layers: machine, system, user.

**Machines** represent physical or virtual devices and located in `/machines`.
These configurations can have:
- shared configs for devices with similar purpose or where it makes sense, name
  them after purpose `server-shared.nix` or device type, e.g. `mac-shared.nix`
- machine-specific configs for particular devices, name after hostname of the device
- hardware-specific configs for machines running NixOS. Put these configurations
  into `/machines/hardware/` directory and import them into your machine config.

**Systems** represent OS-level or architecture-level configurations located in `/systems`.
These configurations can have:
- shared configs for all systems named `shared.nix` by default
- shared configs by system type named `[darwin|nixos].nix`
- By architecture named `[architecture]-[hostname].nix`
- By system type named `[darwin|nixos]-[hostname].nix`

Priority of selecting the system configuration is as follows by specificity:
1. By architecture and hostname
2. By system type and hostname
4. By system type
5. Shared system configuration

Use import to include other system configurations into your machine config if needed.

**Users** represent user-level configurations located in `/users`.
These configurations can have types of configs similar to systems with the same priority
but located in user-specific directories `/users/[username]/` and will serve as
home-manager configurations for the particular user.
