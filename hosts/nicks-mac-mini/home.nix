{config, pkgs, ...}:
{
  targets.darwin.defaults = {
    NSGlobalDomain._HIHideMenuBar = true;
  };
}
