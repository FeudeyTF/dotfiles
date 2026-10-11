{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../modules/bootloader.nix
    ../modules/amnezia.nix
    ../modules/bluetooth.nix
    ../modules/dm.nix
    ../modules/env.nix
    ../modules/fonts.nix
    ../modules/nm.nix
    ../modules/print-and-scan.nix
    ../modules/sound.nix
    ../modules/graphics.nix
    ../modules/steam.nix
    ../modules/zapret.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    channel.enable = false;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      feudey = import ../home-manager/feudey.nix;
    };
  };

  home-manager.useUserPackages = true;

  console.keyMap = "dvorak-programmer";

  home-manager.useGlobalPkgs = true;

  programs.nix-ld.enable = true;

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.hyprland.enable = true;

  my.zapret = {
    enable = true;
    zapret-discord-youtube = {
      version = "1.10.3";
      hash = "sha256-7CI4CO85Ggg0w94t3+dreWNYdIJRMTZ72PRRMmHCudk=";
      batFileName = "general (ALT13).bat";

      extraListGoogle = [
        "rr1---sn-hxb54vo-238s.googlevideo.com"
        "rr6---sn-n8v7kn7y.googlevideo.com"
        "rr18---sn-n8v7znse.googlevideo.com"
        "rr2---sn-hxb54vo-238s.googlevideo.com"
        "rr3---sn-axq7sn7l.googlevideo.com"
        "rr4---sn-hxb54vo-238s.googlevideo.com"
        "rr9---sn-axq7sn7s.googlevideo.com"
      ];

      extraListGeneral = [
        "byond.com"
        "dm-lang.org"
        "ref.dm-lang.org"
      ];
    };
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

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
    ];
  };

  system.stateVersion = "26.05";
}
