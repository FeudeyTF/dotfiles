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
	./modules/waybar
    ../modules/nixvim
  ];

  home = {
    username = "feudey";
    homeDirectory = "/home/feudey";
    stateVersion = "26.05";
  };


  home.packages = with pkgs; [
    fastfetch
    mc
    gtk3
    telegram-desktop
    onlyoffice-desktopeditors
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    termshark
    corefonts
    unzip
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

    extraConfig = {
      init.defaultBranch = "main";

      pull.rebase = false;
      push.autoSetupRemote = true;

      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.ssh = {
    enable = true;

    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
    };
  };

  services.ssh-agent.enable = true;

  programs.home-manager.enable = true;
}
