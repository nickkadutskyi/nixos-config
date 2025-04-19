{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  config = mkIf config.services.dnsmasq.enable {
    launchd.daemons.dnsmasq.serviceConfig.ProgramArguments =
      # Prepend /bin/wait4path
      mkBefore [ "/bin/wait4path" ];
    # The original ProgramArguments from the dnsmasq module will be merged automatically
  };
}
