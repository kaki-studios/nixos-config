{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # toolchains and LSPs TODO move elsewhere
    # ponytail: stable pinned via fenix flake input, follows nixpkgs so binary cache hits
    (inputs.fenix.packages.${pkgs.system}.stable.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "rust-analyzer"
    ])

    # gcc
    clang-tools
    clang
    gdb
    # lldb
    vscode-extensions.vadimcn.vscode-lldb # provides codelldb

    go
    gopls

    python3

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
    anki # for studying
    codex

    inputs.quickshell.packages.${pkgs.system}.default
    kdePackages.qtdeclarative
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Kaarlo Kirvelä";
      user.email = "kkirvela@gmail.com";
    };
  };

  programs.gh.enable = true; # for git auth
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
  xdg.configFile."nvim/luasnippets" = {
    source = ../config/nvim/luasnippets;
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
    initContent = ''
      nix_shell_prompt() {
        [[ -n $IN_NIX_SHELL ]] && echo "%{$fg_bold[yellow]%}(nix)%{$reset_color%} "
      }
      PROMPT='$(nix_shell_prompt)'$PROMPT
    '';

  };

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    # font, colors and background_opacity all come from stylix (targets.kitty)
    settings = {
      cursor_shape = "block";
      cursor_blink_interval = 0;
      dynamic_background_opacity = "no";
    };
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
    };
  };
}
