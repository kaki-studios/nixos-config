{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        scheme-small # base + common packages, much smaller than scheme-full
        latexmk
        mathtools
        physics
        tikz-cd
        enumitem
        cleveref
        ;
    };
  };

  programs.zathura = {
    enable = true;
    # Colors and fonts come from stylix (targets.zathura); only behaviour here.
    options = {
      # PDF pages paint their own white background, so the palette only reaches
      # the document once recolor is on. stylix supplies recolor-lightcolor
      # (base00) and recolor-darkcolor (base06); without this the page stays
      # black-on-white and only the UI is themed.
      recolor = true;

      # stylix's zathura target sets default-fg to base01, which is darker than
      # default-bg (base00) — that comes from base16-zathura and only "works"
      # once recolor paints the page. Force the usual body colour so the
      # non-recolored chrome is readable too.
      default-fg = lib.mkForce config.lib.stylix.colors.withHashtag.base05;
    };
  };
}
