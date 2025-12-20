return {

	{
		"mfussenegger/nvim-dap",
		-- recommended = true,
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
		},
	  -- stylua: ignore
	keys = {
	  { "<leader>d", "", desc = "+debug", mode = {"n", "v"} },
	  { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
	  { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
	  { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
	  -- { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
	  { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
	  { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
	  { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
	  { "<leader>dj", function() require("dap").down() end, desc = "Down" },
	  { "<leader>dk", function() require("dap").up() end, desc = "Up" },
	  { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
	  { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
	  { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
	  { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
	  { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
	  { "<leader>ds", function() require("dap").session() end, desc = "Session" },
	  { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
	  { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
	  { "<leader>dv", "<cmd>DapVirtualTextToggle<cr>", desc = "Toggle Virtual Text" },
	},
		config = function()
			require("dapui").setup()
			
			-- Setup virtual text to show variable values inline
			require("nvim-dap-virtual-text").setup({
				enabled = true,                     -- enable this plugin (the default)
				enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
				highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
				highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
				show_stop_reason = true,            -- show stop reason when stopped for exceptions
				commented = false,                  -- prefix virtual text with comment string
				only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
				all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
				clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
				-- A callback that determines how a variable is displayed or whether it should be omitted
				display_callback = function(variable, buf, stackframe, node, options)
					if options.virt_text_pos == 'inline' then
						return ' = ' .. variable.value
					else
						return variable.name .. ' = ' .. variable.value
					end
				end,
				-- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
				virt_text_pos = 'eol',
			})
			
			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
			require("dap-python").setup("python")
			table.insert(require("dap").configurations.python, {
				type = "python",
				request = "attach",
				name = "configuration",
				mode = "remote",
				connect = {
					port = 5678,
					host = "0.0.0.0",
				},
				cwd = vim.fn.getcwd(),
				pathMappings = {
					{ localRoot = vim.fn.getcwd(), remoteRoot = "/app/" },
				},
				-- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
			})
			require("dap-python").resolve_python = function()
				return vim.fn.exepath("python")
			end

			-- Rust DAP configuration with codelldb
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.rust = {
				{
					name = "Launch",
					type = "codelldb",
					request = "launch",
					program = function()
						-- Try to find the binary in target/debug
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
				{
					name = "Attach to process",
					type = "codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					args = {},
				},
			}
-- stylua: ignore

			-- load mason-nvim-dap here, after all adapters have been setup

			-- for name, sign in pairs(LazyVim.config.icons.dap) do
			-- 	sign = type(sign) == "table" and sign or { sign }
			-- 	vim.fn.sign_define(
			-- 		"Dap" .. name,
			-- 		{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
			-- 	)
			-- end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end

			-- Extends dap.configurations with entries read from .vscode/launch.json
			if vim.fn.filereadable(".vscode/launch.json") then
				vscode.load_launchjs()
			end
		end,
	},
}
