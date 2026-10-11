{ config, ... }: {
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${config.xdg.configHome}/hypr/wallpapers/space.jpg";
          fit_mode = "fill";
        }

        {
          monitor = "HDMI-A-1";
          path = "${config.xdg.configHome}/hypr/wallpapers/space.jpg";
          fit_mode = "fill";
        }
      ];
    };
  };

  xdg.configFile."hypr/wallpapers".source = ./wallpapers;
}
