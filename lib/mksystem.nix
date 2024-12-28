# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, inputs }:

name:
{
  system,
  user,
  darwin ? false,
  wsl ? false,
}:
let
  # True if this is a WSL system.
  isWSL = wsl;

  # Machine configuration for all users.
  machineConfig = ../machines/${name}.nix;

  # System configuration for a specific user.
  userSystemGenericConfig = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  userSystemSpecificConfig = ../users/${user}/${if darwin then "darwin-${name}.nix" else "nixos-${name}.nix"};
  userSystemConfig =
    if builtins.pathExists userSystemSpecificConfig then userSystemSpecificConfig else userSystemGenericConfig;

  # User specific configuration (shared across all machines)
  userHomeConfig = ../users/${user}/home.nix;

  # NixOS vs nix-darwin functions
  systemFunc = if darwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  sosps = if darwin then inputs.sops-nix.darwinModules else inputs.sops-nix.nixosModules;
in
systemFunc rec {
  inherit system inputs;
  modules = [
    {
      nixpkgs = {
        # Allow unfree packages.
        config.allowUnfree = true;
        # The platform the configuration will be used on.
        hostPlatform = system;
      };
    }
    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })
    machineConfig
    userSystemConfig
    home-manager.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHomeConfig {
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
    sosps.sops
    {
      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        age.keyFile = "/Users/nick/.config/sops/age/key.txt";
        secrets = {
          "php/intelephense_license" = {
            owner = user;
          };
          "clickup/api_key" = {
            owner = user;
          };
        };
      };
    }
    # Manages Homebrew on macOS with Nix
    (if darwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })
    (
      if darwin then
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = user;
            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              "nickkadutskyi/homebrew-cask" = inputs.my-homebrew-cask;
              "nikitabobko/homebrew-tap" = inputs.nikitabobko-homebrew-tap;
            };
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      else
        { }
    )
    # Custom icons for macOS
    (if darwin then inputs.darwin-custom-icons.darwinModules.default else { })

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
      };
    }
  ];
}
