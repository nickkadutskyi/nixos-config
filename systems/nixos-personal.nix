{
  config,
  pkgs,
  lib,

  system,
  machine,
  user,
  inputs,
  ...
}:
{
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  environment.systemPackages = [
    pkgs._1password-gui
    pkgs._1password-cli
    pkgs.google-chrome
    pkgs.ghostty
    pkgs.ghostty.terminfo
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "nick" ];
  };

  # Since we're using zsh as our shell
  programs.zsh.enable = true;
  users.users.${user} = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../users/${user}/ssh/Nicks-MacBook-Air-0.pub)
      (builtins.readFile ../users/${user}/ssh/Nicks-Mac-mini-0.pub)
      (builtins.readFile ../users/${user}/ssh/Nicks-iPhone-0.pub)
    ];
  };
}
