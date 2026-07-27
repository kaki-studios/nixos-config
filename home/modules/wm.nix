{ pkgs, lib, ... }:
{
  services.awww.enable = true;
  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl".source = ../config/niri/config.kdl;
  xdg.configFile."quickshell" = {
    source = ../config/quickshell;
    recursive = true;
  };

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
  qt = {
    enable = true;
    kvantum.enable = true;
    style.name = "kvantum";
  };
}
