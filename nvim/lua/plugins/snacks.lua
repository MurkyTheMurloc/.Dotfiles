local function diagnostics_all(config)
	local orig = Snacks.picker.diagnostics
	local diags = {}

	-- Alle aktiven LSP-Clients durchgehen
	for _, client in ipairs(vim.lsp.get_active_clients()) do
		-- Buffers, die zum Client gehören
		for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
			for _, d in ipairs(vim.diagnostic.get(buf)) do
				d.bufnr = buf
				table.insert(diags, d)
			end
		end
	end

	orig(vim.tbl_extend("force", config or {}, { items = diags }))
end

return {
	"folke/snacks.nvim",
	dependencies = { "folke/todo-comments.nvim" },
	priority = 1000,
	event = "VeryLazy",
	lazy = false,
	---@module "snacks"
	---@type snacks.Config
	opts = {
		indent = { enabled = true, },
		picker = { enabled = true },
		input = { enabled = true },
		rename = { enabled = true },
		words = { enabled = true },
		statuscolumn = {
			enabled = true,
			left = { "mark", "sign" },
			right = { "fold", "git" },
			folds = {
				open = false, -- show open fold icons
				git_hl = true, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "MiniDiffSign" },
			},
		},
	},
	init = function()
		-- Custom Picker für Monorepo Diagnostics (muss vor Keys definiert werden!)




		-- auch Keys nach ftplugins setzen, da viele [[ und ]] überschreiben
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				local buffer = vim.api.nvim_get_current_buf()
				vim.keymap.set(
					"n",
					"]]",
					function() require("snacks").words.jump(vim.v.count1) end,
					{ desc = "Next Reference", buffer = buffer }
				)
				vim.keymap.set(
					"n",
					"[[",
					function() require("snacks").words.jump(-vim.v.count1) end,
					{ desc = "Previous Reference", buffer = buffer }
				)
			end,
		})
	end,
	keys = {
		-- Words
		{
			"]]",
			function() require("snacks").words.jump(vim.v.count1) end,
			desc = "Next Reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function() require("snacks").words.jump(-vim.v.count1) end,
			desc = "Previous Reference",
			mode = { "n", "t" },
		},

		-- Picker
		{ "<leader>fb", function() Snacks.picker.buffers() end,            desc = "Buffers" },
		{ "<leader>ff", function() Snacks.picker.files() end,              desc = "Files" },
		{ "<leader>fg", function() Snacks.picker.grep() end,               desc = "Grep" },
		{ "<leader>fc", function() Snacks.picker.colorschemes() end,       desc = "Colorschemes" },
		{ "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
		{ "<leader>fD", function() Snacks.picker.diagnostics() end,        desc = "Project Diagnostics" },

		{ "<leader>fA", function() diagnostics_all() end,                  desc = "Monorepo Diagnostics" },

		{
			"<leader>fs",
			function() Snacks.picker.lsp_symbols() end,
			desc = "LSP Symbols",
		},
		{
			"<leader>fS",
			function() Snacks.picker.lsp_workspace_symbols() end,
			desc = "All LSP Symbols",
		},
		{
			"<leader>fr",
			function() Snacks.picker.lsp_references() end,
			nowait = true,
			desc = "References",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.todo_comments({ filter = { buf = 0 } })
			end,
			desc = "Buffer Todos",
		},
		{ "<leader>fT", function() Snacks.picker.todo_comments() end, desc = "Project Todos" },
		{ "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications" },
		{ "<leader>fu", function() Snacks.picker.undo() end,          desc = "Undo" },
		{ "<leader>f.", function() Snacks.picker.resume() end,        desc = "Resume" },
	},
}
