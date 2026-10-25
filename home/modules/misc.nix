{ pkgs, ... }:
{
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

  home.packages = with pkgs; [
    playerctl
    libnotify
    wl-clipboard
    qbittorrent
    mpv
    obs-studio
  ];

  programs.browserpass = {
    enable = true;
    browsers = [ "librewolf" ];
  };
}
