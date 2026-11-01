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
  ];
}
