{ pkgs, ... }:
{
  imports = [
    ../modules/proxy/amnezia
    ../modules/proxy/zapret-discord-youtube
    ../modules/proxy/tg-ws-proxy
    ../modules/proxy/warp
  ];

  proxy = {
    tg-ws-proxy = {
      enable = true;
    };

    zapret-discord-youtube = {
      enable = true;

      package = pkgs.callPackage ../pkgs/zapret-discord-youtube {
        extraListGoogle = [
          "rr1---sn-hxb54vo-238s.googlevideo.com"
          "rr6---sn-n8v7kn7y.googlevideo.com"
          "rr18---sn-n8v7znse.googlevideo.com"
          "rr2---sn-hxb54vo-238s.googlevideo.com"
          "rr3---sn-axq7sn7l.googlevideo.com"
          "rr4---sn-hxb54vo-238s.googlevideo.com"
          "rr9---sn-axq7sn7s.googlevideo.com"
        ];

        extraListGeneral = [
          "cache.nixos.com"
          "byond.com"
          "dm-lang.org"
          "ref.dm-lang.org"
        ];
      };

      batFileName = "general (ALT13).bat";
    };
  };
}
