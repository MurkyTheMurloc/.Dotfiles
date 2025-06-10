return {
	{
		"youyoumu/pretty-ts-errors.nvim",
		opts = {
			executable = "/Users/paulbose/.local/share/pnpm/bin/pretty-ts-errors-markdown", -- Path to the executable
			float_opts = {
				border = "rounded",                                                        -- Border style for floating windows
				max_width = 80,                                                            -- Maximum width of floating windows
				max_height = 20,                                                           -- Maximum height of floating windows
				wrap = false,                                                              -- Whether to wrap long lines
			},
			auto_open = true,                                                            -- Automatically show errors on hover
		},
		config = function()
			local pte = require("pretty-ts-errors")

			-- Show error under cursor
			vim.keymap.set('n', '<leader>te', function()
				pte.show_formatted_error()
			end, { desc = "Show TS error" })

			-- Show all errors in file
			vim.keymap.set('n', '<leader>tE', function()
				pte.open_all_errors()
			end, { desc = "Show all TS errors" })

			-- Toggle auto-display
			vim.keymap.set('n', '<leader>tt', function()
				pte.toggle_auto_open()
			end, { desc = "Toggle TS error auto-display" })
		end,
	},
}
