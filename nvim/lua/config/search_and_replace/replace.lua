local M = {}

local function escape(str)
	return str:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "\\%1")
end

-- Replace mit ripgrep + sed (File)
function M.file_replace(pattern, replacement)
	local file = vim.fn.expand("%:p")
	local escaped_pattern = escape(pattern)
	local escaped_replacement = replacement:gsub("&", "\\&")

	-- Ripgrep nur, um zu prüfen, ob Match existiert
	local check_cmd = string.format("rg -q -F '%s' '%s'", pattern, file)
	local result = os.execute(check_cmd)
	if result == 0 then
		-- sed ersetzt direkt in der Datei
		local sed_cmd = string.format(
			"sed -i '' 's/%s/%s/g' '%s'",
			escaped_pattern,
			escaped_replacement,
			file
		)
		os.execute(sed_cmd)
		vim.cmd("edit")     -- Buffer reload
		print("File replaced successfully!")
	else
		print("No match found in current file.")
	end
end

return M
