{
  description = "A very basic flake";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    byond-sdk = {
      url = "github:FeudeyTF/byond-sdk-flake";
      #url = "path:/home/feudey/Projects/byond-sdk-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      zen-browser,
      byond-sdk,
      ...
    }@inputs:
    {
      nixosConfigurations.Feudey = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
        ];
      };
    };
}
