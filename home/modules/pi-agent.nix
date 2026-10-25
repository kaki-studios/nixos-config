{ pkgs, ... }:
{

  programs.pi-coding-agent = {
    enable = true;
    extraPackages = [ pkgs.nodejs ]; # needed for extensions
  };
  home.file.".pi/agent/settings.json".source = ../config/pi-agent/settings.json;
  home.file.".pi/agent/models.json".source = ../config/pi-agent/models.json;
  home.file.".pi/agent/AGENTS.md".source = ../config/pi-agent/AGENTS.md;
  home.file.".pi/agent/extensions" = {
    source = ../config/pi-agent/extensions;
    recursive = true;
  };
  # Themes are generated from the stylix palette in home/modules/theme.nix.
}
