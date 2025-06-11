return {
	'nvim-telescope/telescope.nvim',
	lazy = "VeryLazy",
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		'nvim-telescope/telescope-frecency.nvim',
		'neovim/nvim-lspconfig',
		'rcarriga/nvim-notify',     -- Add notify as a dependency
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>fm",
			function()
				require("telescope").extensions.notify.notify()
			end,
			desc = "View Notification History",
		},
	},
	opts = {
		defaults = {
			layout_strategy = 'vertical',
			layout_config = {
				mirror = false,
			},
			find_command = {
				'fd',
				'--type', 'f',
				'--hidden',
				'--exclude', '.git',
				'--exclude', 'node_modules',
				'--follow',
				'--no-ignore-vcs',
			},
			hidden = true,
			file_ignore_patterns = { "%.git/", "node_modules" },
			extensions = {
				fzf = {},
			},
		},
	},
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)

		-- Load extensions
		telescope.load_extension("fzf")
		telescope.load_extension("frecency")
		telescope.load_extension("notify")     -- Load notify extension



		-- Telescope keybindings
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions,
			{ noremap = true, silent = true, desc = "Go to definition" })
		vim.keymap.set("n", "leader<gr>", builtin.lsp_references,
			{ noremap = true, silent = true, desc = "Find references" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>f.", builtin.resume, { noremap = true, silent = true })
	end,
}
