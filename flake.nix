#   nix run nix-darwin -- switch --flake "path:$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake path:~/.config/nixpkgs

{
  description = "Default user environment packages";
  inputs = {
    # Primary nixpkgs source for the system
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    # Stable nixpkgs source for the system
    nixpkgs-stable.url = "github:NixOs/nixpkgs/nixos-25.11";

    # Master nixpkgs source for the system to use for
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

    # Starship plugin for JJ
    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      nixpkgs-stable,
      # neovim-nightly-overlay,
      ...
    }@inputs:
    let
      overlays = [
        #  neovim-nightly-overlay.overlays.default
        (final: prev: rec {
          # csvkit 2.2.0 on unstable won't build so using 2.1.0 from stable
          csvkit = nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.csvkit;
          # Latest opencode from master nixpkgs
          # opencode = nixpkgs-master.legacyPackages.${prev.stdenv.hostPlatform.system}.opencode;
          # dark-mode-notify from nixpkgs-unstable doesn't work due to failed build of swift-5.10.1
          dark-mode-notify = nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.dark-mode-notify;
          # Using stable due to failing build of folly dep on nixpkgs-unstable
          watchman = nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.watchman;
        })
      ];
      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          inputs
          ;
      };
    in
    {
      inherit mkSystem;
      locations = {
        machines = ./machines;
        systems = ./systems;
        users = ./users;
      };
      darwinConfigurations.Nicks-MacBook-Air-0 = mkSystem "Nicks-MacBook-Air-0" {
        system = "aarch64-darwin";
        user = "nick";
        isDarwin = true;
      };
      darwinConfigurations.Nicks-Mac-mini-0 = mkSystem "Nicks-Mac-mini-0" {
        system = "aarch64-darwin";
        user = "nick";
        isDarwin = true;
      };
    };
}
