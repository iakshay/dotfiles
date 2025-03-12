return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "sql",
			callback = function()
				-- Set the commentstring for SQL
				vim.opt_local.commentstring = "-- %s" -- Change to your desired comment format
			end,
		})
	
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dbui",
			callback = function()
				if vim.g.loaded_dadbod then
					pcall(function()
						vim.cmd("DBUIHideNotifications")
					end)
				end
				vim.bo.shiftwidth = 2 -- Set shiftwidth to 2 for dbui files
				vim.bo.tabstop = 2 -- Optionally set tabstop to match shiftwidth
				vim.bo.expandtab = true -- Use spaces instead of tabs
			end,
		})

		-- mapping
		vim.keymap.set({ "n", "v" }, "\\d", "<cmd>DBUIToggle<CR>")
	end,
}
