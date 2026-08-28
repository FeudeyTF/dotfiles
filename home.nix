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
    ripgrep
    hyprshot
    onlyoffice-desktopeditors
    inputs.zen-browser.packages.${pkgs.system}.default
    inputs.byond-sdk.packages.${pkgs.system}.DreamDaemon
    inputs.byond-sdk.packages.${pkgs.system}.DreamMaker
    fsel
    nil
    termshark
    corefonts
    unzip
    github-cli
    spotdl
    steamcmd
    discord
    bluetui
    (pkgs.runCommand "dm-langserver" { } ''
      mkdir -p $out/bin
      cp ${./dm-langserver} $out/bin/dm-langserver
      chmod +x $out/bin/dm-langserver
    '')
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
