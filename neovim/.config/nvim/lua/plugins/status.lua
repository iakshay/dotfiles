---@type LazySpec[]
return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local function format_branch(branch)
				if vim.fn.winwidth(0) > 100 and branch and branch ~= "" then
					-- Find the last occurrence of '/'
					local last_slash = branch:match(".*/()")
					-- If found, return the substring after it, otherwise return the whole branch name
					return last_slash and branch:sub(last_slash) or branch
				end
				return ""
			end

			require("lualine").setup({
				options = {
					disabled_filetypes = {
						statusline = {
							"neo-tree",
							"neotest-summary",
							"NvimTree",
							"Outline",
							"startify",
							"dashboard",
							"packer",
						},
						winbar = {},
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{ "branch", fmt = format_branch },
						"diff",
						"diagnostics",
					},
					lualine_c = { { "filename", file_status = true, path = 1 } },
					lualine_x = {},
					-- lualine_x = {'encoding', 'fileformat', 'filetype'},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})
		end,
	},
}
