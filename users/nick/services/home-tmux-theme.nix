{ config, pkgs, ... }:
with pkgs;
with builtins;
let
  tmuxPath = (toString (lib.getExe tmux));
  scriptContent = # bash
    ''
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")
      [ $SYSTEM_THEME = "light" ] && BORDER_FG="#EBECF0" || BORDER_FG="#393B40"
      ${tmuxPath} set -g pane-border-style fg=$BORDER_FG
      ${tmuxPath} set -g pane-active-border-style fg=$BORDER_FG
    '';
  scriptPath = (toString (writeShellScript "home-tmux-theme.sh" scriptContent));
  cmdPath = (toString (lib.getExe dark-mode-notify));
in
{
  launchd.agents = {
    "tmux-theme-helper" = {
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
