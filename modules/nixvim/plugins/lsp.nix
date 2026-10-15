{ pkgs, ... }: {

  extraPackages = [ pkgs.python3 ];

  plugins.lsp = {
    enable = true;

    servers = {
      nil_ls = {
        enable = true;

        settings = {
          nix = {
            flake = {
              autoArchive = true;
            };
          };

          formatting = {
            command = [ "nixfmt" ];
          };
        };
      };

      ts_ls.enable = true;
      jdtls.enable = true;
      lemminx.enable = true;

      lua_ls = {
        enable = true;
        settings.telemetry.enable = false;
      };

      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };

  plugins.lspkind.enable = true;
}
