{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./settings.nix
    ./proxy.nix
    ../modules/android.nix
    ../modules/bootloader.nix
    ../modules/bluetooth.nix
    ../modules/dm.nix
    ../modules/env.nix
    ../modules/fonts.nix
    ../modules/nm.nix
    ../modules/print-and-scan.nix
    ../modules/sound.nix
    ../modules/graphics.nix
    ../modules/steam.nix
    ../modules/quartus.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };

    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      feudey = import ../home-manager/feudey.nix;
    };
  };

  nixpkgs.config.problems.handlers."gtk+".broken = "warn";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.hyprland.enable = true;

  users.users.hackerman = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      nmap
      nuclei
      nuclei-templates
      wpscan
      metasploit
    ];
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  users.users.feudey = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "wireshark"
      "scanner"
      "lp"
      "docker"
      "ollama"
    ];
  };

  system.stateVersion = "26.05";
}
