return {
	"piersolenski/wtf.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		openai_api_key =
		"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",
		openai_model_id = "gpt-4o-mini",
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
