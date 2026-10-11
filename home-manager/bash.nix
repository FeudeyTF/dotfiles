{
  programs.bash = {
    enable = true;

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      clean = "sudo nix-collect-garbage -d";
    };
  };
}
