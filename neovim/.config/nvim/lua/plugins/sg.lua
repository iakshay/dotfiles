return {
	"sourcegraph/sg.nvim",
	lazy = true,
	enabled = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{
			"<leader>sf",
			"<cmd>lua require('sg.extensions.telescope').fuzzy_search_results()<CR>",
			desc = "Sourcegraph fuzzy search results",
		},
	},
	opts = {
		enable_cody = false,
		accept_tos = true,
		diagnostics = {
			enable = true,
			severity = {
				error = "Error",
				warning = "Warning",
				hint = "Hint",
				information = "Information",
			},
		},
	},
}
