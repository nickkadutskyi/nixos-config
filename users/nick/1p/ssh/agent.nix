{ machine, ... }:
# toml
''
  [[ssh-keys]]
  vault = "Private"
  [[ssh-keys]]
  vault = "Clients"
  [[ssh-keys]]
  vault = "EPDS"
  ${
    if machine == "Nicks-MacBook-Air-0" then
      # toml
      ''
        [[ssh-keys]]
        vault = "Nicks-MacBook-Air-0"
      ''
    else if machine == "Nicks-Mac-mini-0" then
      # toml
      ''
        [[ssh-keys]]
        vault = "Nicks-Mac-mini-0"
      ''
    else
      ""
  }
''
