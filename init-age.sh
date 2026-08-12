#!/usr/bin/env bash
NAME=$(hostname)
mkdir -p ~/.config/sops/age
op read "op://$NAME/$NAME/private key?ssh-format=openssh" | ssh-to-age -private-key -i - -o ~/.config/sops/age/keys.txt
chmod 700 ~/.config/sops/age
chmod 600 ~/.config/sops/age/keys.txt

