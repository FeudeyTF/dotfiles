{ pkgs, ... }: {
  environment.variables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
    DXVK_FILTER_DEVICE_NAME = "NVIDIA GeForce GTX 1050";
    BYOND_NO_SANDBOX = 1;
    BYOND_CACHE = "$HOME/.local/share/byond-flake/prefix/drive_c/users/feudey/Documents/BYOND/cache";
    # __NV_PRIME_RENDER_OFFLOAD = 1;
    # __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # __VK_LAYER_NV_optimus = "NVIDIA_only";

    # Cache
    XDG_CACHE_HOME = "$HOME/.cache";
    PIP_CACHE_DIR = "$HOME/.cache/pip";
    NPM_CONFIG_CACHE = "$HOME/.cache/npm";
    CARGO_HOME = "$HOME/.cache/cargo";
    GOCACHE = "$HOME/.cache/go-build";
    GOPATH = "$HOME/.cache/go";
    COMPOSER_CACHE_DIR = "$HOME/.cache/composer";
    __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/nvidia";
    _JAVA_OPTIONS = "-Duser.home=$HOME/.cache/java_home -Djava.util.prefs.userRoot=$HOME/.cache/java_prefs";
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
