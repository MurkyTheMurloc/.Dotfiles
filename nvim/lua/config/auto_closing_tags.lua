local M = {}

-- tags we never auto-remove
local skip = {
	slot               = true,
	Fragment           = true,
	["astro-fragment"] = true,
	head               = true,
	style              = true,
}

-- strip off attributes and brackets, return bare name
local function get_name(tag)
	return tag:match("^</?%s*([%w:-]+)")
end

-- Given a buffer, a tag name, and the zero-based row where you just
-- turned <Tag> into <Tag/>, scan forward and delete exactly the matching </Tag>.
local function remove_matching_closer(bufnr, tag_name, self_row)
	if skip[tag_name] then return end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local depth = 0
	-- scan from the line *after* your self-close:
	for line_idx = self_row + 2, #lines do
		local line = lines[line_idx]

		-- count any new "<Tag ...>" openings (but not self-closing "<Tag/>")
		for _ in line:gmatch("<%s*" .. tag_name .. "%s*[^/>]->") do
			depth = depth + 1
		end

		-- look for a closing "</Tag>"
		if line:find("</%s*" .. tag_name .. "%s*>") then
			if depth == 0 then
				-- this is *the* closer we want to delete
				local cleaned = line:gsub("</%s*" .. tag_name .. "%s*>", "", 1)
				vim.api.nvim_buf_set_lines(bufnr, line_idx - 1, line_idx, false, { cleaned })
				return
			else
				-- that closer belonged to a nested opener; skip it
				depth = depth - 1
			end
		end
	end
end

function M.process_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local all = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for idx, line in ipairs(all) do
		-- for each self-closing "<Tag .../>" on this line:
		for tag in line:gmatch("<%s*[%w:-]+.-/>") do
			local name = get_name(tag)
			if name then
				remove_matching_closer(bufnr, name, idx - 1)
			end
		end
	end
end

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = { "*.html", "*.jsx", "*.tsx", "*.astro" },
	callback = function()
		local line = vim.api.nvim_get_current_line()
		if not line:match("/>%s*$") then
			return
		end
		M.process_buffer()
	end,
})

return M
