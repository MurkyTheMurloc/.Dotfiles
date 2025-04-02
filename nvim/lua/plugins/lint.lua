return {
    "mfussenegger/nvim-lint",
    event = {
        "BufReadPre",
        "BufNewFile"
    },
    config = function()
        local lint = require("lint")

        -- Helper function for running shell commands with error handling
        local function run_command(cmd)
            local success, _, exit_code = os.execute(cmd)
            if not success or exit_code ~= 0 then
                vim.notify("Error running: " .. cmd, vim.log.levels.ERROR)
            end
        end

        -- Mapping of linter names to config file patterns
        local linter_config_files = {
            biomejs = "biome.*",
            deno = "deno.*",
            eslint_d = "eslint.*"
        }

        -- Searches upward in the directory tree for a matching config file
        local function find_config_file(pattern)
            local found = vim.fs.find(pattern, { upward = true, stop = vim.loop.os_homedir() })
            return #found > 0
        end

        -- Determines which linter to use based on the presence of config files
        local function determine_linters(filetype)
            for linter, config_pattern in pairs(linter_config_files) do
                if find_config_file(config_pattern) then
                    return { linter } -- Return immediately with the detected linter
                end
            end
            return { "deno" } -- Default to Deno if no config is found
        end

        -- Append the linter name to each diagnostic message
        local function add_linter_name_to_diagnostics(linter_name)
            return function(diagnostic)
                diagnostic.message = string.format("%s: %s", linter_name, diagnostic.message)
                return diagnostic
            end
        end

        -- Wrap each linter to include the linter name in its diagnostic messages
        for linter, linter_name in pairs({
            eslint_d = "eslint",
            biomejs = "biome",
            deno = "deno"
        }) do
            lint.linters[linter] = require("lint.util").wrap(
                lint.linters[linter],
                add_linter_name_to_diagnostics(linter_name)
            )
        end

        -- Dynamically determine linters for the given filetype
        lint.linters_by_ft = setmetatable({}, {
            __index = function(_, filetype)
                return determine_linters(filetype)
            end
        })

        -- Custom fix function for Deno
        local function deno_fix(bufnr)
            local file_path = vim.api.nvim_buf_get_name(bufnr)
            local deno_cmd = string.format("deno lint --fix %s", vim.fn.shellescape(file_path))
            run_command(deno_cmd)
            if vim.api.nvim_buf_is_loaded(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("checktime")
                    vim.cmd("silent! edit!")
                end)
            end
        end

        -- Custom fix function for Biome
        local function biome_fix(bufnr)
            local file_path = vim.api.nvim_buf_get_name(bufnr)
            local biome_cmd = string.format("biome lint --write %s", vim.fn.shellescape(file_path))
            run_command(biome_cmd)
            if vim.api.nvim_buf_is_loaded(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("checktime")
                    vim.cmd("silent! edit!")
                end)
            end
        end

        -- Assign fix functions to the corresponding linters
        lint.linters.deno.fix = deno_fix
        lint.linters.biomejs.fix = biome_fix
        lint.linters.eslint_d.fix = function(bufnr)
            local file_path = vim.api.nvim_buf_get_name(bufnr)
            local eslint_cmd = string.format("eslint_d --fix %s", vim.fn.shellescape(file_path))
            run_command(eslint_cmd)
            if vim.api.nvim_buf_is_loaded(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("checktime")
                    vim.cmd("silent! edit!")
                end)
            end
        end

        -- Create an autocommand group for linting events
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end
        })

        -- Keymap to manually trigger the fix command for the current file
        vim.keymap.set("n", "<leader>lf", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local filetype = vim.bo.filetype

            -- Dynamically determine the linter(s) for the current filetype
            local linters = lint.linters_by_ft[filetype]
            if not linters or #linters == 0 then
                vim.notify("No linter configured for filetype: " .. filetype)
                return
            end

            -- Use the first active linter
            local linter = linters[1]
            if not lint.linters[linter] or not lint.linters[linter].fix then
                vim.notify("Fix function not implemented for linter: " .. linter)
                return
            end

            vim.notify("Running fix with linter: " .. linter)
            lint.linters[linter].fix(bufnr)
            vim.cmd("write")
        end, { desc = "Trigger lint fix for the current file" })
    end
}
