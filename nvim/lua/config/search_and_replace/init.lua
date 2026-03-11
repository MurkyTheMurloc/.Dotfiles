local search = require("config.search_and_replace.search")
local replace = require("config.search_and_replace.replace")
local snacks = require("snacks.input")

local function file_replace()
	local current = search.get_structure_under_cursor()
	snacks.input({
		prompt = string.format("replace %s with:", current),
	}, function(replacement)
		if replacement and #replacement > 0 then
			replace.file_replace(current, replacement)
		end
	end)
end
local function project_replace()
	local current = search.get_structure_under_cursor()
	snacks.input({
		prompt = string.format("replace: %current with:", current),
	}, function(replacement)
		if replacement then
			replace.replace(current, replacement, "project")
		end
	end)
end
vim.keymap.set("n", "<leader>sr", file_replace, { desc = "File-wide Replace (ripgrep + Snacks)" })
vim.keymap.set("n", "<leader>sp", project_replace, { desc = "Project-wide Search & Replace" })
