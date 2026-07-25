# NixOS Configuration

Flake-based NixOS setup for my machines.

## Structure

- `hosts/` — machine-specific configurations
- `modules/` — shared NixOS modules
- `home/` — home-manager user config

## Hosts

- **desktop** — main workstation

## Management

```bash
# Apply system config
sudo nixos-rebuild switch --flake .#desktop

# Update flake inputs
nix flake update
```

## Notes

- Uses `nixos-unstable` channel
- Home-manager with catppuccin theming