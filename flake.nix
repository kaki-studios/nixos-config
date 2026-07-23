{
  description = "My NixOS machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager"; # unstable cuz we need pi-agent
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      catppuccin,
      ...
    }:
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hosts/desktop/configuration.nix

            catppuccin.nixosModules.catppuccin

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.kaarlo = {
                imports = [
                  ./home/default.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
