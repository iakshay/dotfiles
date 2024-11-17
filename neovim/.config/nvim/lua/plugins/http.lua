return {
	{
		"mistweaverco/kulala.nvim",
		ft = "http",
		keys = {
			{ "<leader>R", "", desc = "+Rest", ft = "http" },
			{ "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad", ft = "http" },
			{ "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
			{ "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
			{
				"<leader>Rg",
				"<cmd>lua require('kulala').download_graphql_schema()<cr>",
				desc = "Download GraphQL schema",
				ft = "http",
			},
			{ "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
			{ "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
			{
				"<leader>Rp",
				"<cmd>lua require('kulala').jump_prev()<cr>",
				desc = "Jump to previous request",
				ft = "http",
			},
			{ "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" },
			{ "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request", ft = "http" },
			{ "<leader>rr", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
			{ "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
			{ "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
		},
		opts = {},
	},
	-- {
	-- 	"rest-nvim/rest.nvim",
	-- 	dependencies = {
	-- 		{ "nvim-lua/plenary.nvim" },
	-- 	},
	-- 	ft = { "http" },
	-- 	cmd = { "Rest" },
	-- 	keys = {
	-- 		{ "<leader>rr", "<cmd>Rest run<cr>", mode = "n", desc = "HTTP request under cursor" },
	-- 	},
	-- 	config = function()
	-- 		-- first load extension
	-- 		require("telescope").load_extension("rest")
	-- 		-- then use it, you can also use the `:Telescope rest select_env` command
	-- 		-- require("telescope").extensions.rest.select_env()
	-- 		vim.g.rest_nvim = {
	-- 			-- Open request results in a horizontal split
	-- 			result_split_horizontal = false,
	-- 			-- Keep the http file buffer above|left when split horizontal|vertical
	-- 			result_split_in_place = false,
	-- 			-- stay in current windows (.http file) or change to results window (default)
	-- 			stay_in_current_window_after_split = false,
	-- 			-- Skip SSL verification, useful for unknown certificates
	-- 			skip_ssl_verification = false,
	-- 			-- Encode URL before making request
	-- 			encode_url = true,
	-- 			-- Highlight request on run
	-- 			highlight = {
	-- 				enabled = true,
	--
	-- 				timeout = 150,
	-- 			},
	-- 			result = {
	-- 				-- toggle showing URL, HTTP info, headers at top the of result window
	-- 				show_url = true,
	-- 				-- show the generated curl command in case you want to launch
	-- 				-- the same request via the terminal (can be verbose)
	-- 				show_curl_command = false,
	-- 				show_http_info = true,
	-- 				show_headers = true,
	-- 				-- table of curl `--write-out` variables or false if disabled
	-- 				-- for more granular control see Statistics Spec
	-- 				show_statistics = false,
	-- 				-- executables or functions for formatting response body [optional]
	-- 				-- set them to false if you want to disable them
	-- 				-- formatters = {
	-- 				-- 	json = "jq",
	-- 				-- 	html = function(body)
	-- 				-- 		return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
	-- 				-- 	end,
	-- 				-- },
	-- 			},
	-- 			-- Jump to request line on run
	-- 			jump_to_request = false,
	-- 			env_file = ".env",
	-- 			custom_dynamic_variables = {},
	-- 			yank_dry_run = true,
	-- 			search_back = true,
	-- 		}
	-- 		-- 	    vim.api.nvim_set_keymap("n", "<leader>rr", '<cmd>lua require("rest-nvim").run()<CR>', { noremap = true, silent = true })
	-- 		-- vim.api.nvim_set_keymap(
	-- 		-- 	"n",
	-- 		-- 	"<leader>rl",
	-- 		-- 	'<cmd>lua require("rest-nvim").last()<CR>',
	-- 		-- 	{ noremap = true, silent = true }
	-- 		-- )
	-- 		-- vim.api.nvim_set_keymap(
	-- 		-- 	"n",
	-- 		-- 	"<leader>rp",
	-- 		-- 	'<cmd>lua require("rest-nvim").preview()<CR>',
	-- 		-- 	{ noremap = true, silent = true }
	-- 		-- )
	-- 		-- vim.api.nvim_set_keymap("n", "<leader>re", '<cmd>lua require("rest-nvim").env()<CR>', { noremap = true, silent = true })
	-- 		--
	-- 		-- vim.api.nvim_create_autocmd('FileType', {
	-- 		--       pattern = 'http',
	-- 		--       callback = function()
	-- 		--         vim.cmd [[command! RunHttp :lua require('rest-nvim').run()]]
	-- 		--         vim.keymap.set('n', '<CR>', rest_nvim.run, { buffer = true })
	-- 		--       end,
	-- 		--     })
	-- 	end,
	-- },
}
