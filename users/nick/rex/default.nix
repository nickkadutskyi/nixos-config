{ config, lib, ... }:
{
  xdg.configFile = {
    "rex/init.lua".text =
      lib.replaceStrings
        [ ''"@themeDirectory@"'' ]
        [
          (builtins.toJSON "${config.xdg.configHome}/rex/themes")
        ]
        (builtins.readFile ./init.lua);
    "rex/themes" = {
      # Rex imports Ghostty themes directly; keep one source of truth.
      source = ../ghostty/themes;
      recursive = true;
    };
  };

  # Rex Beta 0.1.0 (1940) keeps appearance in UserDefaults, not init.lua.
  # These are app-private keys; recheck them when upgrading Rex. Only values
  # that differ from Rex's built-in defaults are listed.
  targets.darwin.defaults."com.superlogical.rex" = {
    # Preserve the enabled experimental features from Rex's local preferences.
    "rex.developer-mode-enabled" = true;
    "Workspace.experiments.terminalGridAnchor" = "bottom";
    "Workspace.experiments.usesNewQuickSwitcher" = true;
    "Workspace.cursorShadersEnabled" = true;

    "Workspace.animationStyle" = "natural";
    "Workspace.interfaceStyle" = "blendTheme";
    "Workspace.toolbarBehavior" = "alwaysShow";
    "Workspace.usesPaneGlass" = true;
    "Workspace.tintsPanesWithProgramBackground" = false;
    "Workspace.showsActivePaneBorder" = true;
    "Workspace.activePaneBorderOpacity" = 0.39965533088235294;
    "Workspace.hiddenPaneButtons" = [
      "splitDown"
      "splitRight"
      "zoom"
    ];
    "Workspace.hiddenChromeButtons" = [ "commandPalette" ];
    "Workspace.tabsFillAvailableSpace" = true;
    "Workspace.tabIconColorMode" = "activeTabs";
    "Workspace.prefersGeneratedTitles" = false;
    "Workspace.terminalFontName" = "TX-02";
    "Workspace.terminalFontStyle" = "Retina";
    "Workspace.terminalFallbackFontNames" = [ "Symbols Nerd Font" ];
    "Workspace.terminalFontPointSize" = 14.0;
    "Workspace.terminalCellHeightPercent" = 30.0;
    "Workspace.terminalAllowsLigatures" = false;
    "Workspace.terminalImproveTextContrast" = false;
    "Workspace.terminalCursorStyle" = "bar";
    "Workspace.terminalOptionKeyBehavior" = "leftActsAsAlt";
    "Workspace.terminalPaddingX" = 7.0;
    "Workspace.terminalPaddingY" = 7.0;
    # Ghostty uses the standard extended palette, not Rex's generated one.
    "Workspace.lightUsesExtendedThemePalette" = false;
    "Workspace.darkUsesExtendedThemePalette" = false;

    "rex.server.web-client-origin-patterns" = [ "https://rex.superlogical.com" ];
    # Defaults for these two could not be confirmed; keep the chosen values.
    "rex.client.remoteControl" = true;
    "RexAppUpdateAutomation" = "install";
  };
}
