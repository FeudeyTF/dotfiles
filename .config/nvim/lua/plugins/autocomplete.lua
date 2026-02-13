vim.pack.add({
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/nvim-mini/mini.icons",
	{ src = "https://github.com/Saghen/blink.cmp" }
})

vim.pack.add({
	{ src = "https://github.com/onsails/lspkind.nvim" }
})

local blinkcmp = require("blink.cmp")

blinkcmp.setup({
	signature = { enabled = true },
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
		menu = {
			draw = {
				treesitter = { "lsp" },
				columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
			},
			auto_show = true,
		},
	},
	keymap = {
		["<Tab>"] = { 'select_and_accept', 'fallback' }
	},
	fuzzy = { implementation = 'lua' },
})
