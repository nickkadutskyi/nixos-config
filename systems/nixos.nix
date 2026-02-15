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
  imports = [
    ./shared.nix
  ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  environment.systemPackages = [ pkgs.ghostty.terminfo ];

  # Since we're using zsh as our shell
  programs.zsh.enable = true;

  users.users.nick = {
    hashedPasswordFile = config.sops.secrets."nick/hashed_password".path;
    isNormalUser = true;
    home = "/home/nick";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../users/${user}/ssh/Nicks-MacBook-Air-0.pub)
      (builtins.readFile ../users/${user}/ssh/Nicks-Mac-mini-0.pub)
      (builtins.readFile ../users/${user}/ssh/Nicks-iPhone-0.pub)
    ];
  };

}
