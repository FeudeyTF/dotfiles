{ pkgs, ... }: {

  extraPackages = with pkgs; [
    uncrustify
    prettier
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
        scss = [
          "prettierd"
          "prettier"
        ];
        css = [
          "prettierd"
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
