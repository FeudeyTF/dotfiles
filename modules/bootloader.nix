{ pkgs, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      splashImage = null;
      backgroundColor = null;
      devices = [ "nodev" ];

      theme = (
        pkgs.sleek-grub-theme.override {
          withStyle = "dark";
        }
      );
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_default_ttl" = 65;
    "net.ipv6.conf.all.hop_limit" = 65;
    "net.ipv6.conf.default.hop_limit" = 65;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };
}
