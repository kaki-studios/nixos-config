{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    tmuxp.enable = true;

    prefix = "C-a";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 1;

    focusEvents = true;
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs.tmuxPlugins; [
      sensible

      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_status_background "none"
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_window_text " #{b:pane_current_path}"
          set -g @catppuccin_window_current_text " #{b:pane_current_path}"
          set -g @catppuccin_date_time_text " %H:%M"
        '';
      }

      resurrect

      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];

    extraConfig = ''
      # Start pane numbering at 1
      set -g pane-base-index 1

      # Kitty / CSI-U
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g allow-passthrough on
      set-option -sa terminal-features ',xterm-kitty:RGB'

      # Open splits/windows in current directory
      unbind '"'
      unbind %

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r refresh-client -S \; display-message "Reloaded Home Manager tmux config"

      # Previous window
      unbind p
      bind p previous-window

      # Don't rename windows
      set -g allow-rename off

      # Alt-arrow pane navigation
      bind -n M-Left  select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D

      # Disable bells
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # Catppuccin status line
      set -g status-left ""
      set -g status-right-length 100
      set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}#{E:@catppuccin_status_date_time}"

      # URL picker
      bind u capture-pane \;\
          save-buffer /tmp/tmux-buffer \;\
          split-window -l 10 "urlview /tmp/tmux-buffer"

      # Sessionizer
      bind-key -r f run-shell "~/.local/scripts/tmux-sessionizer"
    '';
  };
}
