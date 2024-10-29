{ pkgs, gitignore}:
pkgs.writeText ".gitconfig" /* gitconfig */ ''
  [user]
    helper = osxkeychain
    name = Nick Kadutskyi
    email = nick@kadutskyi.com
    signingkey = F9F8942C85B8E317
  [alias]
    st = status
    ci = commit
    br = branch
    co = checkout
    # ignore = update-index --assume-unchanged
    # unignore = update-index --no-assume-unchanged
    # ignored = !git ls-files -v | grep "^[[:lower:]]"
  [core]
    autocrlf = input
    excludesfile = ${gitignore}
    editor = nvim
  [init]
    defaultBranch = main
  [commit]
    gpgSign = true
  [tag]
    gpgSign = true
  [push]
    followTags = true
''
