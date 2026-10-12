{
  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [ "" ];
        lualine_c = [
          {
            __unkeyed-1 = "filename";
            file_status = true;
            symbols = {
              modified = " [unsaved]";
              readonly = " [readonly]";
              unnamed = "[unnamed]";
              newfile = " [new]";
            };
          }
        ];

        lualine_x = [ "" ];
        lualine_y = [ "" ];
        lualine_z = [ "location" ];
      };
    };
  };
}
