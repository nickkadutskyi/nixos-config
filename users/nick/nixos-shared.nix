{ pkgs, inputs, config, ... }:
{
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using zsh as our shell
  programs.zsh.enable = true;

  users.users.nick = {
    hashedPasswordFile = config.sops.secrets."nick/hashed_password".path;
    isNormalUser = true;
    home = "/home/nick";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/Nicks-MacBook-Air-0.pub)
      (builtins.readFile ./ssh/Nicks-Mac-mini-0.pub)
    ];
  };
}
