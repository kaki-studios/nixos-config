{ config, pkgs, ... }:

{
  home.username = "kaarlo";
  home.homeDirectory = "/home/kaarlo";
  imports = [
    ./modules/dev.nix
    ./modules/wm.nix
  ];

  home.stateVersion = "26.05";
}

