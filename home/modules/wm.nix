{ pkgs, ... }:
{
  services.awww.enable = true;

  xdg.configFile."niri/config.kdl".source = ../config/niri/config.kdl;

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans Regular";
      size = 10;
    };
    theme = {
      package = pkgs.catppuccin-gtk;
      name = "catppuccin-mocha-blue-standard+default";
    };
  };
}
