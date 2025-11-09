-- Lokale Funktion: Finde den ESLint-Root für eine Datei
local function find_eslint_root(file_path)
	local startpath = vim.fs.dirname(file_path)
	local config_files = { ".eslintrc.json", ".eslintrc.js", ".eslintrc.cjs", "eslint.config.js", "eslint.config.ts" }

	-- Suche nach ESLint-Konfigurationsdateien
	local found = vim.fs.find(config_files, {
		upward = true,
		path = startpath,
		type = "file",
	})

	if #found > 0 then
		return vim.fs.dirname(found[1]), found[1] -- Rückgabe von Root und gefundener Konfig-Datei
	end

	-- Fallback: Suche nach package.json mit eslintConfig
	found = vim.fs.find({ "package.json" }, {
		upward = true,
		path = startpath,
		type = "file",
	})

	if #found > 0 then
		local package_json_path = found[1]
		local ok, package_json = pcall(vim.fn.json_decode, vim.fn.readfile(package_json_path))
		if ok and package_json and package_json.eslintConfig then
			return vim.fs.dirname(package_json_path), package_json_path
		end
	end

	-- Fallback: Suche nach .git
	found = vim.fs.find({ ".git" }, {
		upward = true,
		path = startpath,
		type = "directory",
	})

	if #found > 0 then
		return vim.fs.dirname(found[1]), nil
	end

	-- Letzter Fallback: nil, um ESLint die Root-Suche selbst übernehmen zu lassen
	return nil, nil
end

return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		local lint = require("lint")

		local function run_command(cmd, cwd)
			local handle = io.popen("cd " .. vim.fn.shellescape(cwd or vim.fn.getcwd()) .. " && " .. cmd .. " 2>&1")
			local result = handle:read("*a")
			local success = handle:close()
			if not success then
				vim.notify("Error running: " .. cmd .. "\n" .. result, vim.log.levels.ERROR)
			end
			return success
		end

		local linter_config_files = {
			biomejs = { "biome.json", "biome.jsonc" },
			deno = { "deno.json", "deno.jsonc" },
			eslint_d = { ".eslintrc.json", ".eslintrc.js", ".eslintrc.cjs", "eslint.config.js", "eslint.config.ts" },
		}

		local function has_config_file(config_names)
			local buf_path = vim.api.nvim_buf_get_name(0)
			local startpath = vim.fs.dirname(buf_path)
			local found = vim.fs.find(config_names, {
				upward = true,
				path = startpath,
				type = "file",
			})
			return #found > 0
		end

		local function determine_linters(filetype)
			local detected = {}

			for linter, config_files in pairs(linter_config_files) do
				if has_config_file(config_files) then
					table.insert(detected, linter)
				end
			end

			if #detected == 0 then
				return { "deno" } -- Fallback
			end

			return detected
		end

		local function add_linter_name_to_diagnostics(name)
			return function(diagnostic)
				diagnostic.message = string.format("%s: %s", name, diagnostic.message)
				return diagnostic
			end
		end

		for linter, name in pairs({
			eslint_d = "eslint",
			biomejs = "biome",
			deno = "deno",
		}) do
			lint.linters[linter] = require("lint.util").wrap(
				lint.linters[linter],
				add_linter_name_to_diagnostics(name)
			)
		end

		lint.linters_by_ft = setmetatable({}, {
			__index = function(_, filetype)
				return determine_linters(filetype)
			end,
		})

		vim.defer_fn(function()
			-- Dynamisch Mason-Pfad oder System-Pfad verwenden
			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

			lint.linters.deno.fix = function(bufnr)
				local file_path = vim.api.nvim_buf_get_name(bufnr)
				local deno = mason_bin .. "/deno"
				if vim.fn.filereadable(deno) == 0 then
					deno = "deno" -- Fallback auf globales Deno
				end
				local cmd = string.format("%s lint --fix %s", deno, vim.fn.fnameescape(file_path))
				if run_command(cmd, vim.fn.getcwd()) then
					vim.cmd("checktime | silent! edit!")
				end
			end

			lint.linters.biomejs.fix = function(bufnr)
				local file_path = vim.api.nvim_buf_get_name(bufnr)
				local biome = mason_bin .. "/biome"
				if vim.fn.filereadable(biome) == 0 then
					biome = "biome" -- Fallback auf globales Biome
				end
				local cmd = string.format("%s lint --write %s", biome, vim.fn.fnameescape(file_path))
				if run_command(cmd, vim.fn.getcwd()) then
					vim.cmd("checktime | silent! edit!")
				end
			end

			lint.linters.eslint_d.fix = function(bufnr)
				local file_path = vim.api.nvim_buf_get_name(bufnr)
				local eslint = mason_bin .. "/eslint_d"
				if vim.fn.filereadable(eslint) == 0 then
					eslint = "eslint_d" -- Fallback auf globales eslint_d
				end
				local root_dir, config_file = find_eslint_root(file_path)
				local cmd = string.format(
					"%s --fix %s%s",
					eslint,
					vim.fn.fnameescape(file_path),
					config_file and " --config " .. vim.fn.fnameescape(config_file) or ""
				)
				if run_command(cmd, root_dir or vim.fn.getcwd()) then
					vim.cmd("checktime | silent! edit!")
				end
			end
		end, 0)

		local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				local buf_path = vim.api.nvim_buf_get_name(0)
				if buf_path == "" then return end -- Skip für leere Buffer
				local root_dir = find_eslint_root(buf_path)
				local opts = {
					cwd = root_dir,
					ignore_errors = true,
				}
				lint.try_lint(nil, opts)
			end,
		})

		vim.keymap.set("n", "<leader>lf", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local filetype = vim.bo.filetype
			local linters = lint.linters_by_ft[filetype]

			if not linters or #linters == 0 then
				vim.notify("No linter configured for filetype: " .. filetype, vim.log.levels.WARN)
				return
			end

			local ran_any = false
			local buf_path = vim.api.nvim_buf_get_name(bufnr)
			local root_dir = find_eslint_root(buf_path)

			for _, linter in ipairs(linters) do
				local fixer = lint.linters[linter] and lint.linters[linter].fix
				if fixer then
					vim.notify("Running fix with linter: " .. linter, vim.log.levels.INFO)
					fixer(bufnr, root_dir) -- Passe root_dir an fixer-Funktion weiter
					ran_any = true
				else
					vim.notify("Fix not implemented for: " .. linter, vim.log.levels.WARN)
				end
			end

			if ran_any then
				vim.cmd("write")
			end
		end, { desc = "Fix all linters configured for this file" })
	end,
}
