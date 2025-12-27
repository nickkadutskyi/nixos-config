{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.targets.darwin.services.tool-theme;

  # Helper function to check if a file exists or is managed by home-manager
  fileExistsOrManaged =
    path:
    let
      homeDir = config.home.homeDirectory;
      # Convert relative path to absolute
      absPath = if lib.hasPrefix "/" path then path else "${homeDir}/${path}";
      # Check if file is managed by home-manager via xdg.configFile or home.file
      managedViaXdgConfig = config.xdg.configFile ? ${lib.removePrefix "${config.xdg.configHome}/" absPath};
      managedViaHomeFile = config.home.file ? ${lib.removePrefix "${homeDir}/" absPath};
    in
    {
      inherit absPath;
      exists = builtins.pathExists absPath;
      managed = managedViaXdgConfig || managedViaHomeFile;
    };

  # Helper function to validate tool configuration
  validateToolConfig =
    toolName: toolCfg:
    let
      lightCheck = fileExistsOrManaged toolCfg.lightThemePath;
      darkCheck = fileExistsOrManaged toolCfg.darkThemePath;
    in
    {
      inherit toolName;
      valid = (lightCheck.exists || lightCheck.managed) && (darkCheck.exists || darkCheck.managed);
      lightTheme = lightCheck;
      darkTheme = darkCheck;
    };

  # Generate warnings for invalid configurations
  generateWarnings =
    let
      toolValidations = mapAttrsToList (name: value: validateToolConfig name value) cfg.tools;
      invalidTools = filter (v: !v.valid) toolValidations;
      makeWarning =
        v:
        let
          missingFiles =
            [ ]
            ++ optional (!v.lightTheme.exists && !v.lightTheme.managed) "light theme (${v.lightTheme.absPath})"
            ++ optional (!v.darkTheme.exists && !v.darkTheme.managed) "dark theme (${v.darkTheme.absPath})";
        in
        "tool-theme: ${v.toolName} theme switching disabled - missing files: ${concatStringsSep ", " missingFiles}";
    in
    map makeWarning invalidTools;

  # Filter only valid tools for script generation
  validTools =
    let
      toolValidations = mapAttrsToList (name: value: validateToolConfig name value) cfg.tools;
    in
    filter (v: v.valid) toolValidations;

  # Generate theme switching script content
  scriptContent =
    let
      homeDir = config.home.homeDirectory;

      # Helper to convert relative paths to absolute
      toAbsPath = path: if lib.hasPrefix "/" path then path else "${homeDir}/${path}";

      # Generate switching logic for each valid tool
      generateToolSwitch =
        v:
        let
          toolCfg = cfg.tools.${v.toolName};
          mainPath = toAbsPath toolCfg.mainConfigPath;
          lightPath = toAbsPath toolCfg.lightThemePath;
          darkPath = toAbsPath toolCfg.darkThemePath;
        in
        ''
          # Sets ${v.toolName} theme
          if [ "$SYSTEM_THEME" = "dark" ]; then
            /bin/ln -sf "${darkPath}" "${mainPath}"
          else
            /bin/ln -sf "${lightPath}" "${mainPath}"
          fi
        ''
        + optionalString (toolCfg.onSwitch != null) ''
          ${toolCfg.onSwitch}
        '';

      toolSwitches = concatMapStringsSep "\n" generateToolSwitch validTools;
    in
    # bash
    ''
      # Get current system theme
      SYSTEM_THEME=$([ "$DARKMODE" = "1" ] && echo "dark" || echo "light")

      ${toolSwitches}
    '';

  scriptPath = toString (pkgs.writeShellScript "tool-theme.sh" scriptContent);
  cmdPath = toString (lib.getExe pkgs.dark-mode-notify);
in
{
  options.targets.darwin.services.tool-theme = {
    enable = mkEnableOption "automatic theme switching for configured tools based on macOS appearance";

    tools = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            mainConfigPath = mkOption {
              type = types.str;
              description = "Path to the main config file (relative to home directory or absolute). This will be symlinked to either light or dark theme.";
              example = ".config/fzf/fzfrc";
            };

            lightThemePath = mkOption {
              type = types.str;
              description = "Path to the light theme file (relative to home directory or absolute).";
              example = ".config/fzf/light.fzfrc";
            };

            darkThemePath = mkOption {
              type = types.str;
              description = "Path to the dark theme file (relative to home directory or absolute).";
              example = ".config/fzf/dark.fzfrc";
            };

            onSwitch = mkOption {
              type = types.nullOr types.lines;
              default = null;
              description = "Optional shell commands to run after switching themes for this tool.";
              example = ''
                # Reload tool configuration
                killall -USR1 mytool
              '';
            };
          };
        }
      );
      default = {
        tmux = {
          mainConfigPath = "${config.xdg.configHome}/tmux/tmux-theme.conf";
          lightThemePath = "${config.xdg.configHome}/tmux/tmux-light.conf";
          darkThemePath = "${config.xdg.configHome}/tmux/tmux-dark.conf";
          onSwitch = ''
            ${lib.getExe pkgs.tmux} -L default source "${config.targets.darwin.services.tool-theme.tools.tmux.mainConfigPath}" 2>/dev/null || true
          '';
        };
        fzf = {
          mainConfigPath = "${config.xdg.configHome}/fzf/fzfrc";
          lightThemePath = "${config.xdg.configHome}/fzf/light.fzfrc";
          darkThemePath = "${config.xdg.configHome}/fzf/dark.fzfrc";
        };
        zsh-hist-sub = {
          mainConfigPath = "${config.xdg.configHome}/zsh/zsh-hist-sub-theme";
          lightThemePath = "${config.xdg.configHome}/zsh/zsh-hist-sub-light";
          darkThemePath = "${config.xdg.configHome}/zsh/zsh-hist-sub-dark";
        };
        zsh-theme = {
          mainConfigPath = "${config.xdg.configHome}/zsh/zsh-theme-theme";
          lightThemePath = "${config.xdg.configHome}/zsh/zsh-theme-light";
          darkThemePath = "${config.xdg.configHome}/zsh/zsh-theme-dark";
        };
        grep = {
          mainConfigPath = "${config.xdg.configHome}/grep/grep-theme";
          lightThemePath = "${config.xdg.configHome}/grep/grep-colors-light";
          darkThemePath = "${config.xdg.configHome}/grep/grep-colors-dark";
        };
        ripgrep = {
          mainConfigPath = "${config.xdg.configHome}/ripgrep/.ripgreprc";
          lightThemePath = "${config.xdg.configHome}/ripgrep/.ripgreprc-light";
          darkThemePath = "${config.xdg.configHome}/ripgrep/.ripgreprc-dark";
        };
      };
      description = "Configuration for tools that should have automatic theme switching.";
      example = literalExpression ''
        {
          fzf = {
            mainConfigPath = ".config/fzf/fzfrc";
            lightThemePath = ".config/fzf/light.fzfrc";
            darkThemePath = ".config/fzf/dark.fzfrc";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    warnings = generateWarnings;
    assertions = [
      (lib.hm.assertions.assertPlatform "targets.darwin.tool-theme" pkgs lib.platforms.darwin)
    ];

    launchd.agents.tool-theme-helper = mkIf (validTools != [ ]) {
      enable = true;
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
