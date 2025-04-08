# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= nick

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= $(hostname)

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
# SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
SSH_OPTIONS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# We need to do some OS switching below.
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake ".#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# NOTE(mitchellh): I'm sure there is a way to do this and bootstrap all
# in one step but when I tried to merge them I got errors. One day.
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixVersions.latest;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
  			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy our secrets into the VM
vm/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.jj/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nixos-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nixos-config#${NIXNAME}\" \
	"

# bootstrap x240 from scratch. Prior to running this, you need to
# boot the x240 from the NixOS ISO and set the root password to "root".
x240/bootstrap0:
	ssh -t $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted -s /dev/sda -- mklabel gpt; \
		parted -s /dev/sda -- mkpart primary 512MB 100\%; \
		parted -s /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted -s /dev/sda -- set 2 esp on; \
		sleep 1; \
		cryptsetup luksFormat /dev/sda1; \
		cryptsetup open --type luks /dev/sda1 enc-pv; \
		pvcreate /dev/mapper/enc-pv; \
		vgcreate vg /dev/mapper/enc-pv; \
		lvcreate -L 10G -n swap vg; \
		lvcreate -l 100%VG -n root vg; \
		sleep 1; \
		mkfs.fat -F 32 -n boot /dev/sda2; \
		mkfs.ext4 -j -L root /dev/vg/root; \
		mkswap -L swap /dev/vg/swap; \
		sleep 1; \
		mount /dev/vg/root /mnt; \
		mkdir /mnt/boot; \
		mount /dev/sda2 /mnt/boot; \
		swapon /dev/vg/swap; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixVersions.latest;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
			boot.initrd.luks.devices = {\n \
			  rootfs = {\n \
			    name = \"rootfs\";\n \
			    device = \"/dev/sda1\";\n \
			    preLVM = true;\n \
			  };\n \
			};\n \
			boot.loader.grub = {\n \
			  device = \"/dev/sda\";\n \
			};\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after x240/bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
x240/bootstrap1:
	NIXUSER=root $(MAKE) copy
	# This will fail due to age keys not being present so continue on error
	NIXNAME="Server-x240-0" NIXUSER=root $(MAKE) remote/switch || true
	$(MAKE) x240/secrets
	NIXNAME="Server-x240-0" NIXUSER=root $(MAKE) remote/switch
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

x240/sync:
	$(MAKE) copy
	$(MAKE) x240/secrets
	NIXNAME="Server-x240-0" $(MAKE) remote/switch
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy the Nix configurations into the machine.
copy:
	rsync -avr -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.DS_Store' \
		--rsync-path="sudo rsync" \
		--delete \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nixos-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run copy before.
remote/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		[ \"$(uname)\" = \"Darwin\" ] && \
		  nix run --extra-experimental-features \"nix-command flakes\" nix-darwin -- \
		    switch --flake \"~/.config/nixos-config/.#${NIXNAME}\" \
		|| \
		  sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild \
		    switch --flake \"/nixos-config#${NIXNAME}\" \
	"

	# copy our secrets into the machine. TODO: bring machine specific private key from 1Password
x240/secrets:
	# GPG keyring
	# rsync -av -e 'ssh $(SSH_OPTIONS)' \
	# 	--exclude='.#*' \
	# 	--exclude='S.*' \
	# 	--exclude='*.conf' \
	# 	$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	op read "op://Server-x240-0/Server-x240-0/private key?ssh-format=openssh" | \
        ssh $(NIXUSER)@$(NIXADDR) "cat > ~/.ssh/Server-x240-0 && chmod 600 ~/.ssh/Server-x240-0"
	# rsync -av -e 'ssh $(SSH_OPTIONS)' \
	# 	--exclude='environment' \
	# 	$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh
