{ pkgs }:
pkgs.writeText ".gitignore_global" /* gitignore */ ''
  .DS_Store
''
