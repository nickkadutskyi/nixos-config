#   nix run nix-darwin -- switch --flake "path:$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake path:~/.config/nixpkgs

{
  description = "Default user environment packages";
  inputs = {
    # Primary nixpkgs source for the system
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    # Stable nixpkgs source for the system
    nixpkgs-stable.url = "github:NixOs/nixpkgs/nixos-24.11";

    # Master nixpkgs source for the system to use for
    # awscli2 because it fails to build on nixpkgs-unstable
    nixpkgs-master.url = "github:NixOs/nixpkgs/master";

    # NixOS like configuration for macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cross-platform user specific configuration for home directories
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manages Homebrew on macOS
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Declarative Homebrew Tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    nickkadutskyi-homebrew-cask = {
      url = "github:nickkadutskyi/homebrew-cask";
      flake = false;
    };

    # Sets custom icons on macOS
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";

    # Encrypts secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nightly version of Neovim
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      nix-darwin,
      home-manager,
      nix-homebrew,
      darwin-custom-icons,
      sops-nix,
      ...
    }@inputs:
    let
      overlays = [ ];
      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          nixpkgs-master
          inputs
          ;
      };
    in
    {
      darwinConfigurations.Nicks-MacBook-Air-0 = mkSystem "Nicks-MacBook-Air-0" {
        system = "aarch64-darwin";
        systemUser = "nick";
        isDarwin = true;
      };
      darwinConfigurations.Nicks-Mac-mini-0 = mkSystem "Nicks-Mac-mini-0" {
        system = "aarch64-darwin";
        systemUser = "nick";
        isDarwin = true;
      };
      nixosConfigurations.Server-x240-0 = mkSystem "Server-x240-0" {
        system = "x86_64-linux";
        systemUser = "nick";
      };
    };
}
