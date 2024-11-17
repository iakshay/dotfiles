return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	main = "nvim-treesitter.configs", -- Sets main module to use for opts
	-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
	config = function()
		-- https://gist.github.com/lestoni/8c74da455cce3d36eb68
		-- https://www.jackfranklin.co.uk/blog/code-folding-in-vim-neovim/
		vim.opt.foldcolumn = "0"
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		-- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
		vim.o.foldtext = ""
		vim.o.fillchars = "fold: "
		-- vim.opt.foldtext = ""

		vim.opt.foldnestmax = 3
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99

		local function close_all_folds()
			vim.api.nvim_exec2("%foldc!", { output = false })
		end
		local function open_all_folds()
			vim.api.nvim_exec2("%foldo!", { output = false })
		end
		-- Function to toggle fold column
		local function toggle_fold_column()
			local fold_column = vim.wo.foldcolumn
			if fold_column == "4" then
				vim.wo.foldcolumn = "0" -- Set to 0 to hide the fold column
			else
				vim.wo.foldcolumn = "4" -- Set to 4 to show the fold column
			end
		end

		-- zR open all folds
		-- zM close all open folds
		-- za toggles the fold at the cursor
		vim.keymap.set("n", "<leader>zs", close_all_folds, { desc = "[s]hut all folds" })
		vim.keymap.set("n", "<leader>zo", open_all_folds, { desc = "[o]pen all folds" })
		vim.keymap.set("n", "<leader>zT", toggle_fold_column, { desc = "[T]oggle fold columns" })
	end,
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"hcl",
			"terraform",
			"http",
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		highlight = {
			enable = true,
			-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
			--  If you are experiencing weird indenting issues, add the language to
			--  the list of additional_vim_regex_highlighting and disabled languages for indent.
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
		textobjects = {
			select = {
				enable = true,

				-- Automatically jump forward to textobjects, similar to targets.vim
				lookahead = true,

				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					-- you can optionally set descriptions to the mappings (used in the desc parameter of nvim_buf_set_keymap
					["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
				},
				-- You can choose the select mode (default is charwise 'v')
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					["@class.outer"] = "<c-v>", -- blockwise
				},
				-- If you set this to `true` (default is `false`) then any textobject is
				-- extended to include preceding or succeeding whitespace. Succeeding
				-- whitespace has priority in order to act similarly to eg the built-in
				-- `ap`. Can also be a function (see above).
				include_surrounding_whitespace = true,
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>A"] = "@parameter.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			-- move = {
			-- 	enable = true,
			-- 	goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
			-- 	goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
			-- 	goto_previous_start = {
			-- 		["[f"] = "@function.outer",
			-- 		["[c"] = "@class.outer",
			-- 		["[a"] = "@parameter.inner",
			-- 	},
			-- 	goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
			-- },
			lsp_interop = {
				enable = true,
				border = "none",
				floating_preview_opts = {},
				peek_definition_code = {
					["<leader>df"] = "@function.outer",
					["<leader>dF"] = "@class.outer",
				},
			},
		},
	},
	-- There are additional nvim-treesitter modules that you can use to interact
	-- with nvim-treesitter. You should go explore a few and see what interests you:
	--
	--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
	--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
	--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
