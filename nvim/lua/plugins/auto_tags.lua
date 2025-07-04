return {
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					-- Defaults
					enable_close = false,                  -- Auto close tags
					enable_rename = true,                  -- Auto rename pairs of tags
					enable_close_on_slash = true           -- Auto close on trailing </

				},
			})
		end,
	},
}
