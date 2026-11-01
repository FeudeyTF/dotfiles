# Given by good man from Reddit - ccc41-ng. Original code - https://paste.debian.net/hidden/a8fe17a8

{

  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.proxy.zapret-discord-youtube;
in
{
  options.proxy.zapret-discord-youtube = {
    enable = lib.mkEnableOption "zapret (DPI bypass) with YouTube and Discord lists";

    batFileName = lib.mkOption {
      type = lib.types.singleLineStr;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../../pkgs/zapret-discord-youtube { };
    };

    zapret = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zapret;
    };
  };

  config = lib.mkIf cfg.enable {
    services.zapret =
      let
        batFile = builtins.readFile "${cfg.package.src}/${cfg.batFileName}";

        batFileLines = builtins.filter (
          l: builtins.isString l && l != "" && builtins.match "^#.*" l == null
        ) (builtins.split "\n" batFile);

        dropWhile =
          pred: arr:
          (lib.lists.foldl'
            (prev: cur: rec {
              shouldDrop = prev.shouldDrop && pred cur;
              result = if !shouldDrop then prev.result ++ [ cur ] else [ ];
            })
            {
              shouldDrop = true;
              result = [ ];
            }
            arr
          ).result;

        batFileFromStart = dropWhile (line: !(lib.strings.hasPrefix "start " line)) batFileLines;

        batFileRawArgs = lib.lists.flatten (map (lib.strings.splitString " ") batFileFromStart);

        wfUdpArg =
          lib.lists.findSingle (lib.strings.hasPrefix "--wf-udp=") (throw "no --wf-udp")
            (throw "multiple --wf-udp")
            batFileRawArgs;

        udpPorts = lib.trivial.pipe wfUdpArg [
          (lib.strings.removePrefix "--wf-udp=")
          (lib.strings.splitString ",")
          (builtins.filter (s: (builtins.match "%.*%" s) == null))
          (map (builtins.replaceStrings [ "-" ] [ ":" ]))
        ];

        batFileNotReplacedArgs = dropWhile (arg: !(lib.strings.hasPrefix "--filter" arg)) batFileRawArgs;

        params = lib.lists.filter (arg: arg != "") (
          map (builtins.replaceStrings
            [
              "%BIN%"
              "%LISTS%"
              "\r"
              "^"
              "\""
              "%GameFilterTCP%"
              "%GameFilterUDP%"
              "-user"
            ]
            [
              "${cfg.package}/bin/"
              "${cfg.package}/lists/"
              ""
              ""
              ""
              "12"
              "12"
              ""
            ]
          ) batFileNotReplacedArgs
        );
      in
      {
        enable = true;
        httpSupport = true;
        udpSupport = true;
        configureFirewall = true;
        inherit udpPorts params;
        package = cfg.zapret;
      };
  };
}
