{
  config,
  lib,
  pkgs,
  ...
}:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "mauve";
    flavor = "mocha";
  };
  catppuccin.sddm = {
    enable = true;
  };
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.sessionPackages = [
    pkgs.niri
  ];
  programs.niri.enable = true;
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
