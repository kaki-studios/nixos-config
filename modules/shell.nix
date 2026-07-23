{
  config,
  lib,
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    zsh-completions
  ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
