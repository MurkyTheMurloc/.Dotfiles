return {
	"piersolenski/wtf.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		openai_api_key = "",
		openai_model_id = "gpt-4.5-turbo",
	},
	keys = {
		{
			"<leader>k",
			mode = { "n", "x" },
			function()
				require("wtf").ai()
			end,
			desc = "Debug diagnostic with AI",
		},
		{
			mode = { "n" },
			"<leader>ws",
			function()
				require("wtf").search()
			end,
			desc = "Search diagnostic with Google",
		},
		{
			mode = { "n" },
			"<leader>wh",
			function()
				require("wtf").history()
			end,
			desc = "Populate the quickfix list with previous chat history",
		},
		{
			mode = { "n" },
			"<leader>wg",
			function()
				require("wtf").grep_history()
			end,
			desc = "Grep previous chat history with Telescope",
		},
	},
}
