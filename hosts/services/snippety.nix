{ pkgs, inputs, ... }:
{
  # Enables snippety-helper service
  environment.userLaunchAgents.snippety-helper = {
    enable = true;
    source = ./snippety-agent.plist;
    target = "org.nixos.snippety-helper.plist";
  };

  # Enable logs rotation for snippety-helper logs
  environment.etc."newsyslog.d/org.nixos.user.snippety.conf".text = ''
    # Managed by Nix-Darwin
    # logfilename                           [owner:group]  mode  count  size  when  flags [/pid_file] [sig_num]
    /Users/**/.local/state/snippety/*.log   nick:staff     640   5      1024  *     G
  '';
}
