{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    accent = "blue";
    flavor = "mocha";
  };
  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
  };
}
