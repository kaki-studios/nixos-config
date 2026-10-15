{ pkgs, inputs, ... }:
let
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
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
        # "privacy.resistFingerprinting" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "browser.tabs.inTitlebar" = 0;
      };
      userChrome = builtins.readFile ./userChrome.css;
      # userContent = builtins.readFile ./userContent.css;
      userContent = builtins.readFile ./userContent.css;
    };

  };

}
