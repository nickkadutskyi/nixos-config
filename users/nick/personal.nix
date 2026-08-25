{
  config,
  lib,
  pkgs,

  inputs,
  machine,
  system,
  user,
  isWSL,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  #---------------------------------------------------------------------
  # Services and Modules
  #---------------------------------------------------------------------
  tools.development.enable = true;
  # Web Development
  tools.development.web.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  home.packages = [
    # ----------------------------------------------------------------
    # Tooling
    # ----------------------------------------------------------------
    pkgs._1password-cli
    pkgs.emmylua-ls
    # Reformats Lua code
    pkgs.stylua
    # Provides vscode-css-language-server vscode-eslint-language-server
    # vscode-html-language-server vscode-json-language-server
    # vscode-markdown-language-server
    pkgs.vscode-langservers-extracted
  ];
  xdg.configFile = {
    "1Password/ssh/agent.toml".text = import ./1p/ssh/agent.nix { inherit machine; };
    "ghostty/config".text = import ./ghostty/config.nix { inherit isDarwin; };
    "ghostty/themes" = {
      source = ./ghostty/themes;
      recursive = true;
    };
  };
}
