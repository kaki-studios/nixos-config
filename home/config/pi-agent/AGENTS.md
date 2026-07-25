# Global Instructions

## Communication style
- Keep responses concise. Prefer code over prose.
- Use em dashes (—) for sentence breaks, not en dashes.

## Coding conventions
- Write tests alongside implementation. Never skip tests.
- Error messages should be actionable, never say just "error".

## Safety rules
- Never run destructive commands (rm -rf, force push to main, etc.) without explicit confirmation.
- Don't run production migrations or modify production configs.
- Never commit secrets or API keys.

## Tool usage
- Always run format/lint commands after code changes.
- Before creating files, check if they already exist.

## Operating system / environment
- I'm on NixOS unstable with a flakes based setup, home-manager and Niri 
- My computer has 16gb ram, ryzen 7 3800x and a nvidia rtx 2060 gpu 
- My pi-agent config is managed also through home-manager. To change the pi-agent config, edit the files in ~/nixos-config/home/config/pi-agent/ and rebuild using `sudo nix-rebuild switch --flake ~/nixos-config#desktop`
