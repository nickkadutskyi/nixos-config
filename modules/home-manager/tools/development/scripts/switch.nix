{ pkgs, ... }:
# Switches this Mac to nixos-config-private, run as `sudo switch`. When the
# local nixos-config checkout has uncommitted or unpushed changes, it overrides
# the GitHub version pinned in the private flake.lock with the checkout.
# Both checkouts are looked up in the project directories from project-roots.nix.
pkgs.writeShellScriptBin "switch"
  # bash
  ''
    set -e

    USERHOME=''${USERHOME:-$HOME}

    # sudo keeps the caller's HOME, which Nix refuses to use as root ("$HOME is
    # not owned by you"). The checkouts are found through USERHOME, so only Nix
    # and git see root's home.
    if [ "$(id -u)" -eq 0 ]; then
      export HOME=~root
    fi

    PROJECT_ROOTS=(${pkgs.lib.escapeShellArgs (import ./project-roots.nix)})

    # Prints the first $USERHOME/<root>/<name> that exists.
    find_checkout() {
      local root
      for root in "''${PROJECT_ROOTS[@]}"; do
        if [ -d "$USERHOME/$root/$1" ]; then
          echo "$USERHOME/$root/$1"
          return
        fi
      done
    }

    NIXOS_CONFIG_LOCAL=$(find_checkout nixos-config)
    NIXOS_CONFIG_PRIVATE=$(find_checkout nixos-config-private)

    if [ -z "$NIXOS_CONFIG_PRIVATE" ]; then
      echo "switch: nixos-config-private not found in ~/{''${PROJECT_ROOTS[*]}}" >&2
      exit 1
    fi

    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    # Function to run switch with override
    run_with_override() {
      local reason="$1"
      echo -e "''${RED}Using local nixos-config override: ''${reason}''${NC}"
      nix run nix-darwin -- switch --flake "$NIXOS_CONFIG_PRIVATE" \
        --override-input nixos-config "git+file://$NIXOS_CONFIG_LOCAL"
    }

    # Function to run switch without override
    run_without_override() {
      nix run nix-darwin -- switch --flake "$NIXOS_CONFIG_PRIVATE"
    }

    # Check if local nixos-config exists
    if [ -z "$NIXOS_CONFIG_LOCAL" ] || [ ! -d "$NIXOS_CONFIG_LOCAL/.git" ]; then
      # Local repo doesn't exist, run without override
      run_without_override
      exit 0
    fi

    cd "$NIXOS_CONFIG_LOCAL"

    # 1. Check for uncommitted changes (dirty working tree)
    # Check both staged and unstaged changes, ignoring detached HEAD state
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      run_with_override "repository has uncommitted changes"
      exit 0
    fi

    # 2. Check for unpushed commits
    # First check if we're in detached HEAD state (common with jujutsu)
    if ! git symbolic-ref -q HEAD >/dev/null 2>&1; then
      # In detached HEAD state, switch to main branch
      git checkout main >/dev/null 2>&1 || git checkout master >/dev/null 2>&1 || true
    fi

    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

    if [ -n "$REMOTE_BRANCH" ]; then
      REMOTE_COMMIT=$(git rev-parse "$REMOTE_BRANCH" 2>/dev/null || echo "")
      if [ -n "$REMOTE_COMMIT" ] && [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        # Check if local is ahead of remote
        if git merge-base --is-ancestor "$REMOTE_COMMIT" "$LOCAL_COMMIT" 2>/dev/null; then
          run_with_override "repository has unpushed commits"
          exit 0
        fi
      fi
    fi

    # 3. Check if HEAD differs from lock file commit
    LOCK_FILE="$NIXOS_CONFIG_PRIVATE/flake.lock"
    if [ -f "$LOCK_FILE" ]; then
      # Extract the nixos-config commit from lock file
      LOCK_COMMIT=$(nix eval --raw --impure --expr "
        let
          lockFile = builtins.fromJSON (builtins.readFile \"$LOCK_FILE\");
          nixosConfigNode = lockFile.nodes.nixos-config or null;
        in
          if nixosConfigNode != null && nixosConfigNode ? locked && nixosConfigNode.locked ? rev
          then nixosConfigNode.locked.rev
          else \"\"
      " 2>/dev/null || echo "")

      if [ -n "$LOCK_COMMIT" ] && [ "$LOCAL_COMMIT" != "$LOCK_COMMIT" ]; then
        echo -e "''${YELLOW}Warning: Local nixos-config HEAD ($LOCAL_COMMIT) differs from lock file ($LOCK_COMMIT)''${NC}"
        echo -e "''${YELLOW}Running without override - will use GitHub version from lock file''${NC}"
      fi
    fi

    # 4. Repository is clean and up to date (or lock file check failed/matched)
    run_without_override
  ''
