return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd.hi("Comment gui=none")
		end,
	},
	-- {
	-- 	"maxmx03/solarized.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	---@type solarized.config
	-- 	opts = {},
	-- 	config = function(_, opts)
	-- 		vim.o.termguicolors = true
	-- 		vim.o.background = "light"
	-- 		require("solarized").setup(opts)
	-- 		vim.cmd.colorscheme("solarized")
	-- 	end,
	-- },
	{
		"mbbill/undotree",
		config = function()
			-- TODO: Make it work better with NeoTree
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
	-- Neo-tree is a Neovim plugin to browse the file system
	-- https://github.com/nvim-neo-tree/neo-tree.nvim
	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "\\e", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
		},
		opts = {
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				window = {
					mappings = {
						["\\"] = "close_window",
					},
				},
			},
		},
	},
}
