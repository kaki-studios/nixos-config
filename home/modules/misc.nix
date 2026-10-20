{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    autoEnable = true;
    accent = "mauve";
    flavor = "mocha";
    nvim.enable = false; # we set it ourselves
  };
  catppuccin.kvantum = {
    apply = true;
    enable = true;
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

  home.packages = with pkgs; [
    playerctl
    libnotify
    wl-clipboard
    qbittorrent
    mpv
    obs-studio
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
    browsers = [ "librewolf" ];
  };
}
