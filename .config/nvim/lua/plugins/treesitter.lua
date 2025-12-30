vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main"
	}
})

require('nvim-treesitter.config').setup {
	ensure_installed = { "typescript", "lua", "go", "tsx", "c_sharp", "vimdoc", "vim", "javascript" },

	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
	},
}
