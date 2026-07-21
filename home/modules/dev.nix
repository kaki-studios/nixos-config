{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
    go
    gcc
    gdb
  ];
  programs.git = {
    enable = true;
   userName = "Kaarlo Kirvelä";
   userEmail = "kkirvela@gmail.com";
  };
  programs.gh.enable = true;
  programs.neovim.enable = true;


  programs.zsh.enable = true;
}
