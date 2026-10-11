{ pkgs, ... }: {
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
