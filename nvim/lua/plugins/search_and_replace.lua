return {

	{
		"cshuaimin/ssr.nvim",
		-- Optional: only load when you require "ssr"
		lazy = true,
		-- event = "VeryLazy", -- Alternatively, use an event if you want it to load on startup
		config = function()
			require("ssr").setup {
				border = "rounded",
				min_width = 50,
				min_height = 5,
				max_width = 80,
				max_height = 25,
				adjust_window = true,
				keymaps = {
					close = "q",
					next_match = "n",
					prev_match = "N",
					replace_confirm = "<cr>",
					replace_all = "<leader><cr>",
				},
			}

			vim.keymap.set({ "n", "x" }, "<leader>sr", function() require("ssr").open() end, { desc = "Structural Replace" })
		end,
	}
}
