{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # toolchains and LSPs
    rustup # rust-analyzer managed by rustup

    gcc
    clang-tools
    gdb
    # lldb
    vscode-extensions.vadimcn.vscode-lldb # provides codelldb

    go
    gopls

    nil
    nixfmt

    lua-language-server
    stylua

    vscode-langservers-extracted # provides html/css lsp
    typescript-language-server

    gofumpt
    pyright

    zig
    zls

    # other stuff
    ripgrep

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
  # why don't we just include the whole nvim directory?
  # because we want lazylock.json to remain writable, which is in the nvim directory
  # so we manage everything else except lazylock.json
  # TODO manage all of this with nix with Nixvim or NVF
  xdg.configFile."nvim/lua" = {
    source = ../config/nvim/lua;
    recursive = true;
  };
  xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;

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
