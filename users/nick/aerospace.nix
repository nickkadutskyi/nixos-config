{
  config,
  pkgs,
  systemName,
  ...
}:
{
  # i3-like tiling window manager for macOS
  services.aerospace = {
    enable = true;
    settings =
      let
        defaultLayout = "accordion";
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
          alt-period = "layout floating tiling";
          alt-h = "focus --boundaries-action wrap-around-the-workspace left";
          alt-j = "focus --boundaries-action wrap-around-the-workspace down";
          alt-k = "focus --boundaries-action wrap-around-the-workspace up";
          alt-l = "focus --boundaries-action wrap-around-the-workspace right";
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-shift-ctrl-minus = "resize smart -50";
          alt-shift-ctrl-equal = "resize smart +50";
          alt-1 = "workspace T";
          alt-2 = "workspace W";
          alt-3 = "workspace C";
          alt-4 = "workspace M";
          alt-5 = "workspace J";
          alt-shift-1 = "move-node-to-workspace T";
          alt-shift-2 = "move-node-to-workspace W";
          alt-shift-3 = "move-node-to-workspace C";
          alt-shift-4 = "move-node-to-workspace M";
          alt-shift-5 = "move-node-to-workspace J";
          alt-shift-semicolon = "mode service";
          alt-enter = "fullscreen";
        };
        mode.service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            # P in Colemak keyboard layout
            "flatten-workspace-tree"
            "mode main"
          ]; # reset layout
          f = [
            # T in Colemak keyboard layout
            "layout floating tiling"
            "mode main"
          ]; # Toggle between floating and tiling layout
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
        };
        on-window-detected = [
          {
            "if" = {
              app-id = "com.apple.iCal"; # Calendar
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "com.clickup.desktop-app"; # ClickUp
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "com.jetbrains.datagrip"; # DataGrip
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace 1"
            ];
          }
          # Disabled for now because it tries to bring quick terminal to
          # T workspace as well which hides it and breaks the view
          # {
          #   "if" = {
          #     app-id = "com.mitchellh.ghostty"; # Ghostty
          #   };
          #   check-further-callbacks = true;
          #   run = [
          #     "layout floating"
          #     "move-node-to-workspace T"
          #   ];
          # }
          {
            "if" = {
              app-id = "pro.writer.mac"; # iA Writer
            };
            check-further-callbacks = true;
            run = [
              "layout floating"
              "move-node-to-workspace J"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.mail"; # Mail
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace C"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.MobileSMS"; # Messages
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace C"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.Safari"; # Safari
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace W"
            ];
          }
          {
            "if" = {
              app-id = "ru.keepcoder.Telegram"; # Telegram
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace C"
            ];
          }
          {
            "if" = {
              app-id = "com.upwork.Upwork"; # Upwork
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace C"
            ];
          }
        ];
      };
  };
}
