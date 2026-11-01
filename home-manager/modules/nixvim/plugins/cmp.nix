{
  plugins.friendly-snippets.enable = true;

  plugins.blink-cmp = {
    enable = true;

    settings = {
      signature = {
        enabled = true;
      };

      completion = {
        documentation.auto_show = true;

        menu = {
          auto_show = true;
          draw = {
            treesitter = [ "lsp" ];
            columns = [
              [
                "kind_icon"
                "label"
                "label_description"
              ]
              [ "kind" ]
            ];
          };
        };
      };

      keymap = {
        "<Tab>" = [
          "select_and_accept"
          "fallback"
        ];
      };

      fuzzy = {
        implementation = "lua";
      };
    };
  };
}
