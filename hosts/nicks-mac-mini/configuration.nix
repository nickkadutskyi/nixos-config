{ pkgs, inputs, ... }:
{
  networking.computerName = "Nick's Mac mini";
  networking.hostName = "Nicks-Mac-mini";
  # networking.dns = [ ];
  homebrew = {
    casks = [
      # "paragon-ntfs" # brew only provides v16 and no v15 so install manually
      "steam"
      # "vmware-fusion" # 
      "crossover"
      "hhkb"
      "adobe-creative-cloud"
    ];
  };
}
