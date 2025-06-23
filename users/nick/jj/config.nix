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
  b = ["branch"]
  n = ["new"]
''
