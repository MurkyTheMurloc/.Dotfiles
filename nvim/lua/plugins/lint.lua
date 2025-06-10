return {
    "mfussenegger/nvim-lint",
    lazy = true,
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        local lint = require("lint")

        local function run_command(cmd)
            local success = os.execute(cmd)
            if not success then
                vim.notify("Error running: " .. cmd, vim.log.levels.ERROR)
            end
        end

        local linter_config_files = {
            biomejs = { "biome.json", "biome.jsonc" },
            deno = { "deno.json", "deno.jsonc" },
            eslint_d = { ".eslintrc.json", ".eslintrc.js", "eslint.config.js" },
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
                return { "deno" } -- fallback
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
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

            lint.linters.deno.fix = function(bufnr)
                local file_path = vim.api.nvim_buf_get_name(bufnr)
                local deno = mason_bin .. "/deno"
                if vim.fn.filereadable(deno) == 0 then
                    vim.notify("Deno binary not found: " .. deno, vim.log.levels.ERROR)
                    return
                end
                local cmd = string.format("%s lint --fix %s", deno, vim.fn.fnameescape(file_path))
                run_command(cmd)
                vim.cmd("checktime | silent! edit!")
            end

            lint.linters.biomejs.fix = function(bufnr)
                local file_path = vim.api.nvim_buf_get_name(bufnr)
                local biome = mason_bin .. "/biome"
                if vim.fn.filereadable(biome) == 0 then
                    vim.notify("Biome binary not found: " .. biome, vim.log.levels.ERROR)
                    return
                end
                local cmd = string.format("%s lint --write %s", biome, vim.fn.fnameescape(file_path))
                run_command(cmd)
                vim.cmd("checktime | silent! edit!")
            end

            lint.linters.eslint_d.fix = function(bufnr)
                local file_path = vim.api.nvim_buf_get_name(bufnr)
                local eslint = mason_bin .. "/eslint_d"
                if vim.fn.filereadable(eslint) == 0 then
                    vim.notify("eslint_d binary not found: " .. eslint, vim.log.levels.ERROR)
                    return
                end
                local cmd = string.format("%s --fix %s", eslint, vim.fn.fnameescape(file_path))
                run_command(cmd)
                vim.cmd("checktime | silent! edit!")
            end
        end, 0)

        local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })


        vim.keymap.set("n", "<leader>lf", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local filetype = vim.bo.filetype
            local linters = lint.linters_by_ft[filetype]

            if not linters or #linters == 0 then
                vim.notify("No linter configured for filetype: " .. filetype)
                return
            end

            local ran_any = false

            for _, linter in ipairs(linters) do
                local fixer = lint.linters[linter] and lint.linters[linter].fix
                if fixer then
                    vim.notify("Running fix with linter: " .. linter)
                    fixer(bufnr)
                    ran_any = true
                else
                    vim.notify("Fix not implemented for: " .. linter)
                end
            end

            if ran_any then
                vim.cmd("write")
            end
        end, { desc = "Fix all linters configured for this file" })
    end,
}
