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
