vim.pack.add({
	{ src = "https://github.com/mason-org/mason.nvim" },
})
require("mason").setup({
  registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
    },
})


