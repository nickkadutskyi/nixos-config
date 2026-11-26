{
  pkgs,
  user,
  ...
}:
# Shared by the personal machines, both nix-darwin and NixOS. sops-nix puts the
# secrets in /run/secrets on both.
{
  sops = {
    defaultSopsFile = ../secrets/mac/secrets.yaml;
    age.keyFile =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${user}/.config/sops/age/keys.txt"
      else
        "/home/${user}/.config/sops/age/keys.txt";
    secrets = {
      "php/intelephense_license" = {
        owner = user;
      };
      "clickup/api_key" = {
        owner = user;
      };
      "anthropic/api_key" = {
        owner = user;
      };
      "tavily/api_key" = {
        owner = user;
      };
    };
  };
}
