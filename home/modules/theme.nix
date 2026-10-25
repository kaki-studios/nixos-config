{ pkgs, config, ... }:
let
  # Single source of truth for every consumer that can't be themed by a stylix
  # target: the QML shell (theme.json) and pi-agent's theme (stylix.json). Both
  # are derived from stylix.base16Scheme, so changing the scheme in
  # modules/stylix.nix re-themes them with no edits here.
  #
  # Neovim used to be a third consumer here (a generated palette.lua); it now
  # goes through stylix.targets.neovim, see home/modules/wm.nix.
  colors = {
    inherit (config.lib.stylix.colors)
      base00
      base01
      base02
      base03
      base04
      base05
      base06
      base07
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      base0F
      ;

    inherit (config.stylix) polarity;
    monospace = config.stylix.fonts.monospace.name;
    sansSerif = config.stylix.fonts.sansSerif.name;
    fontSize = config.stylix.fonts.sizes.desktop;

    # Derived, not hand-picked: the palette's own blue as selection/active.
    accent = config.lib.stylix.colors.base0D;
  };

  # Same palette, addressed as "#rrggbb" strings.
  palette = config.lib.stylix.colors;
  hex = name: "#${palette.${name}}";

  # Mixes `fg` into `bg` at `ratio` (0..1) so state boxes get a subtle tint
  # instead of a second unrelated colour. stylix exposes the channels as
  # strings, hence the fromJSON.
  mix =
    ratio: fg: bg:
    let
      chan =
        sel:
        let
          value = builtins.floor (
            builtins.fromJSON palette."${fg}-rgb-${sel}" * ratio
            + builtins.fromJSON palette."${bg}-rgb-${sel}" * (1.0 - ratio)
            + 0.5
          );
          digits = pkgs.lib.toHexString value;
        in
        if builtins.stringLength digits == 1 then "0${digits}" else digits;
    in
    "#${chan "r"}${chan "g"}${chan "b"}";

  # pi-agent reads this as ~/.pi/agent/themes/stylix.json.
  piTheme = {
    "$schema" = "https://pi.dev/schemas/theme.schema.json";
    name = "stylix";
    appearance = if config.stylix.polarity == "light" then "light" else "dark";

    colors = {
      accent = hex "base0D";
      border = hex "base02";
      borderAccent = hex "base0D";
      borderMuted = hex "base01";
      success = hex "base0B";
      error = hex "base08";
      warning = hex "base0A";
      muted = hex "base04";
      dim = hex "base03";
      text = hex "base05";
      thinkingText = hex "base04";

      selectedBg = hex "base02";

      userMessageBg = hex "base01";
      userMessageText = hex "base05";
      customMessageBg = hex "base01";
      customMessageText = hex "base05";
      customMessageLabel = hex "base0E";

      toolPendingBg = hex "base00";
      toolSuccessBg = mix 0.12 "base0B" "base00";
      toolErrorBg = mix 0.12 "base08" "base00";
      toolTitle = hex "base0D";
      toolOutput = hex "base05";

      mdHeading = hex "base0A";
      mdLink = hex "base0D";
      mdLinkUrl = hex "base04";
      mdCode = hex "base0E";
      mdCodeBlock = hex "base05";
      mdCodeBlockBorder = hex "base02";
      mdQuote = hex "base04";
      mdQuoteBorder = hex "base02";
      mdHr = hex "base02";
      mdListBullet = hex "base0D";

      toolDiffAdded = hex "base0B";
      toolDiffRemoved = hex "base08";
      toolDiffContext = hex "base03";

      syntaxComment = hex "base03";
      syntaxKeyword = hex "base0E";
      syntaxFunction = hex "base0D";
      syntaxVariable = hex "base09";
      syntaxString = hex "base0B";
      syntaxNumber = hex "base09";
      syntaxType = hex "base0C";
      syntaxOperator = hex "base0C";
      syntaxPunctuation = hex "base05";

      thinkingOff = hex "base03";
      thinkingMinimal = hex "base0D";
      thinkingLow = hex "base0C";
      thinkingMedium = hex "base0B";
      thinkingHigh = hex "base0E";
      thinkingXhigh = hex "base08";
      bashMode = hex "base0A";
    };
  };
in
{
  xdg.configFile."quickshell/theme.json".source =
    (pkgs.formats.json { }).generate "quickshell-theme.json"
      colors;

  # pi-agent's config dir is ~/.pi/agent (not XDG). The theme name is
  # "stylix", so settings.json must select it.
  home.file.".pi/agent/themes/stylix.json".source =
    (pkgs.formats.json { }).generate "pi-stylix-theme.json"
      piTheme;
}
