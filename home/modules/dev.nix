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
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 15;
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      background_opacity = 0.75;
      cursor_shape = "block";
      cursor_blink_interval = 0;
      background = "#11111B";
      selection_foreground = "#11111B";
    };
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
    };
  };
}
