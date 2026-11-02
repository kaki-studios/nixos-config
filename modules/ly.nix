# Ly display manager, hosted by kmscon on tty1.
#
# nixpkgs' `services.displayManager.ly` pins Ly to the kernel VT
# (TTYPath=/dev/tty1, no kmscon), so Ly can only address the 16 VT palette
# entries and gets the kernel's bitmap font. Upstream ships
# `ly-kmsconvt@.service`, which runs
#   kmscon --term=linux --login -- ly --use-kmscon-vt
# instead: Ly then renders through kmscon's libtsm, gets true 24-bit colour and
# a real TTF font, and kmscon releases the DRM device before the chosen session
# starts (Ly calls kmscon-launch-gui, which sends kmscon's OSC setBackground).
# There is no nixpkgs option for that layout yet - an upstream PR is in progress
# - so the unit is wired by hand here.
#
# Everything colour/font related comes from stylix: `stylix.targets.kmscon`
# fills `services.kmscon.config` with the base16 palette and the monospace
# font, and the Ly colours below are derived from the same base16 scheme.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  ly = pkgs.ly.override { x11Support = config.services.xserver.enable; };

  # # Ly reads the NumLock/CapsLock LEDs with KDGKBLED and sets NumLock with
  # # KDSKBLED, both ioctl'ed on stdin. Those only exist on a kernel VT; with
  # # `--use-kmscon-vt` stdin is kmscon's pty, so every ioctl returns ENOTTY and
  # # the greeter puts "failed to set numlock" / "failed to get lock state" on
  # # its info line. Under kmscon the keyboard belongs to kmscon anyway, so the
  # # patch skips the ioctls (and the two indicator labels) in that mode instead
  # # of reporting an error that cannot be acted on.
  # ly = upstreamLy.overrideAttrs (old: {
  # patches = (old.patches or [ ]) ++ [ ./patches/ly-kmscon-led-ioctl.patch ];
  # });

  palette = config.lib.stylix.colors;

  # Stylix stores the base16 palette as "rrggbb" strings; Ly wants 0xSSRRGGBB,
  # where SS is termbox's styling byte (0x01 bold, 0x02 underline, ...). The
  # resulting RGB values are exact members of the palette that
  # stylix.targets.kmscon hands to libtsm, so Ly's truecolor output lands on it.
  # Nix has no hex literals, hence 0x01 -> 1 and 0x1000000 -> 16777216.
  lyColor =
    styling: base16Key: styling * 16777216 + pkgs.lib.fromHexString palette."${base16Key}-hex";

  # Ly parses its colours with zig's parseInt(_, v, 0), which infers the base
  # from the `0x` prefix, so they have to be written as hex strings.
  lyColorHex =
    styling: base16Key:
    "0x${
      pkgs.lib.fixedWidthString 8 "0" (
        pkgs.lib.toLower (pkgs.lib.toHexString (lyColor styling base16Key))
      )
    }";

  # Same config the `services.kmscon` module renders for tty2-6, reused here so
  # the palette/font live in exactly one place.
  kmsconConfigDir = pkgs.writeTextFile {
    name = "kmscon-dm-config";
    destination = "/kmscon.conf";
    text =
      let
        mkKeyValue =
          k: v: if lib.isBool v then (lib.optionalString (!v) "no-") + k else "${k}=${toString v}";
      in
      lib.generators.toKeyValue { inherit mkKeyValue; } (
        lib.filterAttrs (_: v: v != null) config.services.kmscon.config
      );
  };

  lyConfig = pkgs.writeText "ly-config.ini" (
    lib.generators.toINIWithGlobalSection { } {
      globalSection = {
        # 0x00000000 means "terminal default", which libtsm resolves from the
        # kmscon palette (base05 on base00) instead of a hardcoded colour.
        fg = "0x00000000";
        bg = "0x00000000";
        error_bg = "0x00000000";

        # The rest is rendered as truecolor, so it needs an explicit value.
        border_fg = lyColorHex 0 "base0D"; # stylix's accent
        error_fg = lyColorHex 1 "base08"; # bold red
        full_color = true;

        # animation = "matrix";
        # 0 = run forever. The animation is painted only while Ly waits for
        # input, so it stops on its own once a session is picked.
        # animation_timeout_sec = 0;

        # cmatrix_fg = lyColorHex 0 "base0B";
        # gameoflife_frame_delay = 6;
        # gameoflife_entropy_interval = 10;
        # gameoflife_initial_density = 0.4;

        clear_password = true;

        # Sessions: these mirror what the nixpkgs Ly module passes through, but
        # are fixed here because that module is not what starts Ly.
        service_name = "ly";
        path = "/run/current-system/sw/bin";
        setup_cmd = config.services.displayManager.sessionData.wrapper;
        waylandsessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        xsessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions";
        session_log = ".local/state/ly-session.log";

        # /etc is read-only, and Ly would log a failure on every start if it
        # tried to keep its remembered user/session there.
        save_file_dir = "/var/lib/ly";

        # Defaults point at $CONFIG_DIRECTORY/ly/startup.sh, which cannot be
        # expanded and does not exist in the nixpkgs package.
        start_cmd = null;
        login_cmd = null;
      };
    }
  );
in
{
  # tty2-6: themed kmscon logins instead of unthemed getty, and the module that
  # installs kmscon and suppresses getty@. tty1 is taken over below.
  #
  # `hwaccel` is deliberately left at its default (off): the 3D path needs
  # GBM/GL, which nvidia's proprietary driver does not provide for kmscon's
  # drm3d module, while nvidia-drm does advertise DUMB_BUFFER support for the
  # software (drm2d) path.
  services.kmscon = {
    enable = true;
    config = {
      font-size = lib.mkForce 20;
    };
  };

  services.displayManager.enable = true;

  systemd.tmpfiles.rules = [
    # Ly remembers the selected user and session here.
    "d /var/lib/ly 0755 root root -"
  ];

  # Ly is a display manager on tty1. `Conflicts=` mirrors the nixpkgs Ly module
  # (which uses the generic display-manager.service) so logind cannot start a
  # getty/kmscon login on top of the greeter.
  systemd.services.display-manager = {
    description = "Ly display manager on tty1 (inside kmscon)";
    wantedBy = [ "graphical.target" ];
    after = [
      "autovt@tty1.service"
      "dbus.service"
      "plymouth-quit-wait.service"
      "systemd-logind.service"
      "systemd-user-sessions.service"
    ];
    requires = [ "dbus.service" ];
    conflicts = [
      "autovt@tty1.service"
      "getty@tty1.service"
      "kmsconvt@tty1.service"
    ];
    restartIfChanged = false;

    environment = {
      # kmscon shares its environment with the commands it runs, and Ly's
      # termbox2 needs the `kmscon` terminfo entry (libtsm is not a sun-color or
      # xterm clone) to key-bind and colour correctly.
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
    };

    serviceConfig = {
      Type = "idle";
      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.kmscon)
        "--configdir ${kmsconConfigDir}"
        "--vt=tty1"
        "--no-switchvt"
        # kmscon wipes the environment before exec'ing its child by default,
        # which would drop TERMINFO_DIRS above. Ly needs it to find the
        # `kmscon` terminfo entry.
        "--no-reset-env"
        "--login"
        "--"
        (lib.getExe ly)
        "--use-kmscon-vt"
      ];

      # Ly exits on logout; kmscon restarts it, and should kmscon itself die the
      # unit comes back too.
      Restart = "always";
      RestartSec = 1;

      StandardInput = "tty";
      StandardOutput = "tty";
      # Boot messages and kmscon logs must not paint over the login screen.
      StandardError = "journal";

      TTYPath = "/dev/tty1";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      UtmpIdentifier = "tty1";
      IgnoreSIGPIPE = false;
      SendSIGHUP = true;
    };
  };

  # Ly reads users and passwords through PAM. NixOS' default rule stack would
  # work, but the login substack is what the nixpkgs Ly module uses: it keeps
  # the greeter consistent with console and SSH logins, which also means the
  # fingerprint config in modules/fingerprint.nix applies here.
  security.pam.services.ly = {
    useDefaultRules = false;
    rules = {
      auth = utils.pam.autoOrderRules [
        {
          name = "login";
          control = "substack";
          modulePath = "login";
        }
      ];
      account = utils.pam.autoOrderRules [
        {
          name = "login";
          control = "include";
          modulePath = "login";
        }
      ];
      password = utils.pam.autoOrderRules [
        {
          name = "login";
          control = "substack";
          modulePath = "login";
        }
      ];
      session = utils.pam.autoOrderRules [
        {
          name = "login";
          control = "include";
          modulePath = "login";
        }
      ];
    };
  };

  environment.etc."ly/config.ini".source = lyConfig;

  # Keeps `ly` on PATH for the unit's ExecStart and for debugging by hand.
  environment.systemPackages = [ ly ];
}
