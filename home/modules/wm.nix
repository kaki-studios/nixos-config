{ pkgs, lib, ... }:
{
  services.awww.enable = true;
  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl".source = ../config/niri/config.kdl;

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans Regular";
      size = 10;
    };
    theme = {
      package = pkgs.magnetic-catppuccin-gtk;
      name = "Catppuccin-GTK-Dark";
    };
  };

  qt = {
    enable = true;
    kvantum.enable = true;
    style.name = "kvantum";
  };
}
