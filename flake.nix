#   nix run nix-darwin -- switch --flake "path:$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake path:~/.config/nixpkgs

{
  description = "Default user environment packages";
  inputs = {
    # Primary nixpkgs source for the system
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    # Stable nixpkgs source for the system
    nixpkgs-stable.url = "github:NixOs/nixpkgs/nixos-26.05";

    # Master nixpkgs source for the system to use for
    nixpkgs-master.url = "github:NixOs/nixpkgs/master";

    # NixOS like configuration for macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    # Cross-platform user specific configuration for home directories
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brew-src = {
      url = "github:Homebrew/brew/5.1.15";
      flake = false;
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
    dunglas-homebrew-frankenphp = {
      url = "github:dunglas/homebrew-frankenphp";
      flake = false;
    };
    shivammathur-homebrew-php = {
      url = "github:shivammathur/homebrew-php";
      flake = false;
    };
    shivammathur-homebrew-extensions = {
      url = "github:shivammathur/homebrew-extensions";
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
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    # Latest Opencode dev build
    opencode = {
      url = "github:anomalyco/opencode";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    # Starship plugin for JJ
    starship-jj = {
      #   url = "gitlab:lanastara_foss/starship-jj";
      # Keep this branch for now to test the issue
      url = "gitlab:lanastara_foss/starship-jj/feature/finer_grained_timing";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      overlays = [
        (final: prev: rec {
          starship-jj = inputs.starship-jj.packages.${prev.stdenv.hostPlatform.system}.starship-jj;
          watchman = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.watchman;
          opencode = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system}.opencode.overrideAttrs (
            _:
            let
              # Map nix system to release asset name
              platformMap = {
                x86_64-linux = {
                  asset = "opencode-linux-x64.tar.gz";
                  isZip = false;
                };
                aarch64-linux = {
                  asset = "opencode-linux-arm64.tar.gz";
                  isZip = false;
                };
                x86_64-darwin = {
                  asset = "opencode-darwin-x64.zip";
                  isZip = true;
                };
                aarch64-darwin = {
                  asset = "opencode-darwin-arm64.zip";
                  isZip = true;
                };
              };
              hashes = {
                x86_64-linux = "sha256-cyfIVWmxDp7FJJqWQ/D9R34RfbVsRndtlXN8vASG+VA=";
                aarch64-linux = "sha256-cyfIVWmxDp7FJJqWQ/D9R34RfbVsRndtlXN8vASG+VA=";
                x86_64-darwin = "sha256-cyfIVWmxDp7FJJqWQ/D9R34RfbVsRndtlXN8vASG+VA=";
                # only this hash is proper one
                aarch64-darwin = "sha256-cyfIVWmxDp7FJJqWQ/D9R34RfbVsRndtlXN8vASG+VA=";
              };
              platform = prev.stdenv.hostPlatform.system;
              version = "1.17.0";
              platformInfo = platformMap.${platform} or (throw "Unsupported system: ${platform}");
            in
            {
              version = version;
              src = prev.fetchurl {
                url = "https://github.com/anomalyco/opencode/releases/download/v${version}/${platformInfo.asset}";
                hash = hashes.${platform};
              };
            }
          );
        })
        inputs.neovim-nightly-overlay.overlays.default
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
