{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./bash.nix
    ./modules/cursor.nix
    ./modules/direnv.nix
    ./modules/github.nix
    ./modules/kitty.nix
    ./modules/starship.nix
    ./modules/hyprland
    ./modules/obs.nix
    ./modules/waybar
    ./modules/mpv.nix
    ../modules/nixvim
    ../modules/mc.nix
  ];

  home = {
    username = "feudey";
    homeDirectory = "/home/feudey";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    fastfetch
    gtk3
    telegram-desktop
    onlyoffice-desktopeditors
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    termshark
    corefonts
    bluetui
    discord
    ncmpcpp
    fsel
    simple-scan
    qview
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "FeudeyTF";
        email = "yanmordanenko089@gmail.com";
      };

      init.defaultBranch = "master";

      pull.rebase = false;
      push.autoSetupRemote = true;

      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

  services.ssh-agent.enable = true;

  programs.home-manager.enable = true;
}
