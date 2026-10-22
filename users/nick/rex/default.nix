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

  # Rex Beta 0.1.0 (1290) keeps appearance in UserDefaults, not init.lua.
  # These are app-private keys; recheck them when upgrading Rex.
  targets.darwin.defaults."com.superlogical.rex" = {
    "Workspace.appearance" = "system";
    "Workspace.paneDensity" = "comfortable";
    "Workspace.showsPaneHeaders" = true;
    "Workspace.hiddenPaneButtons" = [
      "close"
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
    # Ghostty uses the standard extended palette, not Rex's generated one.
    "Workspace.lightUsesExtendedThemePalette" = false;
    "Workspace.darkUsesExtendedThemePalette" = false;
  };
}
