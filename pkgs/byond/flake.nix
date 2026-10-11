# Created by sriptis - https://github.com/scriptis

{
  description = "BYOND (Windows client) packaged under Wine, mirroring the Lutris installer (lutris.net/games/install/39122)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        byond = pkgs.callPackage ./package/byond.nix {
          # Latest dev release + staging patchset (multiarch wow). Staging carries
          # extra winhttp fixes; BYOND's resource downloads hit a winhttp async
          # callback use-after-free on plain Wine. Override with any wine*Packages.
          winePackage = pkgs.wineWowPackages.staging;
        };
      in
      {
        packages = {
          inherit byond;
          default = byond;
        };

        apps.default = {
          type = "app";
          program = "${byond}/bin/byond";
        };
      }
    );
}
