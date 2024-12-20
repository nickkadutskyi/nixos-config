{ config, pkgs, ... }:
with pkgs;
let
  scriptContent = # bash
    ''
      FZF_CONFIG=~/.config/fzf
      FZF_THEME=~/.config/fzf/fzfrc
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")
      /bin/ln -sf "$FZF_CONFIG/$SYSTEM_THEME.fzfrc" "$FZF_THEME"
    '';
  scriptPath = (toString (writeShellScript "home-fzf-theme.sh" scriptContent));
  cmdPath = (toString (lib.getExe dark-mode-notify));
in
{
  launchd.agents = {
    "fzf-theme-helper" = {
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
