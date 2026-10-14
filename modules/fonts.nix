{ pkgs, ... }: {

  nixpkgs.config.allowUnfreePackages = [
    "corefonts"
  ];

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.commit-mono
      font-awesome
      corefonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      nerd-fonts.iosevka
    ];
    enableDefaultPackages = true;
  };
}
