{ pkgs, ... }: {

  extraPackages = with pkgs; [
    uncrustify
    prettier
    biome
  ];

  plugins.conform-nvim = {
    enable = true;

    settings = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };

      formatters_by_ft = {
        java = [ "uncrustify" ];

        javascript = [
          "biome"
        ];

        javascriptreact = [
          "biome"
        ];

        typescript = [
          "biome"
        ];

        typescriptreact = [
          "biome"
        ];

        scss = [
          "prettier"
        ];
        css = [
          "prettier"
        ];
      };

      formatters = {
        uncrustify = {
          prepend_args = [
            "-c"
            "${./uncrustify.cfg}"
            "--no-backup"
          ];
        };
      };
    };
  };
}
