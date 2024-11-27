{ config, pkgs, ... }:
with pkgs;
with builtins;
let
  nvrPath = (toString (lib.getExe neovim-remote));
  scriptContent = # bash
    ''
      SYSTEM_THEME=$(( /usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light" ) | tr '[:upper:]' '[:lower:]')
      IFS=$'\n'
      for s in $(${nvrPath} --serverlist); do
          test ! -S "$s" && continue
          if [[ $s =~ "nvimsocket" ]]; then
              ${nvrPath} --nostart --servername "$s" --remote-expr "execute('set background=$SYSTEM_THEME')"
          fi
      done
    '';
  scriptPath = (toString (writeShellScript "home-nvim-background.sh" scriptContent));
  cmdPath = (toString (lib.getExe dark-mode-notify));
in
{
  launchd.agents = {
    "nvim-background-helper" = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path ${cmdPath} &amp;&amp; ${cmdPath} ${scriptPath}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}
