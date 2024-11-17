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

		local augroup = vim.api.nvim_create_augroup("DBUIOpened", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			pattern = "DBUIOpened",
			callback = function()
				vim.opt.number = true
				vim.opt.relativenumber = true
				vim.cmd("call search('sunrise')")
				vim.cmd("norm o")
				vim.cmd("call search('Schemas')")
				vim.cmd("norm o")

				vim.cmd("call search('shared')")
				vim.cmd("norm o")

				vim.cmd("call search('tenant_default')")
				vim.cmd("norm o")
			end,
			group = augroup,
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
