{ pkgs, ... }: {

  nixpkgs.config.allowUnfreePackages = [
    "cups-brother-dcpt310"
    "brscan4"
    "brother-udev-rule-type1"
    "brscan4-etc-files"
	"wpscan"
  ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-dcpt310 ];
  };

  hardware.sane = {
    enable = true;
    brscan4.enable = true;
  };

  services.ipp-usb.enable = true;

  services.udisks2.enable = true;
}
