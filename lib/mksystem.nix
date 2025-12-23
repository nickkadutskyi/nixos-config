# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  overlays,
  nixpkgs,
  nixpkgs-master,
  inputs,
  ...
}:

machine:
{
  system,
  user,
  isDarwin ? false,
  isWSL ? false,
  # Makes paths overridable to use in other projects
  machinesLoc ? ../machines,
  systemsLoc ? ../systems,
  usersLoc ? ../users,
}:
let
  systemType = if isDarwin then "darwin" else "nixos";

  mkConfPath =
    {
      loc,
      shared ? "shared.nix",
    }:
    let
      byArchMachine = loc + /${system}-${machine}.nix;
      byTypeMachine = loc + /${systemType}-${machine}.nix;
      byType = loc + /${systemType}.nix;
    in
    if builtins.pathExists byArchMachine then
      byArchMachine
    else if builtins.pathExists byTypeMachine then
      byTypeMachine
    else if builtins.pathExists byType then
      byType
    else
      loc + /${shared};

  # Machine specific configuration, equivalent to
  # NixOS configuration.nix and hardware-configuration.nix
  machineConfig = machinesLoc + /${machine}.nix;

  # OS configuration
  systemConfig = mkConfPath { loc = systemsLoc; };

  # Home configuration
  homeConfig = mkConfPath { loc = usersLoc + /${user}; };

  # NixOS vs nix-darwin functions
  systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  sosps = if isDarwin then inputs.sops-nix.darwinModules else inputs.sops-nix.nixosModules;
in
systemFunc {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    {
      nixpkgs = {
        overlays = overlays;
        # Allow unfree packages.
        config.allowUnfree = true;
        # The platform the configuration will be used on.
        hostPlatform = system;
      };
    }
    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })
    # Machine specific configuration e.g. configuration.nix and hardware-configuration.nix
    machineConfig
    # OS specific configuration
    systemConfig
    # User specific home configuration
    home-manager.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          machine
          system
          isWSL
          user
          ;
      };
      # User specific configuration (shared across all machines)
      home-manager.users.${user} = homeConfig;
    }
    # Secrets management in repo with SOPS
    sosps.sops
    # Manages Homebrew on macOS with Nix
    (if isDarwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })
    (
      if isDarwin then
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
    # macOS built-in Apache HTTP Server module
    (if isDarwin then ../modules/services/web-servers/darwin-apache-httpd.nix else { })

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      _module.args = {
        inherit
          machine
          system
          isWSL
          user
          ;
      };
    }
  ];
}
