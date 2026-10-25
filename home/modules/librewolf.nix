{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};

  colors = config.lib.stylix.colors;

  # Mirrors `mkColor` from stylix's modules/firefox/each-config.nix: the
  # generated Firefox Color theme reads the *derived* "<role>-rgb-*" keys,
  # not the bare "baseXX" ones.
  mkColor = role: {
    r = colors."${role}-rgb-r";
    g = colors."${role}-rgb-g";
    b = colors."${role}-rgb-b";
  };
in
{
  programs.librewolf = {
    enable = true;

    policies.ExtensionSettings = {
      "browserpass@maximbaz.com".default_area = "navbar";
      "addon@darkreader.org".default_area = "navbar";
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}".default_area = "navbar"; # vimium
      "{3c078156-979c-498b-8990-85f7987dd929}".default_area = "menupanel"; # sidebery
      "sponsorBlocker@ajay.app".default_area = "menupanel";
    };
    policies.DefaultDownloadDirectory = "/home/kaarlo/Downloads"; # TODO don't hardcode
    profiles.default = {
      id = 0;
      isDefault = true;

      extensions.packages = with addons; [
        ublock-origin
        browserpass
        sidebery
        # stylus #no need
        darkreader
        vimium
        # unhook # can't find in the nur
        # dearrow # paid
        sponsorblock
      ];
      extensions.force = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # needed for userChrome/userContent
        "extensions.autoDisableScopes" = 0; # stops Nix-installed extensions from starting disabled
        "browser.fullscreen.autohide" = false;
        "browser.theme.content-theme" = 0; # dark theme
        "privacy.resistFingerprinting" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        # LibreWolf's bundled mozilla.cfg defaults sanitizeOnShutdown to true and leaves
        # clearOnShutdown_v2.cookiesAndStorage at Firefox's default (true). A rebuild changes
        # the wrapper store path, which LibreWolf treats as an update and it then sanitizes
        # cookies on that startup — logging you out of everything. Pin all of it off.
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
        "privacy.clearOnShutdown_v2.siteSettings" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.sessions" = false;
        "privacy.clearOnShutdown.offlineApps" = false;
        "privacy.clearOnShutdown.siteSettings" = false;
        "network.cookie.lifetimePolicy" = 0;
        "browser.tabs.inTitlebar" = 0;
        "identity.fxaccounts.enabled" = true;

        # Fonts, reader-mode colors and (via colorTheme below) the browser
        # chrome come from stylix.targets.librewolf.
      };

      # Palette-role tweaks on top of the theme stylix generates. Labelled by
      # role (base0N) rather than hex, so they follow whatever
      # stylix.base16Scheme is set to.
      #
      # mkForce is required: stylix already assigns these leaves, and the
      # JSON submodule errors out on a duplicate definition instead of
      # preferring the later one.
      extensions.settings."FirefoxColor@mozilla.com".settings.theme.colors = {
        # Selected-tab outline. Drives --tab-border-color-selected (native
        # tabs) and Sidebery's --s-act-el-border ring, which normally paint
        # from base0D (the loud accent). base03 is the scheme's muted
        # neutral — tab borders, and Sidebery's accent, calm down with it.
        #
        # Note: tab_background_separator is NOT the knob for this. It maps to
        # --lwt-background-tab-separator-color, which has zero consumers in
        # LibreWolf 158/156, so setting it is a no-op.
        tab_line = lib.mkForce (mkColor "base03");

        # urlbar autocomplete highlighted row (--urlbarview-background-
        # color-selected). stylix picks base04, which is a light surface on a
        # dark scheme; base02 darkens it while base05 text stays readable.
        popup_highlight = lib.mkForce (mkColor "base02");
      };

      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;
    };
  };

  # Firefox Color paints the toolbar/frame/tab/sidebar/popup colors from the
  # palette. Firefox GNOME theme is deliberately *not* enabled: it replaces
  # userChrome/userContent wholesale, which would undo the tab-bar hiding that
  # sidebery relies on.
  stylix.targets.librewolf = {
    enable = true;
    profileNames = [ "default" ];
    colorTheme.enable = true;
  };
}
