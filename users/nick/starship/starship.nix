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
    "$git_branch"
    "$git_state"
    "$git_status"
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
    format = "[$branch]($style)";
    style = "bright-black";
  };
  git_status = {
    format = "[( $ahead_behind$stashed)[( 󰇂$conflicted$untracked$modified$staged$renamed$deleted)](bright-blue)]($style) ";
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
    diverged = "󰦸󰧆";
  };
  git_state = {
    format = "\([$state($progress_current/$progress_total)]($style)\) ";
    style = "bright-black";
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
