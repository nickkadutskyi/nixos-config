{ pkgs, ... }:
# Pushes every valid path in this machine's Nix store to the Attic cache, for
# paths that `attic watch-store` never saw, such as ones built before it ran
# or after the cache was cleared. Paths already cached or signed by
# cache.nixos.org are skipped. Logs to $XDG_STATE_HOME/attic-backfill.log.
# Uses `nix` from PATH and the attic login in ~/.config/attic.
pkgs.writeShellApplication {
  name = "attic-backfill";
  runtimeInputs = [
    pkgs.attic-client
    pkgs.coreutils
    pkgs.gnugrep
  ];
  text = ''
    cache="''${ATTIC_CACHE:-nick-main}"
    state="''${XDG_STATE_HOME:-$HOME/.local/state}"
    log="$state/attic-backfill.log"
    mkdir -p "$state"
    paths=$(mktemp)
    trap 'rm -f "$paths"' EXIT

    {
      echo "== $(uname -n) $(date)"
      nix path-info --all | grep -v '\.drv$' > "$paths"
      echo "$(wc -l < "$paths") paths"
      time attic push "$cache" --stdin --no-closure < "$paths"
      echo "== done $(date)"
    } 2>&1 | tee "$log"
  '';
}
