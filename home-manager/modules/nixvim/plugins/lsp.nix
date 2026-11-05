{ pkgs, ... }: {

  extraPackages = [ pkgs.python3 ];

  plugins.lsp = {
    enable = true;

    keymaps = {
      silent = true;

      lspBuf = {
        "gd" = "definition";
        "gD" = "declaration";
        "gi" = "implementation";
        "gt" = "type_definition";
        "K" = "hover";

        "<leader>cr" = "rename";
        "<leader>ca" = "code_action";
        "<leader>cl" = "references";
        "<leader>cf" = "format";
      };

      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>cd" = "open_float";
      };
    };

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
      verible.enable = true;
      pyright.enable = true;
      ruff.enable = true;
      csharp_ls.enable = true;

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

  filetype = {
    extension = {
      xsl = "xsl";
      xslt = "xslt";
    };
  };
}
