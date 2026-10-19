# Rex Beta

Imported by `../darwin.nix`. Home Manager installs `rex/init.lua` and
`rex/themes/{jb-light,jb-dark}` under its XDG config directory and sets the
supported macOS appearance preferences. Ghostty remains configured separately.
Rex accepts Ghostty theme files, so both apps share `../ghostty/themes` rather
than maintaining duplicate palettes.

## Apply

Install Rex Beta separately. Quit the app before your usual Darwin rebuild so
it reads the new preferences on launch. After reopening, run in a Rex terminal:

```sh
rex config check
rex config reload
rex do import_jb_themes
```

The last command imports and selects both themes through Rex's own importer.
Run it once per Mac and again after changing theme colors; Rex copies imports
into its preferences rather than watching the source files. Existing custom
themes are not replaced by Home Manager. Rex may create another imported theme
when this command is repeated. Appearance follows the system.

`Cmd+Shift+J` writes the current terminal screen and scrollback to a temporary
text file and pastes its shell-quoted path. `Cmd+Option+Shift+J` opens that file
with the default macOS app. These actions require a local macOS Rex server;
files remain in its temporary directory for subsequent use.

## Conversion limits

The public Lua API does not configure typography or persistent client themes.
The `Workspace.*` preferences in `default.nix` were identified in installed Rex
Beta 0.1.0 (1290); they are private, version-dependent settings, not a documented
Lua API. `rex config check` validates Lua only, not those preferences.

- TX-02 Retina, 14 pt, Symbols Nerd Font fallback, +30% cell height, disabled
  ligatures, a bar cursor (applications may override it), and left Option as Alt
  are mapped to the corresponding Rex preferences.
- Rex's ligature toggle approximates `font-feature = -calt`. No verified setting
  was found for `+ss01`, a separate bold face, disabling synthetic styles,
  underline offsets/thickness, or cursor thickness.
- No exact mapping was found for `minimum-contrast = 1.1`, balanced 6 px padding,
  Ghostty's bell features, mouse hiding, padded-notch fullscreen, titlebar style,
  or the shell-integration feature list. Rex retains its own behavior for these.
- No equivalent global quick-terminal action was found; `Cmd+Ctrl+T` and the
  bottom-position/zero-animation settings are not mapped to a different action.
- Ghostty's update channel and auto-download settings are not applied to Rex.

References: [configuration](https://www.superlogical.com/rex/docs/customize/config),
[Lua API](https://www.superlogical.com/rex/docs/reference/lua).
