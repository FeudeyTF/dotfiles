{ config, ... }: {
  programs.hyprshot = {
    enable = true;
    saveLocation = "${config.xdg.cacheHome}/hypr";
  };
}
