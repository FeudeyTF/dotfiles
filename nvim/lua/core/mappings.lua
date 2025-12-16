vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':qa<CR>')
vim.keymap.set('n', '<leader>m', ':Mason<CR>')
vim.keymap.set('n', '<leader>e', ':Neotree<CR>')
vim.keymap.set('n', '<leader>g', ':Neotree float git_status<CR>')

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>') -- open new tab
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>') -- close current tab
vim.keymap.set('n', '<leader>tn', ':tabn<CR>') --  go to next tab
vim.keymap.set('n', '<leader>tp', ':tabp<CR>') --  go to previous tabt
