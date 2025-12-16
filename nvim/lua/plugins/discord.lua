vim.pack.add({
	{ src = "https://github.com/vyfor/cord.nvim" }
})

vim.api.nvim_create_autocmd('PackChanged', {
	callback = function(opts)
		if opts.data.spec.name == 'cord.nvim' and opts.data.kind == 'update' then
			vim.cmd 'Cord update'
		end
	end
})

local git_branch = vim.fn.system('git branch --show-current'):gsub('\n', '')

require('cord').setup({
	text = {
		editing = function(opts)
			return string.format('Editing %s - on branch %s', opts.filename, git_branch)
		end
	},

	hooks = {
		workspace_change = function(opts)
			git_branch = vim.fn.system('git branch --show-current'):gsub('\n', '')
		end
	}
})
