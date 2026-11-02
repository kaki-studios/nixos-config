# niri itself. The login screen used to live here (ReGreet under greetd); it is
# now Ly on tty1, see modules/ly.nix.
{
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
