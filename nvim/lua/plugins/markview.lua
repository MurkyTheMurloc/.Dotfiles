-- For `plugins/markview.lua` users.
return {
	"OXY2DEV/markview.nvim",
	lazy = true,

	-- For `nvim-treesitter` users.
	priority = 49,

	-- For blink.cmp's completion
	-- source
	dependencies = {
		"saghen/blink.cmp"
	},
};
