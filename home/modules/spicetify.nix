{
  pkgs,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      shuffle
    ];
    # theme + colorScheme come from stylix (targets.spicetify); it writes a
    # "stylix" theme whose color.ini is generated from the base16 palette.
  };

  stylix.targets.spicetify.enable = true;
}
