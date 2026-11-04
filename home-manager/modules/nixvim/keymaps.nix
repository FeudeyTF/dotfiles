{
  globals.mapleader = " ";

  keymaps = [
    {
      action = "<cmd>write<CR>";
      key = "<leader>w";
    }
    {
      action = "<cmd>qa<CR>";
      key = "<leader>q";
    }
    {
      action = "<cmd>e .<CR>";
      key = "<leader>e";
    }
    {
      action = "<cmd>nohlsearch<CR>";
      key = "<Esc>";
    }
    {
      action = "<cmd>term<CR>";
      key = "<leader>t";
    }
    {
      key = "<leader>kf";
      action = "<cmd>lua vim.lsp.buf.format()<CR>";
    }
    {
      mode = "v";
      key = "<Tab>";
      action = ">gv";
      options = {
        silent = true;
      };
    }
    {
      mode = "v";
      key = "<S-Tab>";
      action = "<gv";
      options = {
        silent = true;
      };
    }

    # HJKL -> HTNS
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "t";
      action = "j";
      options.desc = "Down";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "n";
      action = "k";
      options.desc = "Up";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "s";
      action = "l";
      options.desc = "Right";
    }

    # Conflicts
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "j";
      action = "t";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "J";
      action = "T";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "k";
      action = "n";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "K";
      action = "N";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "l";
      action = "s";
    }
    {
      mode = [
        "n"
        "v"
        "o"
      ];
      key = "L";
      action = "S";
    }
  ];
}
