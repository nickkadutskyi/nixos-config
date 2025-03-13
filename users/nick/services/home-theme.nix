{ config, pkgs, ... }:
with pkgs;
with builtins;
let
  tmuxPath = (toString (lib.getExe tmux));
  nvrPath = (toString (lib.getExe neovim-remote));
  scriptContent = # bash
    ''
      export TMUX NVR
      TMUX=${tmuxPath}
      NVR=${nvrPath}
      # Get current system theme
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")

      # Sets respective Tmux theme
      $TMUX source "$XDG_CONFIG_HOME/tmux/tmux-$SYSTEM_THEME.conf"

      # Sets respective FZF theme
      FZF_CONFIG=~/.config/fzf
      FZF_THEME=~/.config/fzf/fzfrc
      /bin/ln -sf "$FZF_CONFIG/$SYSTEM_THEME.fzfrc" "$FZF_THEME"

      # Sets respective Neovim theme in all Neovim instances
      (IFS=$'\n'
      for s in $($NVR --serverlist); do
          test ! -S "$s" && continue
          if [[ $s =~ "nvim" ]]; then
              $NVR --nostart --servername "$s" \
                   --remote-expr "execute('set background=$SYSTEM_THEME')"
          fi
      done)

      # Sets zsh-hist-sub theme
      ZSHHS_CONFIG=~/.config/zsh-hist-sub
      ZSHHS_THEME=~/.config/zsh-hist-sub/theme
      /bin/ln -sf "$ZSHHS_CONFIG/$SYSTEM_THEME" "$ZSHHS_THEME"

      # Sets zsh theme (currently for completion matches highlight)
      ZSH_CONFIG=~/.config/zsh-theme
      ZSH_THEME=~/.config/zsh-theme/theme
      /bin/ln -sf "$ZSH_CONFIG/$SYSTEM_THEME" "$ZSH_THEME"
    '';
  scriptPath = (toString (writeShellScript "home-theme.sh" scriptContent));
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
