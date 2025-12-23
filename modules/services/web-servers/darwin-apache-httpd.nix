{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.httpd-darwin;
  isDarwin = pkgs.stdenv.isDarwin;

  # Path to the macOS built-in Apache config
  httpdConfPath = "/etc/apache2/httpd.conf";
  httpdConfBackup = "/etc/apache2/httpd.conf.before-nix-darwin";

  # All available Apache modules on macOS with their default enabled state
  # Defaults reflect your current active configuration
  defaultModules = {
    # MPM modules (only one should be enabled at a time)
    mpm_event = { path = "libexec/apache2/mod_mpm_event.so"; default = true; };
    mpm_prefork = { path = "libexec/apache2/mod_mpm_prefork.so"; default = false; };
    mpm_worker = { path = "libexec/apache2/mod_mpm_worker.so"; default = false; };

    # Authentication modules
    authn_file = { path = "libexec/apache2/mod_authn_file.so"; default = true; };
    authn_dbm = { path = "libexec/apache2/mod_authn_dbm.so"; default = false; };
    authn_anon = { path = "libexec/apache2/mod_authn_anon.so"; default = false; };
    authn_dbd = { path = "libexec/apache2/mod_authn_dbd.so"; default = false; };
    authn_socache = { path = "libexec/apache2/mod_authn_socache.so"; default = false; };
    authn_core = { path = "libexec/apache2/mod_authn_core.so"; default = true; };

    # Authorization modules
    authz_host = { path = "libexec/apache2/mod_authz_host.so"; default = true; };
    authz_groupfile = { path = "libexec/apache2/mod_authz_groupfile.so"; default = true; };
    authz_user = { path = "libexec/apache2/mod_authz_user.so"; default = true; };
    authz_dbm = { path = "libexec/apache2/mod_authz_dbm.so"; default = false; };
    authz_owner = { path = "libexec/apache2/mod_authz_owner.so"; default = false; };
    authz_dbd = { path = "libexec/apache2/mod_authz_dbd.so"; default = false; };
    authz_core = { path = "libexec/apache2/mod_authz_core.so"; default = true; };
    authnz_ldap = { path = "libexec/apache2/mod_authnz_ldap.so"; default = false; };

    # Access and auth
    access_compat = { path = "libexec/apache2/mod_access_compat.so"; default = true; };
    auth_basic = { path = "libexec/apache2/mod_auth_basic.so"; default = true; };
    auth_form = { path = "libexec/apache2/mod_auth_form.so"; default = false; };
    auth_digest = { path = "libexec/apache2/mod_auth_digest.so"; default = false; };
    allowmethods = { path = "libexec/apache2/mod_allowmethods.so"; default = false; };

    # Caching
    file_cache = { path = "libexec/apache2/mod_file_cache.so"; default = false; };
    cache = { path = "libexec/apache2/mod_cache.so"; default = false; };
    cache_disk = { path = "libexec/apache2/mod_cache_disk.so"; default = false; };
    cache_socache = { path = "libexec/apache2/mod_cache_socache.so"; default = false; };
    socache_shmcb = { path = "libexec/apache2/mod_socache_shmcb.so"; default = false; };
    socache_dbm = { path = "libexec/apache2/mod_socache_dbm.so"; default = false; };
    socache_memcache = { path = "libexec/apache2/mod_socache_memcache.so"; default = false; };
    socache_redis = { path = "libexec/apache2/mod_socache_redis.so"; default = false; };

    # Misc
    watchdog = { path = "libexec/apache2/mod_watchdog.so"; default = false; };
    macro = { path = "libexec/apache2/mod_macro.so"; default = false; };
    dbd = { path = "libexec/apache2/mod_dbd.so"; default = false; };
    dumpio = { path = "libexec/apache2/mod_dumpio.so"; default = false; };
    echo = { path = "libexec/apache2/mod_echo.so"; default = false; };
    buffer = { path = "libexec/apache2/mod_buffer.so"; default = false; };
    data = { path = "libexec/apache2/mod_data.so"; default = false; };
    ratelimit = { path = "libexec/apache2/mod_ratelimit.so"; default = false; };
    reqtimeout = { path = "libexec/apache2/mod_reqtimeout.so"; default = true; };
    dialup = { path = "libexec/apache2/mod_dialup.so"; default = false; };

    # Filters
    ext_filter = { path = "libexec/apache2/mod_ext_filter.so"; default = false; };
    request = { path = "libexec/apache2/mod_request.so"; default = false; };
    include = { path = "libexec/apache2/mod_include.so"; default = false; };
    filter = { path = "libexec/apache2/mod_filter.so"; default = true; };
    reflector = { path = "libexec/apache2/mod_reflector.so"; default = false; };
    substitute = { path = "libexec/apache2/mod_substitute.so"; default = false; };
    sed = { path = "libexec/apache2/mod_sed.so"; default = false; };
    charset_lite = { path = "libexec/apache2/mod_charset_lite.so"; default = false; };
    deflate = { path = "libexec/apache2/mod_deflate.so"; default = false; };
    xml2enc = { path = "libexec/apache2/mod_xml2enc.so"; default = false; };
    proxy_html = { path = "libexec/apache2/mod_proxy_html.so"; default = false; };

    # Core
    mime = { path = "libexec/apache2/mod_mime.so"; default = true; };
    ldap = { path = "libexec/apache2/mod_ldap.so"; default = false; };
    log_config = { path = "libexec/apache2/mod_log_config.so"; default = true; };
    log_debug = { path = "libexec/apache2/mod_log_debug.so"; default = false; };
    log_forensic = { path = "libexec/apache2/mod_log_forensic.so"; default = false; };
    logio = { path = "libexec/apache2/mod_logio.so"; default = false; };
    env = { path = "libexec/apache2/mod_env.so"; default = true; };
    mime_magic = { path = "libexec/apache2/mod_mime_magic.so"; default = false; };
    expires = { path = "libexec/apache2/mod_expires.so"; default = false; };
    headers = { path = "libexec/apache2/mod_headers.so"; default = true; };
    usertrack = { path = "libexec/apache2/mod_usertrack.so"; default = false; };
    unique_id = { path = "libexec/apache2/mod_unique_id.so"; default = false; };
    setenvif = { path = "libexec/apache2/mod_setenvif.so"; default = true; };
    version = { path = "libexec/apache2/mod_version.so"; default = true; };
    remoteip = { path = "libexec/apache2/mod_remoteip.so"; default = false; };

    # Proxy modules
    proxy = { path = "libexec/apache2/mod_proxy.so"; default = true; };
    proxy_connect = { path = "libexec/apache2/mod_proxy_connect.so"; default = true; };
    proxy_ftp = { path = "libexec/apache2/mod_proxy_ftp.so"; default = false; };
    proxy_http = { path = "libexec/apache2/mod_proxy_http.so"; default = true; };
    proxy_fcgi = { path = "libexec/apache2/mod_proxy_fcgi.so"; default = true; };
    proxy_scgi = { path = "libexec/apache2/mod_proxy_scgi.so"; default = false; };
    proxy_uwsgi = { path = "libexec/apache2/mod_proxy_uwsgi.so"; default = false; };
    proxy_fdpass = { path = "libexec/apache2/mod_proxy_fdpass.so"; default = false; };
    proxy_wstunnel = { path = "libexec/apache2/mod_proxy_wstunnel.so"; default = true; };
    proxy_ajp = { path = "libexec/apache2/mod_proxy_ajp.so"; default = true; };
    proxy_balancer = { path = "libexec/apache2/mod_proxy_balancer.so"; default = true; };
    proxy_express = { path = "libexec/apache2/mod_proxy_express.so"; default = false; };
    proxy_hcheck = { path = "libexec/apache2/mod_proxy_hcheck.so"; default = false; };

    # Session
    session = { path = "libexec/apache2/mod_session.so"; default = false; };
    session_cookie = { path = "libexec/apache2/mod_session_cookie.so"; default = false; };
    session_dbd = { path = "libexec/apache2/mod_session_dbd.so"; default = false; };

    # Shared memory
    slotmem_shm = { path = "libexec/apache2/mod_slotmem_shm.so"; default = true; };
    slotmem_plain = { path = "libexec/apache2/mod_slotmem_plain.so"; default = false; };

    # SSL
    ssl = { path = "libexec/apache2/mod_ssl.so"; default = true; };

    # HTTP/2
    http2 = { path = "libexec/apache2/mod_http2.so"; default = false; };

    # Load balancing
    lbmethod_byrequests = { path = "libexec/apache2/mod_lbmethod_byrequests.so"; default = false; };
    lbmethod_bytraffic = { path = "libexec/apache2/mod_lbmethod_bytraffic.so"; default = false; };
    lbmethod_bybusyness = { path = "libexec/apache2/mod_lbmethod_bybusyness.so"; default = false; };
    lbmethod_heartbeat = { path = "libexec/apache2/mod_lbmethod_heartbeat.so"; default = false; };

    # Unix daemon
    unixd = { path = "libexec/apache2/mod_unixd.so"; default = true; };

    # Heartbeat
    heartbeat = { path = "libexec/apache2/mod_heartbeat.so"; default = false; };
    heartmonitor = { path = "libexec/apache2/mod_heartmonitor.so"; default = false; };

    # DAV
    dav = { path = "libexec/apache2/mod_dav.so"; default = false; };
    dav_fs = { path = "libexec/apache2/mod_dav_fs.so"; default = false; };
    dav_lock = { path = "libexec/apache2/mod_dav_lock.so"; default = false; };

    # Directory and content
    status = { path = "libexec/apache2/mod_status.so"; default = true; };
    autoindex = { path = "libexec/apache2/mod_autoindex.so"; default = true; };
    asis = { path = "libexec/apache2/mod_asis.so"; default = false; };
    info = { path = "libexec/apache2/mod_info.so"; default = false; };
    cgid = { path = "libexec/apache2/mod_cgid.so"; default = false; };
    cgi = { path = "libexec/apache2/mod_cgi.so"; default = false; };
    vhost_alias = { path = "libexec/apache2/mod_vhost_alias.so"; default = false; };
    negotiation = { path = "libexec/apache2/mod_negotiation.so"; default = true; };
    dir = { path = "libexec/apache2/mod_dir.so"; default = true; };
    imagemap = { path = "libexec/apache2/mod_imagemap.so"; default = false; };
    actions = { path = "libexec/apache2/mod_actions.so"; default = false; };
    speling = { path = "libexec/apache2/mod_speling.so"; default = false; };
    userdir = { path = "libexec/apache2/mod_userdir.so"; default = false; };
    alias = { path = "libexec/apache2/mod_alias.so"; default = true; };
    rewrite = { path = "libexec/apache2/mod_rewrite.so"; default = true; };

    # macOS specific
    hfs_apple = { path = "libexec/apache2/mod_hfs_apple.so"; default = true; };

    # Perl (deprecated in macOS 11, removed in macOS 12)
    perl = { path = "libexec/apache2/mod_perl.so"; default = false; };
  };

  # Build the modules configuration
  enabledModules = filterAttrs (name: enabled: enabled) cfg.modules;

  modulesConfig = concatStringsSep "\n" (mapAttrsToList (name: _:
    let modInfo = defaultModules.${name};
    in "LoadModule ${name}_module ${modInfo.path}"
  ) enabledModules);

  # Build Listen directives
  listenConfig = concatStringsSep "\n" (map (port: "Listen ${toString port}") cfg.listen);
  listenFallBackConfig = concatStringsSep "\n" (map (port: "Listen ${toString port}") cfg.listenFallBack);

  # Build DirectoryIndex
  directoryIndexConfig = if cfg.directoryIndex != [] then
    "DirectoryIndex ${concatStringsSep " " cfg.directoryIndex}"
  else
    "DirectoryIndex index.html";

  # Generate the complete httpd.conf
  httpdConf = pkgs.writeText "httpd.conf" ''
    #
    # Apache HTTP Server Configuration
    # Generated by nix-darwin httpd-darwin module
    #

    ServerRoot "/usr"

    #
    # Listen directives
    #
    <IfDefine SERVER_APP_HAS_DEFAULT_PORTS>
    ${listenFallBackConfig}
    </IfDefine>
    <IfDefine !SERVER_APP_HAS_DEFAULT_PORTS>
    ${listenConfig}
    </IfDefine>

    #
    # Dynamic Shared Object (DSO) Support
    #
    ${modulesConfig}

    <IfModule unixd_module>
        User _www
        Group _www
    </IfModule>

    ServerAdmin ${cfg.serverAdmin}

    ${optionalString (cfg.serverName != null) "ServerName ${cfg.serverName}"}

    <Directory />
        AllowOverride none
        Require all denied
    </Directory>

    DocumentRoot "${cfg.documentRoot}"
    <Directory "${cfg.documentRoot}">
        Options FollowSymLinks Multiviews
        MultiviewsMatch Any
        AllowOverride ${cfg.allowOverride}
        Require all granted
    </Directory>

    <IfModule dir_module>
        ${directoryIndexConfig}
    </IfModule>

    <FilesMatch "^\.([Hh][Tt]|[Dd][Ss]_[Ss])">
        Require all denied
    </FilesMatch>

    <Files "rsrc">
        Require all denied
    </Files>
    <DirectoryMatch ".*\.\.namedfork">
        Require all denied
    </DirectoryMatch>

    ErrorLog "${cfg.errorLog}"
    LogLevel ${cfg.logLevel}

    <IfModule log_config_module>
        LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
        LogFormat "%h %l %u %t \"%r\" %>s %b" common
        <IfModule logio_module>
            LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
        </IfModule>
        CustomLog "${cfg.accessLog}" common
    </IfModule>

    <IfModule alias_module>
        ScriptAliasMatch ^/cgi-bin/((?!(?i:webobjects)).*$) "/Library/WebServer/CGI-Executables/$1"
    </IfModule>

    <Directory "/Library/WebServer/CGI-Executables">
        AllowOverride None
        Options None
        Require all granted
    </Directory>

    <IfModule headers_module>
        RequestHeader unset Proxy early
    </IfModule>

    <IfModule mime_module>
        TypesConfig /private/etc/apache2/mime.types
        AddType application/x-compress .Z
        AddType application/x-gzip .gz .tgz
    </IfModule>

    TraceEnable off

    # MPM configuration
    Include /private/etc/apache2/extra/httpd-mpm.conf

    # Fancy directory listings
    Include /private/etc/apache2/extra/httpd-autoindex.conf

    <IfModule proxy_html_module>
        Include /private/etc/apache2/extra/proxy-html.conf
    </IfModule>

    <IfModule ssl_module>
        SSLRandomSeed startup builtin
        SSLRandomSeed connect builtin
    </IfModule>

    # Include additional config files
    Include /private/etc/apache2/other/*.conf

    #
    # Extra configuration from nix-darwin
    #
    ${cfg.extraConfig}
  '';

in
{
  options = {
    services.httpd-darwin = {
      enable = mkEnableOption "the macOS Built-in Apache HTTP Server";

      modules = mkOption {
        type = types.attrsOf types.bool;
        default = mapAttrs (name: info: info.default) defaultModules;
        description = ''
          Apache modules to enable. Set module name to true to enable, false to disable.
          Example: { rewrite = true; ssl = true; proxy = true; }
        '';
        example = {
          rewrite = true;
          ssl = true;
          proxy = true;
          proxy_fcgi = true;
          mpm_event = true;
        };
      };

      listen = mkOption {
        type = types.listOf types.port;
        default = [ 80 443 ];
        description = "List of ports to listen on.";
        example = [ 80 443 8080 ];
      };

      listenFallBack = mkOption {
        type = types.listOf types.port;
        default = [ 81 444 ];
        description = "List of ports to fall back when default ones are taken.";
        example = [ 80 443 8080 ];
      };

      serverAdmin = mkOption {
        type = types.str;
        default = "admin@localhost";
        description = "Server admin email address.";
      };

      serverName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Server name (e.g., www.example.com:80).";
      };

      documentRoot = mkOption {
        type = types.path;
        default = "/Library/WebServer/Documents";
        description = "Document root directory.";
      };

      directoryIndex = mkOption {
        type = types.listOf types.str;
        default = [ "index.html" "index.php" ];
        description = "List of directory index files.";
        example = [ "index.html" "index.php" ];
      };

      allowOverride = mkOption {
        type = types.str;
        default = "None";
        description = "AllowOverride setting for document root.";
        example = "All";
      };

      errorLog = mkOption {
        type = types.str;
        default = "/private/var/log/apache2/error_log";
        description = "Path to error log file.";
      };

      accessLog = mkOption {
        type = types.str;
        default = "/private/var/log/apache2/access_log";
        description = "Path to access log file.";
      };

      logLevel = mkOption {
        type = types.enum [ "emerg" "alert" "crit" "error" "warn" "notice" "info" "debug" "trace1" "trace2" "trace3" "trace4" "trace5" "trace6" "trace7" "trace8" ];
        default = "warn";
        description = "Apache log level.";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = ''
          Timeout 600
          ProxyTimeout 600
        '';
        description = "Extra configuration to append to httpd.conf.";
        example = ''
          Timeout 600
          ProxyTimeout 600
        '';
      };
    };
  };

  config = mkIf (cfg.enable && isDarwin) {
    assertions = [
      {
        assertion = isDarwin;
        message = "services.httpd-darwin is only supported on macOS (Darwin).";
      }
    ];

    system.activationScripts.postActivation.text = ''
      echo "Setting up macOS Apache HTTP Server..."

      # Backup original config if not already done
      if [ -f "${httpdConfPath}" ] && [ ! -L "${httpdConfPath}" ] && [ ! -f "${httpdConfBackup}" ]; then
        echo "Backing up original httpd.conf to ${httpdConfBackup}"
        sudo cp "${httpdConfPath}" "${httpdConfBackup}"
      fi

      # Remove existing file/symlink and create new symlink
      if [ -f "${httpdConfPath}" ] || [ -L "${httpdConfPath}" ]; then
        sudo rm "${httpdConfPath}"
      fi

      echo "Linking nix-darwin generated httpd.conf"
      sudo ln -sf "${httpdConf}" "${httpdConfPath}"

      # Restart Apache
      echo "Restarting Apache..."
      sudo apachectl restart || true
    '';
  };
}
