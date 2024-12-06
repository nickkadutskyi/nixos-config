{config, pkgs, ...}:
{
  targets.darwin.defaults = {
    NSGlobalDomain._HIHideMenuBar = false;
  };
}
