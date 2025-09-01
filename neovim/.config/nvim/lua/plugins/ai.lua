return {
	{
		"github/copilot.vim",
		enabled = false,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		enabled = true,
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
						accept_word = false,
						accept_line = false,
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				panel = { enabled = false },
				filetypes = {
					markdown = true,
					yaml = true,
					gitcommit = true,
				},
				workspace_folders = {
					"~/Projects/smithdb",
					"~/Projects/datafusion",
				},
			})
		end,
		keys = {
			{
				"<leader>ct",
				function()
					require("copilot.suggestion").toggle_auto_trigger()
				end,
				desc = "Toggle Copilot auto trigger",
			},
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = false,
		opts = {
			show_help = "yes", -- Show help text for CopilotChatInPlace, default: yes
			debug = false, -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
			disable_extra_info = "no", -- Disable extra information (e.g: system prompt) in the response.
			language = "English", -- Copilot answer language settings when using default prompts. Default language is English.
			-- proxy = "socks5://127.0.0.1:3000", -- Proxies requests via https or socks.
			-- temperature = 0.1,
		},
		dependencies = {
			{ "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
			{ "nvim-lua/plenary.nvim" },
		},
		build = function()
			vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
		end,
		event = "VeryLazy",
		keys = {
			-- Show help actions with telescope
			{
				"<leader>cch",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.help_actions())
				end,
				desc = "CopilotChat - Help actions",
			},
			-- Show prompts actions with telescope
			{
				"<leader>ccp",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>ccp",
				":lua require('CopilotChat.actions').show_prompt_actions(true)<CR>",
				mode = "x",
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>cct",
				"<cmd>CopilotChatToggle<cr>",
				desc = "Toggle Copilot chat", -- Toggle vertical split
			},
			{
				"<leader>ccx",
				":CopilotChatInPlace<cr>",
				mode = "x",
				desc = "CopilotChat - Run in-place code",
			},
			{
				"<leader>ccr",
				"<cmd>CopilotChatReset<cr>", -- Reset chat history and clear buffer.
				desc = "CopilotChat - Reset chat history and clear buffer",
			},
		},
		config = function()
			require("CopilotChat").setup({
				window = {
					layout = "float",
				},
			})
		end,
	},
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		---@module 'avante'
		---@type avante.Config
		opts = {
			-- add any opts here
			-- this file can contain specific instructions for your project
			-- instructions_file = "avante.md",
			-- for example
			provider = "claude",
			providers = {
				-- claude = {
				-- 	-- api_
				-- 	endpoint = "https://api.anthropic.com",
				-- 	model = "claude-sonnet-4-20250514",
				-- 	timeout = 30000, -- Timeout in milliseconds
				-- 	extra_request_body = {
				-- 		temperature = 0.75,
				-- 		max_tokens = 20480,
				-- 	},
				-- },
				-- moonshot = {
				-- 	endpoint = "https://api.moonshot.ai/v1",
				-- 	model = "kimi-k2-0711-preview",
				-- 	timeout = 30000, -- Timeout in milliseconds
				-- 	extra_request_body = {
				-- 		temperature = 0.75,
				-- 		max_tokens = 32768,
				-- 	},
				-- },
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
}
