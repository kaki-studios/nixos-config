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
  programs.neovim = {
    enable = true;
    waylandSupport = true;
    defaultEditor = true;
  };


  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      # plugins = [ "git" ];
      theme = "robbyrussell";
    };
    
  };

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
  };
}
