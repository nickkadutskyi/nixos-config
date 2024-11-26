{ pkgs, inputs, ... }:
{
  environment.userLaunchAgents.alacritty-helper = {
    enable = true;
    source = ./alacritty-agent.plist;
    target = "org.nixos.alacritty-helper.plist";
  };
}
