{pkgs, ...}:
{
  services.awww.enable = true;

  xdg.configFile."niri/config.kdl".source = ../config/niri/config.kdl;
}
