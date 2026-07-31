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
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt; # pinentry-curses or pinentry-rofi/bemenu also work well for niri
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 28800;
  };

  programs.password-store = {
    enable = true;
  };
  services.pass-secret-service.enable = true;

  home.packages = [
    pkgs.playerctl
    pkgs.libnotify
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
