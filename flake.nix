#   nix run nix-darwin -- switch --flake "path:$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake path:~/.config/nixpkgs

{
  description = "Default user environment packages";
  inputs = {
    # Source of all packages
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    # NixOS like configuration for macOS
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Fro cross-platform user specific configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # For managing Homebrew by Nix on macOS
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Declarative Homebrew Tap management
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    my-homebrew-cask.url = "github:nickkadutskyi/homebrew-cask";
    my-homebrew-cask.flake = false;
    # For custom icons on macOS
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    # For encrypting secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      darwin-custom-icons,
      sops-nix,
      ...
    }@inputs:
    let
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs inputs;
      };
    in
    {
      darwinConfigurations.Nicks-MacBook-Air = mkSystem "Nicks-MacBook-Air" {
        system = "aarch64-darwin";
        user = "nick";
        darwin = true;
      };
      darwinConfigurations.Nicks-Mac-mini = mkSystem "Nicks-Mac-mini" {
        system = "aarch64-darwin";
        user = "nick";
        darwin = true;
      };
    };
}
