{
  config,
  pkgs,
  currentSystemName,
  ...
}:
{
  # i3-like tiling window manager for macOS
  services.aerospace = {
    enable = true;
    settings =
      let
        defaultLayout = if currentSystemName == "Nicks-MacBook-Air" then "accordion" else "tiles";
      in
      {
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        default-root-container-layout = "${defaultLayout}";
        accordion-padding = 0;
        after-startup-command = [ "layout ${defaultLayout}" ];
        gaps = {
          inner.horizontal = 1;
          inner.vertical = 1;
          outer.left = 0;
          outer.bottom = 0;
          outer.top = 0;
          outer.right = 0;
        };
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";
          alt-h = "focus --boundaries-action wrap-around-the-workspace left";
          alt-j = "focus --boundaries-action wrap-around-the-workspace down";
          alt-k = "focus --boundaries-action wrap-around-the-workspace up";
          alt-l = "focus --boundaries-action wrap-around-the-workspace right";
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-shift-minus = "resize smart -50";
          alt-shift-equal = "resize smart +50";
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-semicolon = "mode service";
          alt-enter = "fullscreen";
        };
        mode.service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [ # P in Colemak keyboard layout
            "flatten-workspace-tree"
            "mode main"
          ]; # reset layout
          f = [ # T in Colemak keyboard layout
            "layout floating tiling"
            "mode main"
          ]; # Toggle between floating and tiling layout
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
        };
        key-mapping.key-notation-to-key-code = {
          # q = "q";
          # w = "w";
          # f = "e";
          # p = "r";
          # g = "t";
          # j = "y";
          # l = "u";
          # u = "i";
          # y = "o";
          # semicolon = "p";
          # leftSquareBracket = "leftSquareBracket";
          # rightSquareBracket = "rightSquareBracket";
          # backslash = "backslash";

          # a = "a";
          # r = "s";
          # s = "d";
          # t = "f";
          # d = "g";
          # h = "h";
          # n = "j";
          # e = "k";
          # i = "l";
          # o = "semicolon";
          # quote = "quote";

          # z = "z";
          # x = "x";
          # c = "c";
          # v = "v";
          # b = "b";
          # k = "n";
          # m = "m";
          # comma = "comma";
          # period = "period";
          # slash = "slash";
        };
      };
  };
}
