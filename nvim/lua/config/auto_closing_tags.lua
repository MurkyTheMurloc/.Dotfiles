local M = {}

-- Tags we should NOT auto-remove, even if they are made self-closing
local skip_closing_removal = {
	slot = true,
	Fragment = true,
	["astro-fragment"] = true,
	head = true,
	style = true,
}

local function extract_tag_name(tag_text)
	return tag_text:match("<%s*/?%s*([%w:-]+)")
end

local function remove_closing_tag(bufnr, tag_name, start_row)
	if skip_closing_removal[tag_name] then return end

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, -1, false)
	local closing_tag_pattern = "</%s*" .. tag_name .. "%s*>"

	for i, line in ipairs(lines) do
		local line_number = start_row + i - 1
		if line:match(closing_tag_pattern) then
			local new_line = line:gsub(closing_tag_pattern, "", 1)
			vim.api.nvim_buf_set_lines(bufnr, line_number, line_number + 1, false, { new_line })
			break
		end
	end
end

function M.process_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for i, line in ipairs(lines) do
		for tag in line:gmatch("<%s*[%w:-]+.-/>") do
			local tag_name = extract_tag_name(tag)
			if tag_name then
				remove_closing_tag(bufnr, tag_name, i - 1)
			end
		end
	end
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	pattern = { "*.html", "*.jsx", "*.tsx", "*.astro" },
	callback = function()
		M.process_buffer()
	end,
})

return M
