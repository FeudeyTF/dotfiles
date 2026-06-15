{
  config,
  inputs,
  pkgs,
  ...
}:

{
  home.username = "feudey";

  home.homeDirectory = "/home/feudey";

  home.stateVersion = "26.05";

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
    inputs.zen-browser.packages."x86_64-linux".default
    fsel
    nil
	termshark
	corefonts
  ];

  home.file = {

  };

  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      clean = "sudo nix-collect-garbage -d";
    };
  };

  programs.home-manager.enable = true;
}
