return {
	{
		"mrjones2014/smart-splits.nvim",
		lazy = false, -- Don't lazy load for terminal multiplexer integration
		config = function()
			require("smart-splits").setup({
				-- Ignored buffer types (only while resizing)
				ignored_buftypes = {
					"nofile",
					-- 'quickfix',
					"prompt",
				},
				-- Ignored filetypes (only while resizing)
				ignored_filetypes = { "NvimTree" },
				-- the default number of lines/columns to resize by at a time
				default_amount = 3,
				-- Desired behavior when your cursor is at an edge and you
				-- are moving towards that same edge:
				-- 'wrap' => Wrap to opposite side
				-- 'split' => Create a new split in the desired direction
				-- 'stop' => Do nothing
				at_edge = "wrap",
				-- when moving cursor between splits left or right,
				-- place the cursor on the same row of the *screen*
				-- regardless of line numbers. False by default.
				move_cursor_same_row = false,
				-- whether the cursor should follow the buffer when swapping
				-- buffers by default
				cursor_follows_swapped_bufs = false,
				-- ignore these autocmd events (via :h eventignore) while processing
				-- smart-splits.nvim computations, which involve visiting different
				-- buffers and windows. These events will be ignored during processing,
				-- and un-ignored on completed. This only applies to resize events,
				-- not cursor movement events.
				ignored_events = {
					"BufEnter",
					"WinEnter",
				},
				-- enable or disable a multiplexer integration;
				-- automatically determined, unless explicitly disabled or set
				multiplexer_integration = nil,
				-- disable multiplexer navigation if current multiplexer pane is zoomed
				disable_multiplexer_nav_when_zoomed = true,
			})

			-- Set up keymaps
			local map = vim.keymap.set
			-- moving between splits
			map("n", "<C-h>", function()
				require("smart-splits").move_cursor_left()
			end, { desc = "Move to left split" })
			map("n", "<C-j>", function()
				require("smart-splits").move_cursor_down()
			end, { desc = "Move to below split" })
			map("n", "<C-k>", function()
				require("smart-splits").move_cursor_up()
			end, { desc = "Move to above split" })
			map("n", "<C-l>", function()
				require("smart-splits").move_cursor_right()
			end, { desc = "Move to right split" })
			-- resizing splits
			map("n", "<A-h>", function()
				require("smart-splits").resize_left()
			end, { desc = "Resize split left" })
			map("n", "<A-j>", function()
				require("smart-splits").resize_down()
			end, { desc = "Resize split down" })
			map("n", "<A-k>", function()
				require("smart-splits").resize_up()
			end, { desc = "Resize split up" })
			map("n", "<A-l>", function()
				require("smart-splits").resize_right()
			end, { desc = "Resize split right" })
			-- swapping buffers between windows
			map("n", "<leader><leader>h", function()
				require("smart-splits").swap_buf_left()
			end, { desc = "Swap buffer left" })
			map("n", "<leader><leader>j", function()
				require("smart-splits").swap_buf_down()
			end, { desc = "Swap buffer down" })
			map("n", "<leader><leader>k", function()
				require("smart-splits").swap_buf_up()
			end, { desc = "Swap buffer up" })
			map("n", "<leader><leader>l", function()
				require("smart-splits").swap_buf_right()
			end, { desc = "Swap buffer right" })
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		enable = false,
		---@type Flash.Config
		opts = {},
		  -- stylua: ignore
		keys = {
		    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
		    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
	},
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup()

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			require("mini.indentscope").setup({
				draw = {
					delay = 5000,
					animation = require("mini.indentscope").gen_animation.none(),
				},
			})

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
}
