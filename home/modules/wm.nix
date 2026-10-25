{
  pkgs,
  config,
  lib,
  ...
}:
let
  # stylix.imageScalingMode and `awww img --resize` disagree on names.
  awwwResize = {
    stretch = "stretch";
    fill = "crop";
    fit = "fit";
    center = "no";
    tile = "no";
  };

  setWallpaper = pkgs.writeShellScript "awww-set-wallpaper" ''
    # services.awww starts the daemon with Restart=always, and awww caches the
    # last image per output. Re-send the image on every daemon start so the
    # cache can't resurrect a wallpaper from before a stylix bump, and retry
    # while the daemon's socket is coming up.
    for attempt in 1 2 3 4 5; do
      if ${lib.getExe' pkgs.awww "awww"} img \
        --resize ${awwwResize.${config.stylix.imageScalingMode}} \
        ${config.stylix.image}; then
        exit 0
      fi
      sleep 1
    done
    echo "awww-set-wallpaper: could not reach awww-daemon after 5 attempts" >&2
    # Not fatal: failing here would make systemd restart the daemon in a loop.
    exit 0
  '';
in
{
  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl".source = ../config/niri/config.kdl;

  # GTK + Qt theming comes from stylix (see modules/stylix.nix). Targets are
  # explicit because stylix.autoEnable is off system-wide.
  stylix.targets = {
    gtk.enable = true;
    qt.enable = true;
    kitty.enable = true;
    tmux.enable = true;
    anki.enable = true;
    zathura.enable = true;
    mpv.enable = true;

    # The gutter (line numbers + sign column) is a full-height strip; with
    # kitty's background_opacity the rest of the window is translucent, so an
    # opaque gutter reads as a brighter band. Let the palette background
    # through instead.
    neovim = {
      enable = true;
      transparentBackground = {
        main = true;
        numberLine = true;
        signColumn = true;
      };
    };
    # Image + palette for the lock surface; the image is stylix.image, the same
    # wallpaper awww draws below.
    swaylock.enable = true;
  };

  # stylix sets theme/font/cursor but not the light/dark preference, which is
  # what libadwaita apps read.
  gtk.colorScheme = "dark";

  # niri has no wallpaper option and stylix has no awww target, so hand
  # stylix.image to the daemon ourselves, right after it starts.
  services.awww.enable = true;
  systemd.user.services.awww.Service.ExecStartPost = [ setWallpaper ];
}
