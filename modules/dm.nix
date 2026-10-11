{ pkgs, ... }: {
  services.displayManager.ly = {
    enable = true;
    package = pkgs.ly;

    settings = {
      animation = "colormix";
      session_log = "";
    };
  };
}
