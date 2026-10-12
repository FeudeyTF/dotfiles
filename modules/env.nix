{ pkgs, ... }: {
  environment.variables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
    DXVK_FILTER_DEVICE_NAME = "NVIDIA GeForce GTX 1050";
    BYOND_NO_SANDBOX = 1;
    BYOND_CACHE = "/home/feudey/.local/share/byond-flake/prefix/drive_c/users/feudey/Documents/BYOND/cache";
    # __NV_PRIME_RENDER_OFFLOAD = 1;
    # __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  nixpkgs.config.allowUnfreePackages = [
    "discord"
    "discord-unwrapped"
  ];

  environment.systemPackages = with pkgs; [
    wget
    btop
    nvitop
    nixfmt
  ];

  programs.wireshark.enable = true;

  programs.dconf.enable = true;

  programs.git = {
    enable = true;
    config = {
      safe = {
        directory = "/etc/nixos";
      };
    };
  };
}
