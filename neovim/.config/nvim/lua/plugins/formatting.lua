return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	config = function()
		-- Initialize autosave as enabled by default
		vim.g.conform_autosave_enabled = true
		
		require("conform").setup({
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Check if autosave is disabled globally or for this buffer
				if not vim.g.conform_autosave_enabled or vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end

				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				http = { "kulala-fmt" },
				python = {
					-- To fix auto-fixable lint errors.
					"ruff_fix",
					-- To run the Ruff formatter.
					"ruff_format",
					-- To organize the imports.
					"ruff_organize_imports",
				},
				rust = { "rustfmt" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				json = { "prettier" },
			},
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
		
		vim.api.nvim_create_user_command("FormatToggleAutosave", function()
			vim.g.conform_autosave_enabled = not vim.g.conform_autosave_enabled
			local status = vim.g.conform_autosave_enabled and "enabled" or "disabled"
			print("Conform autosave " .. status)
		end, {
			desc = "Toggle conform autosave on/off",
		})
	end,
}
