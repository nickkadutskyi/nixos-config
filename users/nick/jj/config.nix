{ isDarwin, ... }:
# toml
''
  [user]
  email = "nick@kadutskyi.com"
  name = "Nick Kadutskyi"

  [fsmonitor]
  backend = "watchman"
  watchman.register-snapshot-trigger = true

  [snapshot]
  max-new-file-size = 3097152

  [signing]
  behavior = "own"
  backend = "ssh"
  key = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUOOm/kpbXdO0Zg7XzDK3W67QUCZ/jutXK8w+pgoZqq'

  ${
    if isDarwin then
      ''
        [signing.backends.ssh]
        # This value will vary by OS and can be obtained by following this step:
        # https://developer.1password.com/docs/ssh/git-commit-signing/#step-1-configure-git-commit-signing-with-ssh
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
      ''
    else
      ''''
  }

  [aliases]
  b = ["bookmark"]
  n = ["new"]

  r = ["rebase"]
  s = ["squash"]

  # Instead of moving the bookmark to the commit before the working copy,
  # it moves the bookmark to the closest commit with a description that is
  # either not empty or a merge.
  tug = ["bookmark", "move", "--from", "closest_bookmark(@)", "--to", "closest_pushable(@)"]

  # Rebase the current bookmark onto the trunk.
  retrunk = ["rebase", "-d", "trunk()"]

  [revset-aliases]
  "closest_bookmark(to)" = "heads(::to & bookmarks())"
  'closest_pushable(to)' = 'heads(::to & ~description(exact:"") & ~description(glob:"private:*") & (~empty() | merges()))'
  "fork_history(to, from)" = "fork_point(to | from)..@"

  [template-aliases]
  "format_timestamp(timestamp)" = "timestamp.ago()"

  [ui]
  default-command = "log"
  merge-editor = "neovim"

  [git]
  push-new-bookmarks = true
  private-commits = "description(glob:'private:*')"

  [merge-tools.neovim]
  program = "sh"
  edit-args = [
    "-c",
    """
      set -eu
      rm -f "$right/JJ-INSTRUCTIONS"
      git -C "$left" init -q
      git -C "$left" add -A
      git -C "$left" commit -q -m baseline --allow-empty # create parent commit
      mv "$left/.git" "$right"
      git -C "$right" add --intent-to-add -A # create current working copy
      (cd "$right"; nvim -c "lua require('lazy').load({plugins = {'diffview.nvim'}})" -c DiffviewOpen)
      git -C "$right" diff-index --quiet --cached HEAD && { echo "No changes done, aborting split."; exit 1; }
      git -C "$right" commit -q -m split # create commit on top of parent including changes
      git -C "$right" restore . # undo changes in modified files
      git -C "$right" reset .   # undo --intent-to-add
      git -C "$right" clean -q -df # remove untracked files
    """
  ]
  merge-args = [
    "-c",
    """
      # 3-way merge helper for jj resolve using Neovim + diffview.nvim
      # $left   – OURS   side
      # $base   – BASE   side (merge ancestor)
      # $right  – THEIRS side
      # $output – file path where jj expects the merged result

      set -eu

      # Extract the actual filename from jj's output path
      # $output has format: /path/to/temp/output_filename.ext
      output_basename="$(basename "$output")"
      actual_filename="''${output_basename#output_}"

      # Use the actual filename to preserve original name and extension
      merge_file="$actual_filename"

      # Create a temporary directory that will double as a tiny git repo
      work="$(mktemp -d)"
      trap 'rm -rf "$work"' EXIT

      (
        cd "$work"
        git init -q
        git config user.name "Merge Tool"
        git config user.email "merge@example.com"

        # Create base commit with the common ancestor
        cat "$base" > "$merge_file"
        git add "$merge_file"
        git commit -q -m "base"

        # Create "ours" branch with our changes
        git checkout -q -b ours
        cat "$left" > "$merge_file"
        git add "$merge_file"
        git commit -q -m "ours"

        # Create "theirs" branch with their changes
        git checkout -q main
        git checkout -q -b theirs
        cat "$right" > "$merge_file"
        git add "$merge_file"
        git commit -q -m "theirs"

        # Create a merge conflict by attempting to merge theirs into ours
        git checkout -q ours
        git merge --no-commit theirs || true

        # Now we have a conflicted file that Diffview's merge tool can handle
        # Launch Neovim with Diffview - it will detect the merge state and open merge tool
        nvim -c "lua require('lazy').load({plugins={'diffview.nvim'}})" \
             -c 'DiffviewOpen' \
             "$merge_file"

        # Copy the resolved text back to the path jj provided
        cat "$merge_file" > "$output"
      )
    """
  ]
''
