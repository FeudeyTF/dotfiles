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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "Feudey";

  networking.networkmanager.enable = true;

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
   packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.commit-mono
    font-awesome
	corefonts
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

  /*
    hardware.graphics = {
      enable = true;
    };

    services.xserver.videoDrivers = [
      "nvidia"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
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
  */

  system.stateVersion = "26.05";
}
