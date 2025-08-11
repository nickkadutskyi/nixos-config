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
      $TMUX -L default source "$XDG_CONFIG_HOME/tmux/tmux-$SYSTEM_THEME.conf"

      # Sets respective FZF theme
      FZF_CONFIG=~/.config/fzf
      FZF_THEME=~/.config/fzf/fzfrc
      /bin/ln -sf "$FZF_CONFIG/$SYSTEM_THEME.fzfrc" "$FZF_THEME"

      # Sets zsh-hist-sub theme
      ZSHHS_CONFIG=~/.config/zsh
      ZSHHS_THEME=~/.config/zsh/zsh-hist-sub-theme
      /bin/ln -sf "$ZSHHS_CONFIG/zsh-hist-sub-$SYSTEM_THEME" "$ZSHHS_THEME"

      # Sets zsh theme (currently for completion matches highlight)
      ZSH_CONFIG=~/.config/zsh
      ZSH_THEME=~/.config/zsh/zsh-theme-theme
      /bin/ln -sf "$ZSH_CONFIG/zsh-theme-$SYSTEM_THEME" "$ZSH_THEME"

      # Sets grep theme
      GREP_CONFIG=~/.config/grep
      GREP_THEME=~/.config/grep/grep-theme
      /bin/ln -sf "$GREP_CONFIG/grep-colors-$SYSTEM_THEME" "$GREP_THEME"

      # Sets ripgrep theme
      RG_CONFIG=~/.config/ripgrep
      RG_THEME=~/.config/ripgrep/.ripgreprc
      /bin/ln -sf "$RG_CONFIG/.ripgreprc-$SYSTEM_THEME" "$RG_THEME"
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
          "/bin/wait4path ${cmdPath} && ${cmdPath} ${scriptPath}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}
