{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    # Opt-in only: targets are enabled individually here and in
    # home/modules/wm.nix, so apps with hand-written config that stylix would
    # otherwise overwrite (neovim, librewolf, quickshell) stay untouched.
    autoEnable = false;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 15;
      };
    };

    # Wallpaper: used for the awww background (home/modules/wm.nix) and passed
    # straight to swaylock, which needs no separate copy.
    image = ../home/config/wallpaper/wallpaper.png;

    # Replaces catppuccin.gtk's Papirus-Dark icon theme.
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    # Replaces the home.pointerCursor block from home/modules/misc.nix.
    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    targets = {
      gtk.enable = true; # also sets programs.dconf.enable
      qt.enable = true; # qt5ct/qt6ct + kvantum for system-wide Qt apps
      fontconfig.enable = true;
      font-packages.enable = true;
    };

    # Inherited by home-manager; kitty's target turns this into
    # background_opacity.
    opacity.terminal = 0.75;
  };
}
