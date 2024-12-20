{
  config,
  pkgs,
  currentSystemUser,
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
          mkdir -p /Users/${currentSystemUser}/.local/state/snippety &amp;&amp; \
          /Users/${currentSystemUser}/Downloads/.snippety-helper/bin/snippety-helper.sh \
          >/Users/${currentSystemUser}/.local/state/snippety/org.nixos.snippety-helper.stdout.log \
          2>/Users/${currentSystemUser}/.local/state/snippety/org.nixos.snippety-helper.stderr.log
        ''
      ];
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/${currentSystemUser}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
