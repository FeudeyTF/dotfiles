{
  description = "BYOND (Windows client) packaged under Wine, mirroring the Lutris installer (lutris.net/games/install/39122)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        byond = pkgs.callPackage ./package/byond.nix {
          # Latest dev release + staging patchset. Staging carries extra winhttp
          # fixes; BYOND's resource downloads hit a winhttp async callback
          # use-after-free on plain Wine. Override with any wine*Packages.
          #
          # Namespace note: nixpkgs deprecated `wineWowPackages` (classic
          # multilib 32+64 build) in favor of `wineWow64Packages`, built with
          # Wine's builtin WoW64 mode (--enable-archs=x86_64,i386): a 64-bit
          # unix side that runs 32-bit PE binaries through i386-windows PE
          # DLLs. Verified against this nixpkgs pin: the build ships
          # lib/wine/i386-windows/ and executes PE32 binaries (BYOND is one).
          winePackage = pkgs.wine;
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
