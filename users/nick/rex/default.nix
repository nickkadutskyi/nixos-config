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

  # Rex Beta 0.1.0 (1851) keeps appearance in UserDefaults, not init.lua.
  # These are app-private keys; recheck them when upgrading Rex.
  targets.darwin.defaults."com.superlogical.rex" = {
    # Preserve the enabled experimental features from Rex's local preferences.
    "rex.developer-mode-enabled" = true;
    "Workspace.experiments.terminalGridAnchor" = "bottom";
    "Workspace.experiments.usesNewQuickSwitcher" = true;
    "Workspace.cursorShadersEnabled" = true;
    "Workspace.smoothResizeEnabled" = true;

    "Workspace.appearance" = "system";
    "Workspace.interfaceStyle" = "blendTheme";
    "Workspace.toolbarBehavior" = "onHover";
    "Workspace.paneDensity" = "comfortable";
    "Workspace.usesPaneGlass" = true;
    "Workspace.tintsPanesWithProgramBackground" = true;
    "Workspace.balancesSplitsOnCreation" = true;
    "Workspace.inactivePaneFadeMode" = "both";
    "Workspace.usesStandardInactiveWindowPaneStyles" = true;
    "Workspace.showsActivePaneBorder" = true;
    "Workspace.activePaneBorderColor" = "accent";
    "Workspace.activePaneBorderOpacity" = 0.39965533088235294;
    "Workspace.showsPaneHeaders" = true;
    "Workspace.hiddenPaneButtons" = [
      "splitDown"
      "splitRight"
      "zoom"
    ];
    "Workspace.terminalFontName" = "TX-02";
    "Workspace.terminalFontStyle" = "Retina";
    "Workspace.terminalFallbackFontNames" = [ "Symbols Nerd Font" ];
    "Workspace.terminalFontPointSize" = 14.0;
    "Workspace.terminalCellHeightPercent" = 30.0;
    "Workspace.terminalAllowsLigatures" = false;
    "Workspace.terminalImproveTextContrast" = false;
    "Workspace.terminalCursorStyle" = "bar";
    "Workspace.terminalCursorStyleForced" = false;
    "Workspace.terminalOptionKeyBehavior" = "leftActsAsAlt";
    "Workspace.terminalPaddingColor" = "background";
    "Workspace.terminalPaddingX" = 7.0;
    "Workspace.terminalPaddingY" = 7.0;
    # Ghostty uses the standard extended palette, not Rex's generated one.
    "Workspace.lightUsesExtendedThemePalette" = false;
    "Workspace.darkUsesExtendedThemePalette" = false;
  };
}
