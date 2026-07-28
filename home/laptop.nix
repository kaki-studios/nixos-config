{ config, pkgs, ... }:
{
  imports = [
    ./modules/bluetooth.nix
  ];
  home.packages = with pkgs; [
    brightnessctl
  ];

}
