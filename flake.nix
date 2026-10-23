{
  description = "FeudeyTF's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    byond-sdk = {
      url = "github:FeudeyTF/byond-sdk-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    byond = {
      url = "path:./pkgs/byond";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixvim = {
      url = "github:nix-community/nixvim/main";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      zen-browser,
      byond-sdk,
      byond,
      nixvim,
      ...
    }@inputs:
    {
      nixosConfigurations.Feudey = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
}
