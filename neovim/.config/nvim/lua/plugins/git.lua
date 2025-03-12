return {
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
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
						local current_win = vim.api.nvim_get_current_win()

						vim.cmd("Gitsigns blame")

						vim.api.nvim_set_current_win(current_win)
					end
				end
				vim.keymap.set("n", "<leader>gb", function()
					toggle_git_blame()
				end, { desc = "Toggle Git blame" })

				vim.api.nvim_create_autocmd("FileType", {
					pattern = "gitsigns-blame", -- replace with your desired filetype
					callback = function(ev)
						local bufnr = vim.api.nvim_get_current_buf()
						vim.keymap.set("n", "G", function()
							local cache = require("gitsigns.cache").cache
							local log = require("gitsigns.debug.log")
							local helper = require("personal.copy_github_link")

							local bcache = cache[bufnr]
							if not bcache then
								log.dprint("Not attached")
								return
							end
							local blm_win = vim.api.nvim_get_current_win()
							local cursor = vim.api.nvim_win_get_cursor(blm_win)[1]
							local sha = bcache.blame[cursor].commit.sha
							helper.open_github_commit(sha)
						end, {
							buffer = bufnr,
							desc = "Open Commit in Github",
						})

						vim.keymap.set("n", "P", function()
							local cache = require("gitsigns.cache").cache
							local log = require("gitsigns.debug.log")
							local helper = require("personal.copy_github_link")

							local bcache = cache[bufnr]
							if not bcache then
								log.dprint("Not attached")
								return
							end
							local blm_win = vim.api.nvim_get_current_win()
							local cursor = vim.api.nvim_win_get_cursor(blm_win)[1]
							local summary = bcache.blame[cursor].commit.summary

							local prNumber = tonumber(summary:match("#(%d+)%)?$"))
							helper.open_github_pr(prNumber)
						end, {
							buffer = bufnr,
							desc = "Open PR in Github",
						})

						vim.keymap.set("n", "A", function()
							local cache = require("gitsigns.cache").cache
							local log = require("gitsigns.debug.log")
							local helper = require("personal.copy_github_link")

							local bcache = cache[bufnr]
							if not bcache then
								log.dprint("Not attached")
								return
							end
							local blm_win = vim.api.nvim_get_current_win()
							local cursor = vim.api.nvim_win_get_cursor(blm_win)[1]
							local commit = bcache.blame[cursor].commit
							local author_mail = commit.author_mail:sub(2, -2)

							helper.open_github_author_commits(author_mail)
						end, {
							buffer = bufnr,
							desc = "Open author commits in Github",
						})
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
				end, { expr = true })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true })

				-- Actions
				map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
				map("n", "<leader>hS", gs.stage_buffer)
				map("n", "<leader>ha", gs.stage_hunk)
				map("n", "<leader>hu", gs.undo_stage_hunk)
				map("n", "<leader>hR", gs.reset_buffer)
				map("n", "<leader>hp", gs.preview_hunk)
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end)
				map("n", "<leader>tB", gs.toggle_current_line_blame)
				map("n", "<leader>hd", gs.diffthis)
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end)

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
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
}
