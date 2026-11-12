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
  # Date and time the prompt was drawn (when the previous command finished),
  # at the right edge of the input line, e.g. Thu Nov 12 01:06:06 PST.
  right_format = "$time";
  time = {
    disabled = false;
    format = "[$time]($style)";
    time_format = "%a %b %-d %H:%M:%S %Z";
    style = "dimmed";
  };
  # Most modules are dimmed: the terminal's default text color, drawn fainter,
  # so it stays readable in both light and dark themes. The path is blue, user
  # and host (shown over SSH) are yellow, and root and sudo are bold red.
  username = {
    format = "[$user]($style) [at](dimmed) ";
    style_user = "yellow";
    style_root = "bold red"; # starship's default, kept explicit; matches sudo
  };
  hostname = {
    format = "[$ssh_symbol$hostname]($style) ";
    ssh_symbol = "󰌘 ";
    style = "yellow";
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
    style = "dimmed";
  };
  git_status = {
    # Single 󰇂 when there are any changes (the kinds render as zero-width spaces)
    format = "([󰇂$conflicted$untracked$modified$staged$renamed$deleted]($style) )";
    style = "dimmed";
    conflicted = "​";
    untracked = "​";
    modified = "​";
    staged = "​";
    renamed = "​";
    deleted = "​";
  };
  git_state = {
    format = "\([$state($progress_current/$progress_total)]($style)\) ";
    style = "dimmed";
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
    style = "dimmed";
  };
  # Only rendered when @ is divergent, since $change_offset is empty otherwise.
  jj_change = {
    format = "([\\(divergent/$change_offset\\)](cyan) )";
  };
  # The change's state, plus a single 󰇂 when @ has any file changes. The file
  # kinds render as zero-width spaces so only the 󰇂 shows, not counts.
  jj_status = {
    format = "($conflicted$immutable$hidden )([󰇂$added$copied$deleted$modified$renamed]($style) )";
    style = "dimmed";
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
    style = "dimmed";
    symbol = "󱄅";
    heuristic = true;
    impure_msg = " 󰻍";
    pure_msg = " ";
  };
  direnv = {
    format = "[$loaded]($style) ";
    disabled = false;
    style = "dimmed";
    loaded_msg = "󰏖 ";
    unloaded_msg = "󰏗 ";
  };
  shlvl = {
    disabled = false;
    symbol = " ";
    style = "dimmed";
  };
  sudo = {
    disabled = false;
    format = "[$symbol]($style) ";
    symbol = "󰠠 ";
    style = "bold red"; # same as username's style_root
  };
  cmd_duration = {
    format = "[took $duration]($style) ";
    style = "dimmed";
  };
}
