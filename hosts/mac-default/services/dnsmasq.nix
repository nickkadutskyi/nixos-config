{ pkgs, inputs, ... }:
let
  dnsmasqCustomConfig = {
      enable = true;
      bind = "127.0.0.1";
      port = 53;
      addresses = { test = "127.0.0.1"; };
  };
  mapA = f: attrs: with builtins; attrValues (mapAttrs f attrs);
  environmentEtc = {};
in 
  (if dnsmasqCustomConfig.enable then
  {
    launchd.daemons.dnsmasq-custom = {
        serviceConfig.ProgramArguments = [
          "/bin/sh"
          "-c"
          (
            "/bin/wait4path ${pkgs.dnsmasq}/bin/dnsmasq &amp;&amp; " +
            "exec " +
            "${pkgs.dnsmasq}/bin/dnsmasq " +
            "--listen-address=${dnsmasqCustomConfig.bind} " +
            "--port=${toString dnsmasqCustomConfig.port} " +
            "--keep-in-foreground " +
            pkgs.lib.strings.concatMapStrings (x: " " + x) (mapA (domain: addr: "--address=/${domain}/${addr} ") dnsmasqCustomConfig.addresses)
          )
        ] ;

        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
      };

      environment.etc = builtins.listToAttrs (builtins.map (domain: {
        name = "resolver/${domain}";
        value = {
          enable = true;
          text = ''
            port ${toString dnsmasqCustomConfig.port}
            nameserver ${dnsmasqCustomConfig.bind}
            '';
        };
      }) (builtins.attrNames dnsmasqCustomConfig.addresses));
  }
  else 
  {})
