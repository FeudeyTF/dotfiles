{ pkgs, ... }: {
  programs.amnezia-vpn = {
    enable = true;
  };

  systemd.services.AmneziaVPN-service = {
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.iptables
      pkgs.iproute2
    ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
    };
  };
}
