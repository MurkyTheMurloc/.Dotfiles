local M = {}
function M.get_structure_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.fn.col(".")        -- 1-basierter Cursor
	local s, e
	local patterns = { "%b[]", "%b{}" } -- zuerst Array, dann Dictionary

	for _, pat in ipairs(patterns) do
		local start_idx = 1
		while true do
			s, e = string.find(line, pat, start_idx)
			if not s then break end
			if col >= s and col <= e then
				return string.sub(line, s, e)
			end
			start_idx = e + 1
		end
	end

	-- Fallback: aktuelles Wort
	return vim.fn.expand("<cword>")
end

return M
