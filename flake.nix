#   nix run nix-darwin -- switch --flake "path:$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake path:~/.config/nixpkgs 

{
  description = "Default user environment packages";
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };
  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }@inputs:
    {
      # darwin system config here
      darwinConfigurations = {
        "Nicks-MacBook-Air" = nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules =
            [
              ./hosts/mac-default/configuration.nix
              ./hosts/nicks-macbook-air/configuration.nix
            ]
            ++ (if true then [ ./hosts/mac-default/services/dnsmasq.nix ] else [ ])
            ++ (if true then [ ./hosts/mac-default/services/snippety.nix ] else [ ])
            ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
            ++ [
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = false;
                home-manager.users = {
                  nick.imports = [ ./hosts/mac-default/home.nix ];
                };
              }
            ]
            ++ [
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  enable = true;
                  enableRosetta = true;
                  # User owning the Homebrew prefix
                  user = "nick";
                  autoMigrate = true;
                };
              }
            ]
            ++ [ ];
        };
        "Nicks-Mac-mini" = nix-darwin.lib.darwinSystem {
          inherit inputs;
          modules =
            [
              ./hosts/mac-default/configuration.nix
              ./hosts/nicks-mac-mini/configuration.nix
            ]
            ++ (if true then [ ./hosts/mac-default/services/dnsmasq.nix ] else [ ])
            ++ (if true then [ ./hosts/mac-default/services/snippety.nix ] else [ ])
            ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [ ])
            ++ [
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = false;
                home-manager.users = {
                  nick.imports = [
                    ./hosts/mac-default/home.nix
                    ./hosts/nicks-mac-mini/home.nix
                  ];
                };
              }
            ]
            ++ [
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  enable = true;
                  enableRosetta = true;
                  # User owning the Homebrew prefix
                  user = "nick";
                  autoMigrate = true;
                };
              }
            ]
            ++ [ ];
        };
      };
      # nixos system config here
    };
}
