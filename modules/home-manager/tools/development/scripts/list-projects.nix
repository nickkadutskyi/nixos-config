{ pkgs, ... }:
# Prints the path of every project, one per line. Used by select-project
# (prd, prot) and by the attic-push-devenv launchd agent on the Mac mini.
pkgs.writeShellScriptBin "list-projects"
  # bash
  ''
    FD=${pkgs.fd}/bin/fd

    shopt -s nullglob

    PROJECT_MARKERS=(
      # VCS
      .git .jj .hg .svn
      # Editors
      .idea .vscode .zed .editorconfig
      # JS / TS
      package.json tsconfig.json jsconfig.json deno.json deno.jsonc
      # PHP
      composer.json
      # Rust
      Cargo.toml
      # Zig
      build.zig build.zig.zon
      # Go
      go.mod go.work
      # Python
      pyproject.toml setup.py setup.cfg requirements.txt Pipfile
      # Other build systems
      Gemfile pom.xml build.gradle build.gradle.kts CMakeLists.txt Makefile
      flake.nix shell.nix default.nix
    )

    has_marker() {
      local marker
      for marker in "''${PROJECT_MARKERS[@]}"; do
        [[ -e "$1/$marker" ]] && return 0
      done
      return 1
    }

    # True when the dir has any non-hidden entries or is a repo (.git/.jj)
    has_visible() {
      [[ -e "$1/.git" || -e "$1/.jj" ]] && return 0
      local entries=("$1"/*)
      ((''${#entries[@]}))
    }

    # A top-level dir in the root is a project if it has a marker.
    # Otherwise it is a group: if any of its subdirs has a marker, every
    # subdir is a project; if none has, the group itself is the project.
    # Empty and hidden-only dirs are ignored, unless they contain .git/.jj.
    # A missing root lists nothing.
    list_root_projects() {
      local dir sub subdirs nested
      for dir in "$1"/*/; do
        dir="''${dir%/}"
        has_visible "$dir" || continue
        if has_marker "$dir"; then
          echo "$dir"
          continue
        fi

        subdirs=()
        nested=false
        for sub in "$dir"/*/; do
          sub="''${sub%/}"
          [[ "''${sub##*/}" == node_modules ]] && continue
          has_visible "$sub" || continue
          subdirs+=("$sub")
          has_marker "$sub" && nested=true
        done

        if [[ "$nested" == true ]]; then
          printf '%s\n' "''${subdirs[@]}"
        else
          echo "$dir"
        fi
      done
    }

    {
      # Repos inside ~/.config, such as nvim or nixpkgs configs
      $FD -t d -H '^.git$' ~/.config --min-depth 2 --max-depth 3 -x echo {//}
      list_root_projects ~/Documents
      list_root_projects ~/Developer
    } | sort -ru
  ''
