self: super: {
  mas = super.mas.overrideAttrs (oldAttrs: rec {
    # Disabled because getting the latest version via Homebrew
    # version = "2.0.0";
    # src = super.fetchurl {
    #   url = "https://github.com/mas-cli/mas/releases/download/v${version}/mas-${version}.pkg";
    #   hash = "sha256-/8w5cCUZF5jgmKTZHfevnBdNE3ChC759yV5WsZmGw6g=";
    # };
  });
}
