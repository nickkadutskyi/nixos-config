{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  tmuxIntegration = pkgs.writeShellScriptBin "alacritty-tmux-integration" import ./scripts.sh;
in
{
  general = {
    # If ~/.alacritty_theme.toml exists (handled  by LaunchAgent on macOS),
    # it will import light.toml or dark.toml and overwrite first import
    import = [
      ./light.toml
      "~/.config/alacritty_theme.toml"
    ];
  };
  window = {
    padding = {
      x = 1;
      y = 1;
    };
    # Even padding
    dynamic_padding = true;
    decorations = "Full";
    startup_mode = "Windowed";
    dynamic_title = true;
    decorations_theme_variant = "None";
    resize_increments = false;
    # Left for <A-..> bindings in Neovim, Right for special characters
    option_as_alt = "OnlyLeft";
  };
  scrolling = {
    history = 100000;
    multiplier = 3;
  };
  font = {
    normal = {
      family = "JetBrainsMono Nerd Font";
      style = "Regular";
    };
    size = 13;
    offset = {
      x = 1;
      y = 9;
    };
    glyph_offset = {
      x = 0;
      y = 4;
    };
    builtin_box_drawing = true;
  };
  bell = {
    duration = 100;
    animation = "EaseOutExpo";
    command = lib.mkIf isDarwin {
      program = "osascript";
      args = [
        "-e"
        "beep"
      ];
    };
  };
  selection.save_to_clipboard = false;
  cursor = {
    style = {
      shape = "Block";
      blinking = "Always";
    };
    blink_interval = 500;
    blink_timeout = 60;
    unfocused_hollow = true;
    thickness = 0.2;
  };
  terminal = {
    shell = {
      # Always open a shell in the home directory
      program = "/bin/zsh";
      args = [
        "-c"
        "cd ~; zsh"
      ];
    };
  };
  mouse = {
    hide_when_typing = false;
    bindings = [
      {
        mouse = "Left";
        mods = "Shift";
        action = "ExpandSelection";
      }
    ];
  };

  keyboard = {
    bindings = [
      # Simple Tmux integration for persistent shells
      # Opens a new tab (window) with persistent shell handled by tmux
      {
        key = "P";
        mods = "Command";
        command = {
          program = "/bin/zsh";
          args = [
            "-c"
            "${./scripts.sh} new-window"
          ];
        };
      }
      # Reattach to all tmux session in alacritty group while creating Alacritty
      # window for each tmux session
      {
        key = "G";
        mods = "Command";
        command = {
          program = "/bin/zsh";
          args = [
            "-c"
            "${./scripts.sh} reattach-all"
          ];
        };
      }
      # Prompts user to select a tmux session to attach to in a new tab
      {
        key = "T";
        mods = "Command|Alt";
        command = {
          program = "/bin/zsh";
          args = [
            "-c"
            "${./scripts.sh} init-select-pane"
          ];
        };
      }

      # Tmux universal key bindings
      # `⌘ + ⌥ + w` to close the pane (sends `Ctrl+B x`)
      {
        key = "W";
        mods = "Command|Alt";
        chars = "\u0002x";
      }
      # `⌘ + ⌥  + arrows` are for directional navigation around the panes
      # move down a pane
      {
        key = "Down";
        mods = "Command|Alt";
        chars = "\u0002\u001b[B";
      }
      {
        key = "j";
        mods = "Command|Alt";
        chars = "\u0002\u001b[B";
      }
      # move up a pane
      {
        key = "Up";
        mods = "Command|Alt";
        chars = "\u0002\u001b[A";
      }
      {
        key = "k";
        mods = "Command|Alt";
        chars = "\u0002\u001b[A";
      }
      # move left a pane
      {
        key = "Left";
        mods = "Command|Alt";
        chars = "\u0002\u001b[D";
      }
      {
        key = "h";
        mods = "Command|Alt";
        chars = "\u0002\u001b[D";
      }
      # move right a pane
      {
        key = "Right";
        mods = "Command|Alt";
        chars = "\u0002\u001b[C";
      }
      {
        key = "l";
        mods = "Command|Alt";
        chars = "\u0002\u001b[C";
      }
      # ⌘ + d adds a pane to the right (splits window vertically)
      {
        key = "D";
        mods = "Command";
        chars = "\u0002%";
      }
      # ⌘ + ⇧ + d adds a pane below (splits window horizontally)
      {
        key = "D";
        mods = "Command|Shift";
        chars = "\u0002\"";
      }

      # Convenience
      {
        key = "Escape";
        mods = "Shift";
        action = "ToggleViMode";
      }
      # ⌘ + enter puts window in macOS full screen
      {
        key = "Enter";
        mods = "Command";
        action = "ToggleFullscreen";
      }
      # ⌥ + → and ← move between words
      {
        key = "Right";
        mods = "Alt";
        chars = "\u001BF";
      }
      {
        key = "Left";
        mods = "Alt";
        chars = "\u001BB";
      }
    ];
  };
}
