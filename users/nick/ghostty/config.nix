{ isDarwin, ... }:
# ini
''

  ${
    if isDarwin then
      # ini
      ''
        font-family = "TX-02"
        # As fallback
        font-family = "Symbols Nerd Font"
        font-size = 14
        adjust-underline-position = 2
        adjust-underline-thickness = -1
        font-feature = +ss01
      ''
    else
      # ini
      ''
        # font-family = "JetBrainsMonoNL Nerd Font"
        font-size = 13
        adjust-underline-position = -1
      ''
  }

  font-feature = -calt

  font-synthetic-style =

  theme = light:jb-light,dark:jb-dark
  macos-option-as-alt = left
  adjust-cell-height = 25%
  # Required for Neovim to not being covered by vertical lines
  adjust-cursor-thickness = 2
  window-padding-balance = true
  keybind = global:cmd+ctrl+t=toggle_quick_terminal
  keybind = super+shift+j=write_screen_file:paste
  keybind = super+alt+shift+j=write_screen_file:open
  mouse-hide-while-typing = true
  macos-non-native-fullscreen = visible-menu
  background-opacity = 0.9
  background-blur-radius = 20
  cursor-style = bar
  # disables title to allow zsh plugin to work properly
  shell-integration-features = cursor,no-sudo,no-title
  # window-inherit-working-directory = false

''
