vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{
		src = "https://github.com/nvim-telescope/telescope.nvim",
		version = 'v0.2.0'
	}
})

require("telescope").setup({
  pickers = {
    colorscheme = {
      enable_preview = true
    }
  }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
