{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "blue";
    flavor = "mocha";
  };
  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    gtk.enable = true;
    x11.enable = true;
  };
}
