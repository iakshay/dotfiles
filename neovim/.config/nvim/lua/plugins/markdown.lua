return {
	{
		"OXY2DEV/markview.nvim",
		enabled = true,
		lazy = false, -- Recommended
		-- ft = "markdown" -- If you decide to lazy-load anyway
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
		opts = {
			filetypes = { "markdown", "quarto", "rmd", "copilot-chat", "Avante" },
			modes = { "n", "no", "i" },
			hybrid_modes = { "n", "i" },
			headings = {
				shift_width = 0,
			},
			links = { enable = true },
			list_items = {
				enable = false,
				marker_minus = {
					add_padding = false,
				},
				marker_plus = {
					add_padding = false,
				},
				marker_star = {
					add_padding = false,
				},
			},
			callbacks = {
				on_enable = function(_, win)
					vim.wo[win].conceallevel = 2
					vim.wo[win].concealcursor = ""
				end,
			},
		},
	},
}
