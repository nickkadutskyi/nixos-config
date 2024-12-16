{ isWSL, inputs, ... }:

{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Keep it cross-platform
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Enables XDG Base Directory Specification support
  xdg.enable = true;

  # Packages I always want installed, but keep project specific packages
  # in their project specific flake.nix accessible via `nix develop`
  home.packages =
    with pkgs;
    [
      awscli2
      # cat with syntax highlighting (TODO configure colors)
      bat
      # Converts SASS to CSS (EPDS TODO make it project scoped)
      dart-sass
      # Feature–rich alternative to ls
      eza
      # Faster alternative to find
      fd
      # Fuzzy finder
      fzf
      # GNU Tools for consistency across systems
      gnutar
      gnused
      gnugrep
      google-cloud-sdk
      # Tunnel for socks5 proxy to http proxy (EPDS TODO make it project scoped)
      gost
      git
      # System monitoring
      htop
      # Parses JSON
      jq
      # Lints Lua code (TODO make it *editor scoped* or project scoped)
      luajitPackages.luacheck
      # Main editor (TODO make it work on NixOS, nix-darwin, and non-nix systems)
      neovim
      # Provides Nerd fonts for icons support
      nerd-fonts.jetbrains-mono
      # Nix language server (TODO keep only one server and make it project scoped)
      nil
      # Nix language server
      nixd
      # Reformats Nix code (TODO make it project scoped)
      nixfmt-rfc-style
      # Runs JavaScript (required by Copilot in Neovim TODO make it *editor scoped*)
      nodePackages_latest.nodejs
      # Searching PDF file contents (TODO check if I use this)
      pdfgrep
      # Faster alternative to grep
      ripgrep
      # Lints Lua code (TODO make it *editor scoped* or project scoped)
      selene
      # Reformats shell script (TODO make it *editor scoped*)
      shfmt
      speedtest-cli
      # For testing Stripe API (UPWZ TODO make it project scoped)
      stripe-cli
      # Reformats Lua code (TODO make it *editor scoped* or project scoped)
      stylua
      # Reformats TOML code (TODO make it *editor scoped*)
      taplo
      # Multiplexing (TODO configure in system config if I can make it autochange theme)
      tmux
      # Shows directory structure
      tree
      wget
      # Suggests entries from history with grey text
      zsh-autosuggestions
      # p10k prompt
      zsh-powerlevel10k
      # Highlights binaries in terminal emulator
      zsh-syntax-highlighting
    ]
    ++ (lib.optionals isDarwin [
      _1password-cli
      # Control bluetooth (TODO check if I need this)
      blueutil
      # GNU Coreutils (gtimeout is required by snippety-helper)
      coreutils-prefixed
      # Set default applications for doc types and URL schemes (TODO check if I use it)
      duti
      # Monitors a directory for changes (required by snippety-helper)
      fswatch
      # Global mysql and mysqldump for IntelliJ/DataGrip db export/import
      mariadb
    ])
    ++ (lib.optionals (isLinux && !isWSL) [
      chromium
    ]);

  programs.git = {
    enable = true;
    userName = "Nick Kadutskyi";
    userEmail = "nick@kadutskyi.com";
    aliases = {
      st = "status";
      ci = "commit";
      br = "branch";
      co = "checkout";
    };
    extraConfig = {
      core = {
        autocrlf = "input";
        editor = "nvim";
      };
      gpg = {
        format = "ssh";
      };
      gpg = {
        # On macOS 1Password is used for signing using ssh key
        ssh.program = lib.mkIf isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        followTags = true;
      };
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOOm/kpbXdO0Zg7XzDK3W67QUCZ/jutXK8w+pgoZqq";
      signByDefault = true;
    };
  };
  programs.alacritty = {
    enable = !isWSL;
    settings = import ./alacritty/alacritty.nix { inherit lib pkgs; };
  };
}
