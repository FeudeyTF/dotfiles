{
  nixpkgs.config.allowUnfreePackages = [
    "steam"
	"steam-unwrapped"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
}
