{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "blue";
    flavor = "mocha";
    nvim.enable = false;
  };
  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
  };
  home.packages = [
    pkgs.playerctl
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    gtk.enable = true;
    x11.enable = true;
  };
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
  # services.spotifyd = {
  # enable = true;
  # settings =
  # {
  # global = {
  # username = "Alex";
  # password = ;
  # };
  # }
  # ;
  # };
}
