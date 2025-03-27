# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  nixpkgs,
  nixpkgs-master,
  inputs,
  ...
}:

systemName:
{
  system,
  systemUser,
  isDarwin ? false,
  isWSL ? false,
}:
let
  # Machine configuration for all users.
  machineConfig = ../machines/${systemName}.nix;

  # System configuration for a specific user.
  userSystemGenericConfig = ../users/${systemUser}/${if isDarwin then "darwin" else "nixos"}.nix;
  userSystemSpecificConfig = ../users/${systemUser}/${
    if isDarwin then "darwin-${systemName}.nix" else "nixos-${systemName}.nix"
  };
  userSystemConfig =
    if builtins.pathExists userSystemSpecificConfig then userSystemSpecificConfig else userSystemGenericConfig;

  # NixOS vs nix-darwin functions
  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  sosps = if isDarwin then inputs.sops-nix.darwinModules else inputs.sops-nix.nixosModules;
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
      # User specific configuration (shared across all machines)
      home-manager.users.${systemUser} = import ../users/${systemUser}/home.nix {
        inherit
          isWSL
          inputs
          systemUser
          systemName
          ;
      };
    }
    sosps.sops
    {
      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        age.keyFile = "/Users/nick/.config/sops/age/keys.txt";
        secrets = {
          "php/intelephense_license" = {
            owner = systemUser;
          };
          "clickup/api_key" = {
            owner = systemUser;
          };
          "anthropic/api_key" = {
            owner = systemUser;
          };
          "tavily/api_key" = {
            owner = systemUser;
          };
        };
      };
    }
    # Manages Homebrew on macOS with Nix
    (if isDarwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })
    (
      if isDarwin then
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = systemUser;
            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              "nickkadutskyi/homebrew-cask" = inputs.nickkadutskyi-homebrew-cask;
            };
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      else
        { }
    )
    # Custom icons for macOS
    (if isDarwin then inputs.darwin-custom-icons.darwinModules.default else { })

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inherit
          system
          systemName
          systemUser
          isWSL
          ;
      };
    }
  ];
}
