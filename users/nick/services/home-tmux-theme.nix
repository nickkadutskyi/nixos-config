{ config, pkgs, ... }:
with pkgs;
with builtins;
let
  tmuxPath = (toString (lib.getExe tmux));
  scriptContent = # bash
    ''
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")
      [ $SYSTEM_THEME = "light" ] && BORDER_FG="#EBECF0" || BORDER_FG="#393B40"
      ${tmuxPath} source $XDG_CONFIG_HOME/tmux/tmux-''${SYSTEM_THEME}.conf
    '';
  scriptPath = (toString (writeShellScript "home-tmux-theme.sh" scriptContent));
  cmdPath = (toString (lib.getExe dark-mode-notify));
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  launchd.agents = {
    "tmux-theme-helper" = {
      enable = isDarwin;
      config = {
        ProgramArguments = [
          "/bin/zsh"
          "-c"
          "/bin/wait4path ${cmdPath} &amp;&amp; ${cmdPath} ${scriptPath}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}
