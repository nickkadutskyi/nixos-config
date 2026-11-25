{ pkgs, ... }:
# Builds the devenv shell of the project in the current directory and pushes
# its whole closure to the Attic cache, including paths built before
# `attic watch-store` was running. Expects the devenv flake at ./flake.nix or
# ./nix/flake.nix, entered with `use flake ... --impure` like the .envrc files.
# Uses `nix` from PATH and the attic login in ~/.config/attic.
pkgs.writeShellApplication {
  name = "attic-push-devenv";
  runtimeInputs = [
    pkgs.attic-client
    pkgs.gnugrep
  ];
  text = ''
    cache="''${ATTIC_CACHE:-nick-main}"

    flakedir=""
    for dir in "$PWD" "$PWD/nix"; do
      if [ -f "$dir/flake.nix" ] && grep -q devenv "$dir/flake.nix"; then
        flakedir=$dir
        break
      fi
    done
    if [ -z "$flakedir" ]; then
      echo "attic-push-devenv: no devenv flake.nix in $PWD or $PWD/nix" >&2
      exit 1
    fi

    # The profile keeps the shell from being garbage collected.
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/attic-push-devenv"
    mkdir -p "$state"
    profile="$state/$(basename "$PWD")"

    echo "==> $(basename "$PWD")"
    # devenv takes DEVENV_ROOT from the directory it is evaluated in.
    nix print-dev-env --impure --profile "$profile" "path:$flakedir" >/dev/null
    attic push "$cache" "$profile"
  '';
}
