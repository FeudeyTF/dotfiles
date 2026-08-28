{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./zapret.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.loader = {
    grub = {
      enable = true;
      useOSProber = true;
      efiSupport = true;
      devices = [ "nodev" ];

      theme = pkgs.catppuccin-grub;
    };
  };

  # boot.kernelParams = [ "module_blacklist=amdgpu" ];

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      feudey = import ./home.nix;
    };
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  documentation.man.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  networking.hostName = "Feudey";

  networking.networkmanager.enable = true;

  my.zapret = {
    enable = true;
    zapret-discord-youtube = {
      version = "1.10.2";
      hash = "sha256-aFZT4E94fskU//J/xaGniV4NKOQ4eL75DXjGH8pHlMI=";
      batFileName = "general (EXP).bat";

     /* extraListExclude = [
        "byond.com"
        "play.monkestation.com"
        "monkestation.com"
        "rr18---sn-n8v7znse.googlevideo.com"
        "rr2---sn-hxb54vo-238s.googlevideo.com"
      ];*/
    };
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.displayManager.ly = {
    enable = true;
    package = pkgs.ly;

    settings = {
      animation = "colormix";
      session_log = "";
    };
  };

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.commit-mono
      font-awesome
      corefonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
    ];
    enableDefaultPackages = true;
  };

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

  programs.nix-ld.enable = true;

  users.users.feudey = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "wireshark"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables = rec {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
    DXVK_FILTER_DEVICE_NAME = "NVIDIA GeForce GTX 1050";
    BYOND_NO_SANDBOX = 1;
    BYOND_CACHE = "/home/feudey/.local/share/byond-flake/prefix/drive_c/users/feudey/Documents/BYOND/cache";
    # __NV_PRIME_RENDER_OFFLOAD = 1;
    # __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  environment.systemPackages = with pkgs; [
    wget
    neovim
    btop
    nvitop
    nixfmt
  ];
  programs.amnezia-vpn = {
    enable = true;
  };

  systemd.services.AmneziaVPN-service = {
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.iptables
      pkgs.iproute2
    ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
    };
  };

  programs.wireshark.enable = true;
  programs.dconf.enable = true;
  programs.hyprland.enable = true;
  programs.git = {
    enable = true;
    config = {
      safe = {
        directory = "/etc/nixos";
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:rctrl_toggle";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [
    "nvidia"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  system.stateVersion = "26.05";
}
