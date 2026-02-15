{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  homeDir = config.home.homeDirectory;
  cfg = config.tools.development.tizen;
in
{
  options.tools.development.tizen = {
    enable = mkEnableOption "Tizen development environment with tools and services for Tizen development.";
  };

  config = mkIf cfg.enable {

    home.packages = [
      (import ./scripts/tizen-sdb.nix { inherit pkgs; })
      (import ./scripts/tizen.nix { inherit pkgs; })
    ];
    # Tizen Studio Icons
    home.activation = {
      tizenStudioIcons = lib.mkIf isDarwin (
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          # bash
          ''
            TIZEN_ICONS_PATH="${homeDir}/Tizen/tizen-studio/TizenStudio.app/Contents/Eclipse/plugins/org.tizen.product.plugin_*/icons/branding"
            DEVICE_MANAGER_ICONS_PATH="${homeDir}/Tizen/tizen-studio/tools/device-manager/icons"
            DEVICE_MANAGER_PATH="${homeDir}/Tizen/tizen-studio/tools/device-manager"
            CERTIFICATE_MANAGER_ICONS_PATH="${homeDir}/Tizen/tizen-studio/tools/certificate-manager/Certificate-manager.app/Contents/Eclipse/plugins/org.tizen.cert.product.plugin_*/icons"

            SIZES="16 32 64 128 256 512"
            if [ -d $TIZEN_ICONS_PATH ]; then
              cp -f "${./icons}/tizen_studio_64.png" $TIZEN_ICONS_PATH/"tizen_studio_48.png"
              for size in $SIZES; do
                cp -f "${./icons}/tizen_studio_''${size}.png" $TIZEN_ICONS_PATH/"tizen_studio_''${size}.png"
              done
            else
              echo "Missing Tizen Studio icons path: $TIZEN_ICONS_PATH"
            fi
            SIZES="128 256"
            if [ -d $DEVICE_MANAGER_ICONS_PATH ]; then
              mkdir -p temp_dir/res
              cp "${./icons}/device-256.png" temp_dir/res/
              (cd temp_dir && ${pkgs.zip}/bin/zip -u $DEVICE_MANAGER_PATH/bin/device-ui-3.0.jar res/device-256.png)
              rm -rf temp_dir
              cp -f "${./icons}/device_manager.icns" $DEVICE_MANAGER_ICONS_PATH/"device_manager.icns"
              cp -f "${./icons}/device_manager.ico" $DEVICE_MANAGER_ICONS_PATH/"device_manager.ico"
              for size in $SIZES; do
                cp -f "${./icons}/device_manager_''${size}.png" $DEVICE_MANAGER_ICONS_PATH/"device_manager_''${size}.png"
              done
            else
              echo "Missing Device Manager icons path: $DEVICE_MANAGER_ICONS_PATH"
            fi
            SIZES="16 32"
            if [ -d $CERTIFICATE_MANAGER_ICONS_PATH ]; then
              cp -f "${./icons}/icon_certificate_512.png" $CERTIFICATE_MANAGER_ICONS_PATH/"icon_certificate_48.png"
              for size in $SIZES; do
                cp -f "${./icons}/icon_certificate_''${size}.png" $CERTIFICATE_MANAGER_ICONS_PATH/"icon_certificate_''${size}.png"
              done
            else
              echo "Missing  Certificate Manager icons path: $CERTIFICATE_MANAGER_ICONS_PATH"
            fi
          ''
      );
    };
  };
}
