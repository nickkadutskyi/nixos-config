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

  isLinux = !isDarwin && !isWSL;
  isNixOS = !isDarwin;

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
in
systemFunc {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [

    # -------------------------------------------------------------------------
    # MODULE DEFINITIONS
    # -------------------------------------------------------------------------

    # WSL-specific modules
    (if isWSL then { imports = [ inputs.nixos-wsl.nixosModules.wsl ]; } else { })
    # Linux-specific modules
    (if isLinux then { imports = [ ]; } else { })
    # Darwin-specific modules and configuration
    (
      if isDarwin then
        {
          imports = [
            # Third-party nix-darwin modules
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.darwin-custom-icons.darwinModules.default
            inputs.sops-nix.darwinModules.sops
            # My custom nix-darwin modules
            ../modules/darwin
          ];
        }
      else
        { }
    )
    # NixOS-specific modules and configuration
    (
      if isNixOS then
        {
          imports = [
            # Third-party NixOS modules
            inputs.sops-nix.nixosModules.sops
            # My custom NixOS modules
            ../modules/nixos
          ];
        }
      else
        { }
    )

    # User specific home configuration
    home-manager.home-manager

    # -------------------------------------------------------------------------
    # MODULE CONFIGURATIONS
    # -------------------------------------------------------------------------

    # Shared configuration across all systems and machines
    {
      nixpkgs = {
        overlays = overlays;
        # Allow unfree packages.
        config.allowUnfree = true;
        # The platform the configuration will be used on.
        hostPlatform = system;
      };
    }
    # Machine specific configuration e.g. configuration.nix and hardware-configuration.nix
    machineConfig
    # OS specific configuration
    systemConfig

    # We configure home-manager for our user
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
