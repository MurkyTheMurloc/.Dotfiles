return {
	{
		"Fildo7525/pretty_hover",
		event = "LspAttach",
		opts = {
			border       = "rounded",
			wrap         = true,
			max_width    = 70,
			max_height   = 20,
			toggle       = false,
			multi_server = true,
		},
		init = function()
			vim.keymap.set("n", "K", function()
				require("pretty_hover").hover()
			end, { desc = "Pretty Hover" })
		end,
	},
}
