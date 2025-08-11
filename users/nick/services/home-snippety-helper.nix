{
  config,
  pkgs,
  user,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Enables snippety-helper service
  launchd.agents.snippety-helper = {
    enable = isDarwin;
    config = {
      Label = "org.nixos.snippety-helper";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          mkdir -p /Users/${user}/.local/state/snippety && \
          /Users/${user}/Downloads/.snippety-helper/bin/snippety-helper.sh \
          >/Users/${user}/.local/state/snippety/org.nixos.snippety-helper.stdout.log \
          2>/Users/${user}/.local/state/snippety/org.nixos.snippety-helper.stderr.log
        ''
      ];
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/${user}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
