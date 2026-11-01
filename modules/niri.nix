{
  config,
  lib,
  pkgs,
  ...
}:
let
  # nixpkgs launches ReGreet under cage, but cage has no way to give the
  # greeter the cursor behaviour we want: its cursor size is a compile-time
  # DSIZE constant and seat.c only ever *draws* the cursor, so it can neither
  # be small nor start hidden. niri has xcursor-size, hide-when-typing and
  # hide-after-inactive-ms, which is exactly "small, hidden until moved".
  greeterConfig = pkgs.writeText "niri-greeter.kdl" ''
    hotkey-overlay {
      skip-at-startup
    }

    cursor {
      xcursor-theme "Adwaita"
      xcursor-size 16
      hide-when-typing
      hide-after-inactive-ms 100
    }

    // ReGreet's only window (APP_ID is "apps.regreet"): plain fullscreen
    // surface, no border, ring or clipped-rounded corners around it.
    window-rule {
      match app-id="apps.regreet"
      open-fullscreen true
      focus-ring {
        off
      }
      border {
        off
      }
      geometry-corner-radius 0
    }

    // Quit this greeter compositor once ReGreet exits. On a successful login
    // greetd tears the greeter session down itself, so this only matters for
    // the aborted/crashed case. Both binaries are absolute: greetd runs the
    // session with its own minimal PATH, so bare names can't be relied on.
    spawn-sh-at-startup "${lib.getExe config.services.displayManager.regreet.package}; ${lib.getExe pkgs.niri} msg action quit --skip-confirmation"
  '';
in
{
  services.displayManager.regreet = {
    enable = true;

    # Use the cached user + last session (/var/lib/regreet/state.toml, i.e.
    # normally niri) instead of showing the user/session pickers. Without a
    # cache the full UI is shown, so a fresh install still works.
    settings.skip_selection = true;
  };

  # Must stay a single line: pkgs.formats.toml emits a `"""` multi-line
  # string when the value contains a newline, and greetd's own TOML parser
  # rejects that ("expected equals sign on line, but found none"), which makes
  # greetd exit before it ever draws the greeter.
  services.greetd.settings.default_session.command = lib.concatStringsSep " " [
    (lib.getExe' pkgs.dbus "dbus-run-session")
    (lib.getExe pkgs.niri)
    "--config"
    (toString greeterConfig)
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
