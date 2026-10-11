{ pkgs, ... }: {
  programs.nixvim = {
    enable = true;

    imports = [
      ./opts.nix
      ./keymaps.nix
      ./dm.nix
	  ./theme.nix
	  ./plugins/cmp.nix
	  ./plugins/cord.nix
	  ./plugins/dashboard.nix
	  ./plugins/lualine.nix
	  ./plugins/lsp.nix
	  ./plugins/misc.nix
	  ./plugins/telescope.nix
	  ./plugins/treesitter.nix
    ];

    extraPackages = with pkgs; [
      ripgrep
      fd
      tree-sitter
    ];
  };
}
