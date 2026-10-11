{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./bash.nix
    ./modules/cursor.nix
    ./modules/direnv.nix
	./modules/wm/hyprland.nix
    ../modules/nixvim
  ];

  home = {
    username = "feudey";
    homeDirectory = "/home/feudey";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    fastfetch
    kitty
    mc
    gtk3
    telegram-desktop
    waybar
    hyprpaper
    hyprshot
    onlyoffice-desktopeditors
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.byond-sdk.packages.${pkgs.stdenv.hostPlatform.system}.DreamDaemon
    inputs.byond-sdk.packages.${pkgs.stdenv.hostPlatform.system}.DreamMaker
    termshark
    corefonts
    unzip
    github-cli
    bluetui
    discord
    docker-compose
    ncmpcpp
    fsel
    simple-scan
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "FeudeyTF";
      email = "yanmordanenko089@gmail.com";
    };
  };

  programs.home-manager.enable = true;
}
