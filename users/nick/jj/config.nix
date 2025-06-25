{ isDarwin, ... }:
# toml
''
  [user]
  email = "nick@kadutskyi.com"
  name = "Nick Kadutskyi"

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
  c = ["commit"]
  ci = ["commit", "--interactive"]
  e = ["edit"]
  i = ["git", "init", "--colocate"]
  nb = ["bookmark", "create", "-r @-"] # "new bookmark"
  pull = ["git", "fetch"]
  push = ["git", "push", "--allow-new"]
  r = ["rebase"]
  s = ["squash"]
  si = ["squash", "--interactive"]
  b = ["bookmark"]
  n = ["new"]

  # Move the closest bookmark to the current commit. This is useful when
  # working on a named branch, creating a bunch of commits, and then needing
  # to update the bookmark before pushing.
  tug = ["bookmark", "move", "--from", "closest_bookmark(@-)", "--to", "@-"]

  # Rebase the current bookmark onto the trunk.
  retrunk = ["rebase", "-d", "trunk()"]

  [revset-aliases]
  "closest_bookmark(to)" = "heads(::to & bookmarks())"
  "fork_history(to, from)" = "fork_point(to | from)..@"

  [template-aliases]
  "format_timestamp(timestamp)" = "timestamp.ago()"

  [ui]
  default-command = "log"

  [git]
  push-new-bookmarks = true
''
