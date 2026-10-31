# Telegram link: journalctl -u tg-ws-proxy | grep tg://proxy

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.tg-ws-proxy;

  args = [
    "--host"
    cfg.host
    "--port"
    (toString cfg.port)
  ]
  ++ lib.concatMap (ip: [
    "--dc-ip"
    ip
  ]) cfg.dcIps
  ++ lib.concatMap (d: [
    "--cfproxy-domain"
    d
  ]) cfg.cfproxyDomains
  ++ lib.concatMap (d: [
    "--cfproxy-worker-domain"
    d
  ]) cfg.cfproxyWorkerDomains
  ++ lib.optionals (cfg.fakeTlsDomain != "") [
    "--fake-tls-domain"
    cfg.fakeTlsDomain
  ]
  ++ lib.optional cfg.verbose "--verbose"
  ++ cfg.extraArgs;

  startScript = pkgs.writeShellScript "tg-ws-proxy-start" ''
    set -eu

    ${
      if cfg.secretFile != null then
        ''
          secret_file="$CREDENTIALS_DIRECTORY/secret"
        ''
      else
        ''
          secret_file="$STATE_DIRECTORY/secret"
          if [ ! -s "$secret_file" ]; then
            head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$secret_file"
          fi
        ''
    }
    exec ${lib.getExe cfg.package} \
      --secret "$(tr -d ' \n' < "$secret_file")" \
      ${lib.escapeShellArgs args}
  '';
in
{
  options.my.tg-ws-proxy = {
    enable = lib.mkEnableOption "tg-ws-proxy (local MTProto proxy for Telegram over WebSocket)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/tg-ws-proxy { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/tg-ws-proxy { }";
      description = "tg-ws-proxy package.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "tg-ws-proxy address.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1443;
      description = "tg-ws-proxy port.";
    };

    secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/tg-ws-proxy-secret";
      description = "tg-ws-proxy file with proxy secret. If 'null', it will be generated at first run.";
    };

    dcIps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "2:149.154.167.220"
        "4:149.154.167.220"
      ];
      example = [ "4:149.154.167.220" ];
      description = "DC:IP pairs (the --dc-ip flag).";
    };

    cfproxyDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Cloudflare domains (--cfproxy-domain).";
    };

    cfproxyWorkerDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Cloudflare Worker domains (--cfproxy-worker-domain).";
    };

    fakeTlsDomain = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "example.com";
      description = "SNI-domain for Fake TLS (--fake-tls-domain); empty - turned off.";
    };

    verbose = lib.mkEnableOption "debug-logging";

    openFirewall = lib.mkEnableOption "Opening the proxy port in the firewall (only necessary if 'host' is not loopback)";

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--no-h2" ];
      description = "Additional command-line arguments.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.tg-ws-proxy = {
      description = "Telegram MTProto WebSocket bridge proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = [ pkgs.coreutils ];
      environment.PYTHONUNBUFFERED = "1";

      serviceConfig = {
        ExecStart = startScript;
        Restart = "always";
        RestartSec = 5;

        DynamicUser = true;
        StateDirectory = "tg-ws-proxy";
        StateDirectoryMode = "0700";
        LoadCredential = lib.optional (cfg.secretFile != null) "secret:${cfg.secretFile}";

        AmbientCapabilities = lib.optional (cfg.port < 1024) "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = if cfg.port < 1024 then [ "CAP_NET_BIND_SERVICE" ] else [ "" ];

        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
