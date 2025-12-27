{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.targets.darwin.services.snippety-helper;
  homeDir = config.home.homeDirectory;
  helperDir = "${homeDir}/Downloads/.snippety-helper";

  installerScript =
    pkgs.writeShellScript "snippety-helper-installer"
      # bash
      ''
        COMMAND_TIMEOUT=60
        HELPER_DIRNAME=.snippety-helper
        HELPER_DIR=${homeDir}/Downloads/$HELPER_DIRNAME
        BIN_DIR=$HELPER_DIR/bin
        INPUT_FILE=$HELPER_DIR/data/input
        PS=${pkgs.ps}/bin/ps
        GREP=${pkgs.gnugrep}/bin/grep
        AWK=${pkgs.gawk}/bin/awk
        RM=${pkgs.uutils-coreutils-noprefix}/bin/rm
        CAT=${pkgs.uutils-coreutils-noprefix}/bin/cat
        WHICH=${pkgs.which}/bin/which

        OUTPUT_FILE=$HELPER_DIR/data/output

        remove_old () {
            echo "remove_old (do nothing because snippety-helper is not installed)"
            # echo "Disabled removal of old Snippety Helper."
            # # kill -9 `$PS aux | $GREP "snippety-helper" | $GREP -v grep | $GREP -v "update.sh" | $AWK '{print $2}'` 2>/dev/null
            # # $RM -r "$HELPER_DIR" 2>/dev/null
        }

        install_homebrew () {
            echo "install_homebrew (brew is handled by nix)"
            # $WHICH -s brew
            # if [[ $? != 0 ]] ; then
            #     echo "Missing Homebrew."
            #     # echo -e "\033[96mInstalling Homebrew...\033[0m"
            #     # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # else
            #     echo "Homebrew is already installed."
            #     # echo -e "\033[96mUpdating Homebrew...\033[0m"
            #     # brew update
            # fi
        }

        install_fswatch () {
            echo "install_fswatch (fswatch installed by nix)"
            # $WHICH -s fswatch
            # if [[ $? != 0 ]] ; then
            #     echo "Missing fswatch. Please install it."
            #     # echo -e "\033[96mInstalling fswatch...\033[0m"
            #     # brew install fswatch
            # fi
        }

        install_gtimeout() {
            echo "install_gtimeout (gtimeout installed by nix)"
            # $WHICH -s gtimeout
            # if [[ $? != 0 ]] ; then
            #     echo "Missing gtimeout. Please install it."
            #     # echo -e "\033[96mInstalling gtimeout...\033[0m"
            #     # brew install coreutils
            # fi
        }

        show_success () {
            echo
            echo -e "🎉🎉🎉 \033[32mSnippety Helper has been installed!\033[0m"
            echo
            echo -e "\033[38;5;208mNow copy & run:\n${homeDir}/Downloads/$HELPER_DIRNAME/bin/snippety-helper.sh\033[0m"
            echo
            echo -e "\033[90mTo update run:\n${homeDir}/Downloads/$HELPER_DIRNAME/bin/update.sh\033[0m"
            echo
            echo -e "\033[90mTo uninstall run:\n${homeDir}/Downloads/$HELPER_DIRNAME/bin/uninstall.sh\033[0m"
        }

        create_helper_script () {
            $CAT <<EOT > "$BIN_DIR/snippety-helper.sh"
        #!/bin/bash
        echo -e "\033[92mSnippety Helper is running...\033[0m"
        fswatch -o "$INPUT_FILE" | xargs -n1 -I{} "$BIN_DIR/processor.sh"
        EOT

            chmod a+x "$BIN_DIR/snippety-helper.sh"
        }

        create_processor_script () {
            cat <<EOT > "$BIN_DIR/processor.sh"
        #!/bin/bash
        rm "$OUTPUT_FILE" 2>/dev/null
        result=\$(gtimeout $COMMAND_TIMEOUT sh "$INPUT_FILE")

        if [ ! \$? -eq 0 ]; then
            echo "#TIMEOUT#" > "$OUTPUT_FILE"
        else
            echo "\$result" > "$OUTPUT_FILE"
        fi
        EOT

            chmod a+x "$BIN_DIR/processor.sh"
        }

        create_update_script () {
            cat <<EOT > "$BIN_DIR/update.sh"
        #!/bin/bash
        NEW_VERSION=\$(curl -fsSL https://snippety.app/snippety-helper-version.txt)

        if [ "2023-06-19" = "\$NEW_VERSION" ]; then
            echo "You have the latest version from 2023-06-19."
            exit 0
        else
            echo "Detected a new version from \$NEW_VERSION. Updating..."
        fi

        cd ${homeDir}/Downloads && /bin/bash -c "\$(curl -fsSL https://snippety.app/SnippetyHelper-Installer.sh)"
        EOT

            chmod a+x "$BIN_DIR/update.sh"
        }

        create_uninstall_script () {
            cat <<EOT > "$BIN_DIR/uninstall.sh"
        #!/bin/bash
        cd ${homeDir}/Downloads
        kill -9 \`ps aux | grep "snippety-helper" | grep -v grep  | grep -v "uninstall.sh" | awk '{print \$2}'\` 2>/dev/null
        rm -r "$HELPER_DIR" 2>/dev/null
        echo
        echo "Snippety Helper has been uninstalled!"
        echo "Remember to remove your Automator application if you created one."
        EOT

            chmod a+x "$BIN_DIR/uninstall.sh"
        }

        create_runner_script () {
            cat <<EOT > "$BIN_DIR/runner.sh"
        #!/bin/bash
        TIMEOUT=\''${2:-$COMMAND_TIMEOUT}
        let numberOfIterations=TIMEOUT*5
        rm "$OUTPUT_FILE" 2>/dev/null
        echo "\$1" > "$INPUT_FILE"

        counter=1
        while [ ! -f "$OUTPUT_FILE" ]; do
          sleep 0.20
          ((counter++))

          if [ \$counter -gt \$numberOfIterations ]; then
            echo "#TIMEOUT#"
            exit 0
          fi
        done

        output=\$(cat "$OUTPUT_FILE")
        if [ -z "\$output" ]; then
            echo "#NO OUTPUT#"
        else
            echo -n "\$output"
        fi
        EOT

            chmod a+x "$BIN_DIR/runner.sh"
        }

        create_dirs () {
            mkdir -p "$HELPER_DIRNAME"

            cd "$HELPER_DIRNAME"
            mkdir -p bin
            mkdir -p data

            touch "$INPUT_FILE"
        }

        install_snippety_helper () {
            echo -e "\033[96mInstalling Snippety Helper...\033[0m"

            create_dirs

            create_helper_script
            create_processor_script
            create_runner_script
            create_uninstall_script
            create_update_script

            show_success
        }

        start () {
            remove_old
            install_homebrew
            install_fswatch
            install_gtimeout
            install_snippety_helper
        }

        start
      '';
in
{
  options.targets.darwin.services.snippety-helper = {
    enable = mkEnableOption "Snippety Helper service for macOS";
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "targets.darwin.snippety-helper" pkgs lib.platforms.darwin)
    ];

    # Install required packages
    home.packages = [
      # GNU Coreutils (gtimeout is required by snippety-helper)
      pkgs.coreutils-prefixed
      # Monitors a directory for changes (required by snippety-helper)
      pkgs.fswatch
    ];

    # Install snippety-helper via activation script
    home.activation.snippetyHelperInstallation =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          export PKG_CURL PKG_BASH
          PKG_BASH=${pkgs.bash}
          PKG_CURL=${pkgs.curl}
          if [ ! -d ${helperDir} ]; then
            cd ${homeDir}/Downloads && "$PKG_BASH/bin/bash" ${installerScript}
          fi
        '';

    # Check bash permissions for Full Disk Access
    home.activation.checkBashPermissions =
      lib.hm.dag.entryAfter [ "snippetyHelperInstallation" ]
        # bash
        ''
          YELLOW='\033[0;33m'
          NC='\033[0m' # No Color
          SQL="SELECT client,auth_value
                 FROM access
                WHERE client='/bin/bash'
                  AND auth_value='2'
                  AND service='kTCCServiceSystemPolicyAllFiles';"
          DB="/Library/Application Support/com.apple.TCC/TCC.db"
          if [ ! -f "$DB" ] || [ -z "$(${pkgs.sqlite}/bin/sqlite3 "$DB" "$SQL")" ]; then
            echo -e "''${YELLOW}To use snippety-helper LaunchAgent you need to grant bash shell Full Disk Access."
            echo "Please go to System Preferences -> Security & Privacy -> Full Disk Access and add bash shell."
            echo "You can find bash shell in"
            echo "/bin/bash"
            echo -e "After adding restart snippety-helper LaunchAgent or relogin to system.''${NC}"
          fi
        '';

    # Check xargs permissions for Full Disk Access
    home.activation.checkXargsPermissions =
      lib.hm.dag.entryAfter [ "checkBashPermissions" ]
        # bash
        ''
          YELLOW='\033[0;33m'
          NC='\033[0m' # No Color
          SQL="SELECT client,auth_value
                 FROM access
                WHERE client='/usr/bin/xargs'
                  AND auth_value='2'
                  AND service='kTCCServiceSystemPolicyAllFiles';"
          DB="/Library/Application Support/com.apple.TCC/TCC.db"
          if [ ! -f "$DB" ] || [ -z "$(${pkgs.sqlite}/bin/sqlite3 "$DB" "$SQL")" ]; then
            echo -e "''${YELLOW}To use snippety-helper LaunchAgent you need to grant xargs Full Disk Access."
            echo "Please go to System Preferences -> Security & Privacy -> Full Disk Access and add xargs."
            echo "You can find xargs in"
            echo "/usr/bin/xargs"
            echo -e "After adding restart snippety-helper LaunchAgent or relogin to system.''${NC}"
          fi
        '';

    # Enable snippety-helper launchd agent
    launchd.agents.snippety-helper = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            mkdir -p ${homeDir}/.local/state/snippety && \
            ${helperDir}/bin/snippety-helper.sh \
            >${homeDir}/.local/state/snippety/org.nixos.snippety-helper.stdout.log \
            2>${homeDir}/.local/state/snippety/org.nixos.snippety-helper.stderr.log
          ''
        ];
        EnvironmentVariables = {
          PATH = "/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
