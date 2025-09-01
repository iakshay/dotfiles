return {
	"rmagatti/auto-session",
	lazy = false,
	enabled = true,

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		allowed_dirs = { "~/Projects/*", "~/worktrees/**" },
		-- log_level = 'debug',

		-- Session lens configuration for telescope integration
		session_lens = {
			buftypes_to_ignore = {},
			load_on_setup = true,
			previewer = false,
			picker_opts = {
				border = true,
			},
		},

		-- Auto save/restore session (new format)
		auto_save = true,
		auto_restore = true,

		-- Include globals in session (for DAP breakpoints)
		-- This works with the sessionoptions we set in init.lua
		pre_save_cmds = {
			function()
				-- Save DAP breakpoints as global variable
				if package.loaded["dap"] then
					_G.dap_breakpoints = require("dap.breakpoints").get()
				end
			end,
		},

		post_restore_cmds = {
			function()
				-- Restore DAP breakpoints from global variable
				if package.loaded["dap"] and _G.dap_breakpoints then
					local dap = require("dap")
					for bufnr, breakpoints in pairs(_G.dap_breakpoints) do
						for _, bp in ipairs(breakpoints) do
							dap.set_breakpoint(bufnr, bp.line, bp.condition, bp.log_message)
						end
					end
					_G.dap_breakpoints = nil -- Clean up
				end
			end,
		},
	},
}
