{ pkgs, ... }:
pkgs.writeShellScriptBin "sdb"
  # bash
  ''
    # Check for Tizen Studio location based on platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
      TIZEN_PATH="$HOME/Tizen/tizen-studio/tools/sdb"
    elif [[ -d "/opt/tizen-studio" ]]; then
      TIZEN_PATH="/opt/tizen-studio/tools/sdb"
    elif [[ -d "$HOME/tizen-studio" ]]; then
      TIZEN_PATH="$HOME/tizen-studio/tools/sdb"
    else
      echo "Error: Could not locate Tizen Studio installation" >&2
      exit 1
    fi

    # Execute the binary if it exists
    if [[ -x "$TIZEN_PATH" ]]; then
      exec "$TIZEN_PATH" "$@"
    else
      echo "Error: sdb binary not found at $TIZEN_PATH" >&2
      exit 1
    fi
  ''
