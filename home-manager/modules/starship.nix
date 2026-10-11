{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;

      hostname = {
        ssh_only = false;
        format = "[$ssh_symbol$hostname]($style) ";
        style = "bold purple";
      };

      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vimcmd_symbol = "[<](bold green)";
        vimcmd_visual_symbol = "[<](bold yellow)";
        vimcmd_replace_symbol = "[<](bold purple)";
        vimcmd_replace_one_symbol = "[<](bold purple)";
      };

      username = {
        show_always = true;
        format = "[$user]($style)@";
      };

      directory = {
        truncation_symbol = "…/";
      };

      battery = {
        full_symbol = "full ";
        charging_symbol = "charging ";
        discharging_symbol = "discharging ";
        unknown_symbol = "unknown ";
        empty_symbol = "empty ";
      };
    };
  };
}
