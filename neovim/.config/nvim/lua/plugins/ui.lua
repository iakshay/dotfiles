return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			-- Function to create an immutable buffer and run the command
			local function show_icons()
				-- Get the icons from nvim-web-devicons
				local icons = require("nvim-web-devicons").get_icons()

				-- Create a new buffer
				local buf = vim.api.nvim_create_buf(false, true) -- false: don't create a scratch buffer, true: create a new buffer
				local lines = {}

				-- Prepare lines for the buffer
				for name, icon in pairs(icons) do
					table.insert(lines, name .. " " .. icon.icon)
				end

				-- Set the lines to the buffer
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

				-- Create a window to display the buffer
				local win = vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					width = 50,
					height = #lines + 2,
					row = 5,
					col = 5,
					border = "rounded",
				})

				-- Make the buffer read-only (immutable)
				vim.api.nvim_buf_set_option(buf, "modifiable", false)

				-- Optionally set the buffer name
				vim.api.nvim_buf_set_name(buf, "Icons")
			end

			-- Create user command to run the function
			vim.api.nvim_create_user_command("Icons", show_icons, {})
		end,
	}, -- Highlight todo, notes, etc in comments
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.dashboard").config)
		end,
	},
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
	{
		"hedyhli/outline.nvim",
		lazy = true,
		cmd = { "Outline", "OutlineOpen" },
		keys = { -- Example mapping to toggle outline
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
		},
		opts = {
			-- Your setup opts here
		},
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
		event = "VeryLazy",
		keys = {
			{ "<leader>e", ":Neotree toggle float<CR>", silent = true, desc = "Float File Explorer" },
			{ "<leader><Tab>", ":Neotree toggle left<CR>", silent = true, desc = "Left File Explorer" },
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				popup_border_style = "single",
				enable_git_status = true,
				enable_modified_markers = true,
				enable_diagnostics = true,
				sort_case_insensitive = true,
				default_component_configs = {
					indent = {
						with_markers = true,
						with_expanders = true,
					},
					modified = {
						symbol = " ",
						highlight = "NeoTreeModified",
					},
					icon = {
						folder_closed = "",
						folder_open = "",
						folder_empty = "",
						folder_empty_open = "",
					},
					git_status = {
						symbols = {
							-- Change type
							added = "",
							deleted = "",
							modified = "",
							renamed = "",
							-- Status type
							untracked = "",
							ignored = "",
							unstaged = "",
							staged = "",
							conflict = "",
						},
					},
				},
				window = {
					position = "float",
					width = 35,
				},
				filesystem = {
					follow_current_file = {
						enabled = true,
						leave_dirs_open = false,
					},
					use_libuv_file_watcher = true,
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_name = {
							"node_modules",
						},
						hide_by_pattern = {
							"*.pyc",
							"*.egg-info",
							".*_cache",
							"*pycache*",
						},
						never_show = {
							".next",
							".git",
							".DS_Store",
							"thumbs.db",
						},
					},
				},
				source_selector = {
					winbar = true,
					sources = {
						{ source = "filesystem", display_name = "   Files " },
						{ source = "buffers", display_name = "   Bufs " },
						{ source = "git_status", display_name = "   Git " },
						-- { source = "document_symbols", display_name = "Symbols" },
					},
				},
				event_handlers = {
					{
						event = "neo_tree_window_after_open",
						handler = function(args)
							if args.position == "left" or args.position == "right" then
								vim.cmd("wincmd =")
							end
						end,
					},
					{
						event = "neo_tree_window_after_close",
						handler = function(args)
							if args.position == "left" or args.position == "right" then
								vim.cmd("wincmd =")
							end
						end,
					},
				},
			})
		end,
	},
}
