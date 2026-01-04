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

-- DreamMaker parser
-- Register parser for .dm and .dme files
vim.treesitter.language.register('dm', { 'dm', 'dme', 'dmm' })

-- Add highlighting for DreamMaker files
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'dm', 'dme', 'dmm' },
	callback = function() vim.treesitter.start() end,
})

-- Configure the DreamMaker parser for nvim-treesitter
vim.api.nvim_create_autocmd('User', {
	pattern = 'TSUpdate',
	callback = function()
		require('nvim-treesitter.parsers').dm = {
			install_info = {
				url = 'https://github.com/FeudeyTF/tree-sitter-dm',
				revision = 'HEAD',
				location = 'src',
				generate = true,
				generate_from_json = false,
				queries = 'queries',
			},
		}
	end
})
