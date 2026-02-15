{ pkgs, ... }:
pkgs.writeShellScriptBin "tizen"
  # bash
  ''
    # Check for Tizen Studio location based on platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
      TIZEN_PATH="$HOME/Tizen/tizen-studio/tools/ide/bin/tizen"
    elif [[ -d "/opt/tizen-studio" ]]; then
      TIZEN_PATH="/opt/tizen-studio/tools/ide/bin/tizen"
    elif [[ -d "$HOME/tizen-studio" ]]; then
      TIZEN_PATH="$HOME/tizen-studio/tools/ide/bin/tizen"
    else
      echo "Error: Could not locate Tizen Studio installation" >&2
      exit 1
    fi

    # Execute the binary if it exists
    if [[ -x "$TIZEN_PATH" ]]; then
      exec "$TIZEN_PATH" "$@"
    else
      echo "Error: tizen binary not found at $TIZEN_PATH" >&2
      exit 1
    fi
  ''
