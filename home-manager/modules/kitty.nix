{ lib, ... }: {
  programs.kitty = lib.mkForce {
    enable = true;

    font = {
      name = "monospace";
      size = 20.0;
    };

    settings = {
      confirm_os_window_close = 0;

      foreground = "#c9d1d9";
      background = "#0d1117";

      selection_foreground = "#0d1117";
      selection_background = "#58a6ff";

      cursor = "#58a6ff";

      tab_bar_background = "#010409";
      active_tab_foreground = "#c9d1d9";
      active_tab_background = "#0d1117";
      inactive_tab_foreground = "#8b949e";
      inactive_tab_background = "#010409";

      color0 = "#484f58";
      color8 = "#6e7681";

      color1 = "#ec8e2c";
      color9 = "#fdac54";

      color2 = "#58a6ff";
      color10 = "#79c0ff";

      color3 = "#d29922";
      color11 = "#e3b341";

      color4 = "#58a6ff";
      color12 = "#79c0ff";

      color5 = "#bc8cff";
      color13 = "#d2a8ff";

      color6 = "#39c5cf";
      color14 = "#56d4dd";

      color7 = "#b1bac4";
      color15 = "#ffffff";
    };
  };
}
