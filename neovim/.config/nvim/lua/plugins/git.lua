return {
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
		end,
	},
	-- See `:help gitsigns` to understand what the configuration keys do
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},

			current_line_blame = false,
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end
				local function toggle_git_blame()
					local blame_bufnr = nil

					-- Find the blame buffer if it exists
					for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
						if
							vim.api.nvim_buf_is_valid(bufnr)
							and vim.api.nvim_buf_get_option(bufnr, "filetype") == "gitsigns-blame"
						then
							blame_bufnr = bufnr
							break
						end
					end

					if blame_bufnr then
						-- If the blame buffer is found, close it
						vim.api.nvim_buf_delete(blame_bufnr, { force = true })
					else
						-- If no blame buffer is found, show blame using Gitsigns
						vim.cmd("Gitsigns blame")

						-- Debug: Check what buffer type we're in after blame
						vim.defer_fn(function()
							local current_buf = vim.api.nvim_get_current_buf()
							local ft = vim.api.nvim_buf_get_option(current_buf, "filetype")
							-- vim.notify(
							-- 	"After blame - Buffer: " .. current_buf .. ", Filetype: " .. ft,
							-- 	vim.log.levels.INFO
							-- )
						end, 100)
					end
				end
				vim.keymap.set("n", "<leader>gb", function()
					toggle_git_blame()
				end, { desc = "Toggle Git blame" })

				vim.api.nvim_create_autocmd("FileType", {
					pattern = "gitsigns-blame",
					callback = function(ev)
						local bufnr = ev.buf
						vim.notify(
							"FileType autocmd triggered for gitsigns-blame buffer: " .. bufnr,
							vim.log.levels.INFO
						)

						local function get_blame_data()
							local cache = require("gitsigns.cache").cache

							vim.notify("Cache contents: " .. vim.inspect(vim.tbl_keys(cache)), vim.log.levels.INFO)

							-- Get the original buffer (not the blame buffer)
							local orig_bufnr = nil
							for buf, bcache in pairs(cache) do
								vim.notify(
									"Checking buffer " .. buf .. " has blame: " .. tostring(bcache.blame ~= nil),
									vim.log.levels.INFO
								)
								if bcache.blame then
									orig_bufnr = buf
									break
								end
							end

							if not orig_bufnr then
								vim.notify("No original buffer found with blame data", vim.log.levels.WARN)
								return nil
							end

							local bcache = cache[orig_bufnr]
							if not bcache or not bcache.blame then
								vim.notify("No blame cache for buffer " .. orig_bufnr, vim.log.levels.WARN)
								return nil
							end

							local cursor = vim.api.nvim_win_get_cursor(0)[1]

							-- The blame data is in the entries field
							local blame_entries = bcache.blame.entries
							if not blame_entries then
								vim.notify("No blame entries found", vim.log.levels.WARN)
								return nil
							end

							vim.notify("Blame entries length: " .. #blame_entries, vim.log.levels.INFO)

							-- Get blame data for the current line
							local blame_data = blame_entries[cursor]

							if blame_data then
								vim.notify(
									"Found blame data with structure: " .. vim.inspect(vim.tbl_keys(blame_data)),
									vim.log.levels.INFO
								)
							else
								vim.notify(
									"No blame data for line " .. cursor .. " (entries length: " .. #blame_entries .. ")",
									vim.log.levels.WARN
								)
							end

							return blame_data
						end

						local function safe_execute(fn, desc)
							return function()
								local blame_data = get_blame_data()
								if not blame_data then
									vim.notify("No blame data available", vim.log.levels.WARN)
									return
								end

								local ok, err = pcall(fn, blame_data)
								if not ok then
									vim.notify("Error in " .. desc .. ": " .. tostring(err), vim.log.levels.ERROR)
								end
							end
						end

						local helper = require("personal.copy_github_link")

						vim.keymap.set(
							"n",
							"G",
							safe_execute(function(blame_data)
								helper.open_github_commit(blame_data.commit.sha)
							end, "open commit"),
							{
								buffer = bufnr,
								desc = "Open Commit in Github",
							}
						)

						vim.keymap.set(
							"n",
							"P",
							safe_execute(function(blame_data)
								local summary = blame_data.commit.summary
								local prNumber = tonumber(summary:match("#(%d+)%)?$"))

								if not prNumber then
									vim.notify("No PR number found in commit: " .. summary, vim.log.levels.WARN)
									return
								end

								helper.open_github_pr(prNumber)
							end, "open PR"),
							{
								buffer = bufnr,
								desc = "Open PR in Github",
							}
						)

						vim.keymap.set(
							"n",
							"A",
							safe_execute(function(blame_data)
								local author_mail = blame_data.commit.author_mail:sub(2, -2)
								helper.open_github_author_commits(author_mail)
							end, "open author commits"),
							{
								buffer = bufnr,
								desc = "Open author commits in Github",
							}
						)
					end,
				})

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Next Hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Prev Hunk" })

				-- Actions
				map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
				map("n", "<leader>ha", gs.stage_hunk, { desc = "Stage Hunk" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "Blame Line" })
				map("n", "<leader>tB", gs.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
				map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "Diff This ~" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
			end,
		},
	},
	{
		dir = "~/.config/nvim/lua/personal", -- Load the folder containing your helper
		config = function()
			local helper = require("personal.copy_github_link")

			-- Create the keymap
			vim.keymap.set({ "n", "v" }, "<leader>ghc", function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
				helper.copy_github_link()
			end, { desc = "Copy GitHub link" })

			vim.keymap.set({ "n", "v" }, "<leader>gho", function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
				helper.open_github_link()
			end, { desc = "Open GitHub link" })
		end,
	},
	{
		"pwntester/octo.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			-- OR 'ibhagwan/fzf-lua',
			-- OR 'folke/snacks.nvim',
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},
}
