{ pkgs, ... }: {
  programs.mc = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "mc-with-archivers";
      paths = with pkgs; [
        mc
        p7zip
        unzip
      ];
    };
  };
}
