{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt; # pinentry-curses or pinentry-rofi/bemenu also work well for niri
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 28800;
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        qt6Packages.fcitx5-chinese-addons # pinyin (and table) engines; top-level attr is a throw alias
      ];
      # Declarative ~/.config/fcitx5/profile: English (keyboard-us) + Chinese (pinyin).
      # DefaultIM=pinyin means Ctrl+Space toggles between the two.
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "pinyin";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "pinyin";
        GroupOrder."0" = "Default";
      };
    };
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
