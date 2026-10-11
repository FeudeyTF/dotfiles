{ pkgs, ... }: {
  home = {
    pointerCursor = {
      enable = true;
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;

      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
    };
  };
}
