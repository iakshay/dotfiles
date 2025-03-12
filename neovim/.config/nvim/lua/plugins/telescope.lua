return { -- Fuzzy Finder (files, lsp, etc)
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ -- If encountering errors, see telescope-fzf-native README for installation instructions
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{
			"nvim-telescope/telescope-live-grep-args.nvim",
			-- This will not install any breaking changes.
			-- For major updates, this must be adjusted manually.
			version = "^1.0.0",
		},

		-- Useful for getting pretty icons, but requires a Nerd Font.
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		-- Two important keymaps to use while in Telescope are:
		--  - Insert mode: <c-/>
		--  - Normal mode: ?
		--
		-- This opens a window that shows you all of the keymaps for the current
		-- Telescope picker. This is really useful to discover what Telescope can
		-- do as well as how to actually do it!

		-- [[ Configure Telescope ]]
		-- See `:help telescope` and `:help telescope.setup()`
		local actions = require("telescope.actions")
		local lga_actions = require("telescope-live-grep-args.actions")
		local trouble = require("trouble.sources.telescope")
		local function flash(prompt_bufnr)
			require("flash").jump({
				pattern = "^",
				label = { after = { 0, 0 } },
				search = {
					mode = "search",
					exclude = {
						function(win)
							return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
						end,
					},
				},
				action = function(match)
					local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
					picker:set_selection(match.pos[1] - 1)
				end,
			})
		end
		local function document_symbols_for_selected(prompt_bufnr)
			local action_state = require("telescope.actions.state")
			local entry = action_state.get_selected_entry()

			if entry == nil then
				print("No file selected")
				return
			end

			actions.close(prompt_bufnr)

			vim.schedule(function()
				local bufnr = vim.fn.bufadd(entry.path)
				vim.fn.bufload(bufnr)

				local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

				vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
					if err then
						print("Error getting document symbols: " .. vim.inspect(err))
						return
					end

					if not result or vim.tbl_isempty(result) then
						print("No symbols found")
						return
					end

					local function flatten_symbols(symbols, parent_name)
						local flattened = {}
						for _, symbol in ipairs(symbols) do
							local name = symbol.name
							if parent_name then
								name = parent_name .. "." .. name
							end
							table.insert(flattened, {
								name = name,
								kind = symbol.kind,
								range = symbol.range,
								selectionRange = symbol.selectionRange,
							})
							if symbol.children then
								local children = flatten_symbols(symbol.children, name)
								for _, child in ipairs(children) do
									table.insert(flattened, child)
								end
							end
						end
						return flattened
					end

					local flat_symbols = flatten_symbols(result)

					-- Define highlight group for symbol kind
					vim.cmd([[highlight TelescopeSymbolKind guifg=#61AFEF]])

					require("telescope.pickers")
						.new({}, {
							prompt_title = "Document Symbols: " .. vim.fn.fnamemodify(entry.path, ":t"),
							finder = require("telescope.finders").new_table({
								results = flat_symbols,
								entry_maker = function(symbol)
									local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Other"
									return {
										value = symbol,
										display = function(entry)
											local display_text = string.format("%-50s %s", entry.value.name, kind)
											return display_text,
												{ { { #entry.value.name + 1, #display_text }, "TelescopeSymbolKind" } }
										end,
										ordinal = symbol.name,
										filename = entry.path,
										lnum = symbol.selectionRange.start.line + 1,
										col = symbol.selectionRange.start.character + 1,
									}
								end,
							}),
							sorter = require("telescope.config").values.generic_sorter({}),
							previewer = require("telescope.config").values.qflist_previewer({}),
							attach_mappings = function(_, map)
								map("i", "<CR>", function(prompt_bufnr)
									local selection = action_state.get_selected_entry()
									actions.close(prompt_bufnr)
									vim.cmd("edit " .. selection.filename)
									vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
								end)
								return true
							end,
						})
						:find()
				end)
			end)
		end
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["<C-t>"] = trouble.open,

						["<c-s>"] = flash,
						["<C-k>"] = document_symbols_for_selected,
					},

					n = {
						s = flash,
						["<C-t>"] = trouble.open,
						["<C-k>"] = document_symbols_for_selected,
					},
				},
				file_ignore_patterns = { "^.git", "node_modules", "experimental", "assets", "research", "dawn" },
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
				},
			},
			-- You can put your default mappings / updates / etc. in here
			--  All the info you're looking for is in `:help telescope.setup()`
			--
			-- defaults = {
			--   mappings = {
			--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
			--   },
			-- },
			-- pickers = {}
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				live_grep_args = {
					auto_quoting = true, -- enable/disable auto-quoting
					-- define mappings, e.g.
					mappings = { -- extend mappings
						i = {
							["<C-k>"] = lga_actions.quote_prompt(),
							["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
							["<c-f>"] = require("telescope.actions").to_fuzzy_refine,
						},
					},
				}
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")
		pcall(require("telescope").load_extension, "live_grep_args")
		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")
		local live_grep_args = require("telescope").extensions.live_grep_args
		vim.keymap.set("n", "<leader>snh", builtin.help_tags, { desc = "[S]earch [N]eovim [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	
		vim.keymap.set("n", "<leader>sf", function()
			builtin.find_files({ hidden = true })
		end, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", function()
			live_grep_args.live_grep_args({ additional_args = "--hidden" })
		end, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		-- Slightly advanced example of overriding default behavior and theme
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to Telescope to change the theme, layout, etc.
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		-- It's also possible to pass additional configuration options.
		--  See `:help telescope.builtin.live_grep()` for information about particular keys
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config"), hidden = true })
		end, { desc = "[S]earch [N]eovim files" })

		vim.keymap.set("n", "<leader>sd", function()
			builtin.find_files({ cwd = "~/.dotfiles", hidden = true })
		end, { desc = "[S]earch [D]dotfiles" })
	end,
}
