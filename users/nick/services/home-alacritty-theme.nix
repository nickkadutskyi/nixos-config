{
  config,
  pkgs,
  alacritty,
  ...
}:
with pkgs;
with builtins;
let
  scriptContent = # bash
    ''
      THEMES_DIR="${alacritty}"
      ALACRITTY_THEME=~/.config/alacritty/alacritty_theme.toml
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")
      /bin/ln -sf "$THEMES_DIR/$SYSTEM_THEME.toml" "$ALACRITTY_THEME"
    '';
  scriptPath = (toString (writeShellScript "home-alacritty-theme.sh" scriptContent));
  cmdPath = (toString (lib.getExe dark-mode-notify));
in
{
  launchd.agents = {
    "alacritty-theme-helper" = {
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
