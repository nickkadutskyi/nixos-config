{
  config,
  pkgs,
  ...
}:

{
  add_newline = false;
  format = pkgs.lib.concatStrings [
    "$username"
    "$hostname"
    "$directory"
    "\${custom.git_branch}"
    "\${custom.jj}"
    "\${custom.git_metrics}"
    "$git_status"
    "$git_state"
    "$nix_shell"
    "$direnv"
    "$shlvl"
    "$sudo"
    "$cmd_duration"
    "$line_break"
    "$character"
  ];
  username = {
    format = "[$user]($style) at ";
  };
  hostname = {
    format = "[$ssh_symbol$hostname]($style) ";
    ssh_symbol = "󰌘 ";
  };
  directory = {
    style = "blue";
  };
  character = {
    success_symbol = "[❯](purple)";
    error_symbol = "[❯](red)";
    vimcmd_symbol = "[❮](green)";
  };
  git_branch = {
    disabled = true;
    format = "[$symbol$branch(:$remote_branch)]($style) ";
    symbol = "󰘬 ";
    style = "bright-black";
  };
  git_metrics = {
    disabled = false;
    added_style = "bright-black";
    deleted_style = "bright-black";
    format = "([+$added-$deleted]($added_style)) ";
  };
  git_status = {
    format = "[($ahead_behind$stashed )(󰇂$conflicted$untracked$modified$staged$renamed$deleted)]($style) ";
    style = "bright-black";
    conflicted = "​";
    untracked = "​";
    modified = "​";
    staged = "​";
    renamed = "​";
    deleted = "​";
    stashed = "≡";
    behind = "󰦸";
    ahead = "󰧆";
    diverged = "󰦸 󰧆";
  };
  git_state = {
    format = "\([$state($progress_current/$progress_total)]($style)\) ";
    style = "bright-black";
  };
  custom = {
    git_branch = {
      when = true;
      command = "jj root >/dev/null 2>&1 || starship module git_branch";
      description = "Only show git_branch if we're not in a jj repo";
    };
    git_metrics = {
      when = true;
      command = "jj root >/dev/null 2>&1 || starship module git_metrics";
      description = "Only show git_metrics if we're not in a jj repo";
    };
    jj = {
      command = "prompt";
      format = "$output";
      ignore_timeout = true;
      shell = [
        "starship-jj"
        "--ignore-working-copy"
        "starship"
      ];
      use_stdin = false;
      when = true;

      # symbol = "󱗆 ";
    };
  };
  nix_shell = {
    format = "[$symbol$state(\\($name\\))]($style) ";
    style = "blue";
    symbol = "󱄅 ";
    heuristic = true;
    impure_msg = "󰻍 ";
    pure_msg = " ";
  };
  direnv = {
    format = "[$loaded]($style) ";
    disabled = false;
    style = "yellow";
    loaded_msg = "󰏖 ";
    unloaded_msg = "󰏗 ";
  };
  shlvl = {
    disabled = false;
    symbol = " ";
    style = "yellow";
  };
  sudo = {
    disabled = false;
    format = "[$symbol]($style) ";
    symbol = "󰠠 ";
    style = "yellow";
  };
  cmd_duration = {
    style = "yellow";
  };
}
