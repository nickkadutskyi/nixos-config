{ pkgs, inputs, ...}:
let
  enabled = true;
  sed = "${pkgs.gnused}/bin/sed";
  file = "/etc/apache2/httpd.conf";
  option = "custom.enableBuiltInHttpd";
in
{
  system.activationScripts.postActivation.text = ''
    echo "Setting up Apache server..."
    declare -a apacheModulesEnable=(
              "LoadModule proxy_module libexec/apache2/mod_proxy.so"
              "LoadModule proxy_fcgi_module libexec/apache2/mod_proxy_fcgi.so"
              "LoadModule mpm_event_module libexec/apache2/mod_mpm_event.so"
              "LoadModule rewrite_module libexec/apache2/mod_rewrite.so"
              "LoadModule ssl_module libexec/apache2/mod_ssl.so"
              "LoadModule proxy_http_module libexec/apache2/mod_proxy_http.so"
              "LoadModule proxy_wstunnel_module libexec/apache2/mod_proxy_wstunnel.so"
              "LoadModule proxy_balancer_module libexec/apache2/mod_proxy_balancer.so"
              "LoadModule proxy_ajp_module libexec/apache2/mod_proxy_ajp.so"
              "LoadModule proxy_connect_module libexec/apache2/mod_proxy_connect.so"
              )
    declare -a apacheModulesDisable=(
              "LoadModule mpm_prefork_module libexec/apache2/mod_mpm_prefork.so"
              "    DirectoryIndex index.html"
              )
    declare -a addInTheEnd=(
              "Timeout 600"
              "ProxyTimeout 600"
             )
    declare -a addAfterKey=(
              "    DirectoryIndex index.html"
              "    Listen 80"
              )
    declare -a addAfterValue=(
              "# nix-darwin: ${option}\n    DirectoryIndex index.html index.php"
              "# nix-darwin: ${option}\n    Listen 443"
              )

    ${if enabled then ''

      # ADDS CUSTOM CONFIGURATIONS

      for i in "''${!addAfterKey[@]}"
      do
        if [[ $(${sed} -n '/^'"''${addAfterKey[$i]}"'$/p' ${file}) && ! $(${sed} -n '/^'"''${addAfterKey[$i]}"'$/{:start \@'"''${addAfterValue[$i]}"'@!{N;b start};\,'"''${addAfterKey[$i]}"'\n'"''${addAfterValue[$i]}"',p}' ${file}) ]]; then
          echo "Adding ''${addAfterValue[$i]} after ''${addAfterKey[$i]}"
          ${sed} -i '\,^'"''${addAfterKey[$i]}"'$,a\
      '"''${addAfterValue[$i]}"'
          ' ${file}
        fi
      done
      
      # ENABLES MODULES

      for i in "''${apacheModulesEnable[@]}"
      do
        if [[ $(${sed} -n '/${option}/{:start \@'"$i"'@!{N;b start};\,${option}\n'"$i"',p}' ${file}) ]]; then
          echo "Module $i already enabled"
        else
          echo "Enabling module $i"
          ${sed} -i '\,#'"$i"',a\
      # nix-darwin: ${option}\
      '"$i"'
          ' ${file}
        fi
      done

      # ADDS CONFIGURATIONS IN THE END
      for i in "''${addInTheEnd[@]}"
      do 
        if grep -q "''${i}" ${file}; then
          echo "Config ''${i} is already in the file."
        else
          echo "Adding ''${i} in the end"
          echo -e "# nix-darwin: ${option}\n$i" >> ${file}
        fi
      done

      # DISABLES MODULES

      for i in "''${apacheModulesDisable[@]}"
      do
        if [[ ! $(${sed} -n '\@##*'"$i"'@p' ${file}) ]]; then
          echo "Disabling module $i"
          ${sed} -i 's@'"$i"'$@#'"$i"'@' ${file}
        fi
      done
      sudo apachectl restart
    '' else ''
      
      # REMOVES ADDED CONFIGURATIONS AND MODULES
      
      if grep '${option}' ${file} > /dev/null; then
        echo "Disabling modules..."
        ${sed} -i '/${option}/,+1d' ${file}
        sudo apachectl stop
      fi

      # RENABLES DISABLED MODULES

      for i in "''${apacheModulesDisable[@]}"
      do
        if [[ $(${sed} -n '\@##*'"$i"'@p' ${file}) ]]; then
          echo "Renabling module $i"
          ${sed} -i 's@##*'"$i"'@'"$i"'@' ${file}
        fi
      done
    ''}
  '';
}
