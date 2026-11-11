{
  config,
  lib,
  pkgs,
  ...
}:

{
  add_newline = false;
  format = pkgs.lib.concatStrings (
    [
      "$username"
      "$hostname"
      "$directory"
    ]
    ++ (
      if config.tools.development.enable then
        [ "$vcs" ]
      else
        [
          "$git_branch"
          "$git_status"
        ]
    )
    ++ [
      # "$git_status"
      "$git_state"
      "$nix_shell"
      "$direnv"
      "$shlvl"
      "$sudo"
      "$cmd_duration"
      "$line_break"
      "$character"
    ]
  );
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
    # success_symbol = "[❯](purple)";
    # error_symbol = "[❯](red)";
    # vimcmd_symbol = "[❮](green)";
    success_symbol = "[%](purple)";
    error_symbol = "[%](red)";
    vimcmd_symbol = "[$](green)";
  };
  git_branch = {
    format = "[$branch(:$remote_branch)]($style) ";
    style = "bright-black";
  };
  git_status = {
    # Single 󰇂 when there are any changes (the kinds render as zero-width spaces)
    format = "([󰇂$conflicted$untracked$modified$staged$renamed$deleted]($style) )";
    style = "bright-black";
    conflicted = "​";
    untracked = "​";
    modified = "​";
    staged = "​";
    renamed = "​";
    deleted = "​";
  };
  git_state = {
    format = "\([$state($progress_current/$progress_total)]($style)\) ";
    style = "bright-black";
  };
  # Shows jj modules in jj repos and git modules otherwise. The jj modules share
  # a single `jj show` call; the starship package is wrapped so that call runs
  # with --ignore-working-copy (see tools/development).
  vcs = {
    order = [
      "jj"
      "git"
    ];
    jj_modules = "$jj_bookmark$jj_change$jj_status";
    git_modules = "$git_branch$git_status";
  };
  jj_bookmark = {
    format = "[$bookmark(@$remote)]($style) ";
    style = "bright-black";
  };
  # Only rendered when @ is divergent, since $change_offset is empty otherwise.
  jj_change = {
    format = "([\\(divergent/$change_offset\\)](cyan) )";
  };
  # The change's state, plus a single 󰇂 when @ has any file changes. The file
  # kinds render as zero-width spaces so only the 󰇂 shows, not counts.
  jj_status = {
    format = "($conflicted$immutable$hidden )([󰇂$added$copied$deleted$modified$renamed]($style) )";
    style = "bright-black";
    conflicted = "[\\(conflict\\)](red)";
    immutable = "[\\(immutable\\)](yellow)";
    hidden = "[\\(hidden\\)](yellow)";
    added = "​";
    copied = "​";
    deleted = "​";
    modified = "​";
    renamed = "​";
  };
  nix_shell = {
    format = "[$symbol$state]($style) ";
    style = "blue";
    symbol = "󱄅";
    heuristic = true;
    impure_msg = " 󰻍";
    pure_msg = " ";
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
