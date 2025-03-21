{
  inputs,
  config,
  pkgs,
  systemName,
  ...
}:
let
  pkgs-master = inputs.nixpkgs-master.legacyPackages.${pkgs.system};
in
{
  # i3-like tiling window manager for macOS
  services.aerospace = {
    # Disabled to try FlashSpace instead
    enable = false;
    package = pkgs-master.aerospace;
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
        mode.main.binding =
          let
            switcher = (
              toString (
                pkgs.writeShellScript "aerospace-switcher.sh"
                  # bash
                  ''
                    AS=${pkgs-master.aerospace}/bin/aerospace
                    XA=${pkgs.findutils}/bin/xargs
                    APP_FOCUSED=($($AS list-windows --focused --format "%{app-name}%{newline}%{window-id}"))
                    WORKSPACE_ID=$1
                    declare -a APPS=("Ghostty" "Finder" "IntelliJ IDEA")
                    if [[ " ''${APPS[@]} " =~ " ''${APP_FOCUSED[1]} " ]]; then
                      $AS list-windows --all --format "%{window-id}" |
                        $XA -I _ $AS move-node-to-workspace $WORKSPACE_ID --window-id _
                      $AS focus --window-id ''${APP_FOCUSED[2]}
                    else
                      $AS move-node-to-workspace $WORKSPACE_ID
                      $AS workspace $WORKSPACE_ID
                    fi
                  ''
              )
            );
          in
          {
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
            alt-1 = "workspace C";
            alt-2 = "workspace W";
            alt-3 = "workspace S";
            alt-4 = "workspace M";
            alt-5 = "workspace P";
            alt-shift-1 = [
              "exec-and-forget ${switcher} C"
            ];
            alt-shift-2 = [
              "exec-and-forget ${switcher} W"
            ];
            alt-shift-3 = [
              "exec-and-forget ${switcher} S"
            ];
            alt-shift-4 = [
              "exec-and-forget ${switcher} M"
            ];
            alt-shift-5 = [
              "exec-and-forget ${switcher} P"
            ];
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

          # ----------------------------------------------------------------
          # [C]oding workspace
          # ----------------------------------------------------------------
          {
            "if" = {
              app-id = "com.mitchellh.ghostty";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace C"
            ];
          }
          {
            "if" = {
              app-id = "com.jetbrains.intellij";
            };
            check-further-callbacks = true;
            run = [
              "layout floating"
              "move-node-to-workspace C"
            ];
          }

          # ----------------------------------------------------------------
          # [W]eb workspace
          # ----------------------------------------------------------------
          {
            "if" = {
              app-id = "com.apple.Safari"; # Safari
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace W"
            ];
          }

          # ----------------------------------------------------------------
          # [S]ervices workspace
          # ----------------------------------------------------------------
          {
            "if" = {
              app-id = "com.google.Chrome";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-id = "com.jetbrains.datagrip"; # DataGrip
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.ActivityMonitor";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-id = "org.tizen.sdk.ide";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-id = "org.tizen.cert.ide";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-name-regex-substring = "device-manager";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }
          {
            "if" = {
              app-id = "com.panic.Transmit";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace S"
            ];
          }

          # ----------------------------------------------------------------
          # [M]anagement and communication workspace
          # ----------------------------------------------------------------
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
              app-id = "com.apple.mail"; # Mail
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.MobileSMS"; # Messages
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.reminders";
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "ru.keepcoder.Telegram"; # Telegram
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }
          {
            "if" = {
              app-id = "com.upwork.Upwork"; # Upwork
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace M"
            ];
          }

          # ----------------------------------------------------------------
          # [P]ersonal workspace
          # ----------------------------------------------------------------
          {
            "if" = {
              app-id = "pro.writer.mac"; # iA Writer
            };
            check-further-callbacks = true;
            run = [
              "layout floating"
              "move-node-to-workspace P"
            ];
          }
          {
            "if" = {
              app-id = "com.reederapp.5.macOS"; # Reeder
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace P"
            ];
          }
          {
            "if" = {
              app-id = "com.apple.Notes"; # Notes
            };
            check-further-callbacks = true;
            run = [
              "move-node-to-workspace P"
            ];
          }
        ];
      };
  };
}
