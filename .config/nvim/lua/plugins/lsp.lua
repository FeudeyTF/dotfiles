vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/seblyng/roslyn.nvim" }
})

-- Adding .dm, .dme and .dmm as DM language files
vim.filetype.add({
	extension = {
		dm = "dm",
		dme = "dm",
		dmm = "dm"
	}
})

-- LSP config for DreamMaker language server
vim.lsp.config['dm'] = {
	-- Command, that will start language server
	cmd = { 'dm-langserver' },
	filetypes = { 'dm' },
	root_markers = { 'SpacemanDMM.toml', '.git' },
	settings = {},
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' },
			diagnostics = {
				globals = { 'vim', 'require' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = { enable = false }
		},
	},
})

vim.keymap.set('n', '<leader>kf', vim.lsp.buf.format)

-- Enabling LSP servers (DreamMaker too)
vim.lsp.enable({ "lua_ls", "ts_ls", "marksman", "dm", "clangd" })

vim.diagnostic.config {
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = '󰅚 ',
			[vim.diagnostic.severity.WARN] = '󰀪 ',
			[vim.diagnostic.severity.INFO] = '󰋽 ',
			[vim.diagnostic.severity.HINT] = '󰌶 ',
		},
	} or {},
	virtual_text = {
		source = 'if_many',
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
}
