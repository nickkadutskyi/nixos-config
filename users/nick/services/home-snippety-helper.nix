{
  config,
  pkgs,
  systemUser,
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
          mkdir -p /Users/${systemUser}/.local/state/snippety &amp;&amp; \
          /Users/${systemUser}/Downloads/.snippety-helper/bin/snippety-helper.sh \
          >/Users/${systemUser}/.local/state/snippety/org.nixos.snippety-helper.stdout.log \
          2>/Users/${systemUser}/.local/state/snippety/org.nixos.snippety-helper.stderr.log
        ''
      ];
      EnvironmentVariables = {
        PATH = "/etc/profiles/per-user/${systemUser}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
