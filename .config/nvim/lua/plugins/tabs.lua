vim.pack.add({
	'https://github.com/moll/vim-bbye',
	'https://github.com/nvim-tree/nvim-web-devicons',
	{ src = "https://github.com/akinsho/bufferline.nvim" }
})

vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	{ src = "https://github.com/nvim-lualine/lualine.nvim" }
})

require("bufferline").setup({})
require("lualine").setup({})

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>')             -- open new tab
vim.keymap.set('n', '<leader>tx', ':tabcloseCR>')            -- close current tab
vim.keymap.set('n', '<leader>tn', ':BufferLineMoveNext<CR>') -- go to next tab
vim.keymap.set('n', '<leader>tp', ':BufferLineMovePrev<CR>') -- go to previous tabt
vim.keymap.set('n', '<leader>tc', ':BufferLineCloseOthers<CR>')
