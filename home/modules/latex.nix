{ pkgs, ... }:
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
    options = {
      recolor = true;
    };
  };
}
