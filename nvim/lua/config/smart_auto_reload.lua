local config_lua_dir = "/Users/paulbose/.config/nvim/lua/config"

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.lua",
	callback = function(args)
		local filepath = vim.fn.fnamemodify(args.file, ":p")
		local config_lua_dir = vim.fn.stdpath("config") .. "/lua/"

		if filepath:sub(1, #config_lua_dir) == config_lua_dir then
			-- touch the flag file
			vim.fn.writefile({ tostring(os.time()) }, reload_flag)
			vim.notify("Config changed. Flag set for reload.", vim.log.levels.INFO)
		end
	end,
})
