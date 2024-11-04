---@type LazySpec[]
return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		command = function()
			require("lualine").setup({})
		end,
	},
}
