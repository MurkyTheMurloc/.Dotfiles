
return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    local lint = require("lint")

    local linter_config_files = {
      biomejs = "biome.json",
      eslint_d = ".eslintrc.*", -- Match .eslintrc.js, .eslintrc.json, etc.
      deno = "deno.json",
      eslint_d = "eslint.*"
    }

    local function find_config_file(pattern)
      local cwd = vim.fn.getcwd()
      local found_files = vim.fn.glob(cwd .. "/" .. pattern, true, true)
      if #found_files > 0 then
        return true
      else
        return false
      end
    end

  local function determine_linters(filetype)
  for linter, config_patterns in pairs(linter_config_files) do
    if find_config_file(config_patterns) then
      return { linter } -- Return immediately with the detected linter
    end
  end
  return { "deno" } -- Default to Deno if no config is found
end
-- Add linter names to diagnostic messages
local function add_linter_name_to_diagnostics(linter_name)
  return function(diagnostic)
    diagnostic.message = string.format("%s: %s", linter_name, diagnostic.message)
    return diagnostic
  end
end

-- Wrap linters to include the linter name in diagnostics
for linter, linter_name in pairs({
  eslint_d = "eslint",
  biomejs = "biome",
  deno = "deno",
}) do
  lint.linters[linter] = require("lint.util").wrap(
    lint.linters[linter],
    add_linter_name_to_diagnostics(linter_name)
  )
end

    lint.linters_by_ft = {
      javascript = determine_linters("javascript"),
      typescript = determine_linters("typescript"),
      javascriptreact = determine_linters("javascriptreact"),
      typescriptreact = determine_linters("typescriptreact"),
      svelte = determine_linters("svelte"),
      astro = determine_linters("astro"),
      go = { "golangcilint" },
      rust = { "clippy" },
      python = { "pylint" },
    }

    -- Custom fix functions
    local function deno_fix(bufnr)
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      local deno_cmd = string.format("deno lint --fix %s", vim.fn.shellescape(file_path))
      local result = os.execute(deno_cmd)

      -- Reload buffer after fixing
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("checktime")
          vim.cmd("silent! edit!")
        end)
      end
    end

    local function biome_fix(bufnr)
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      local biome_cmd = string.format("biome format %s", vim.fn.shellescape(file_path))
      local result = os.execute(biome_cmd)

      -- Reload buffer after fixing
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("checktime")
          vim.cmd("silent! edit!")
        end)
      end
    end

    lint.linters.deno.fix = deno_fix
    lint.linters.biomejs.fix = biome_fix
    lint.linters.eslint_d.fix = function(bufnr)
      local file_path = vim.api.nvim_buf_get_name(bufnr)
      local eslint_cmd = string.format("eslint_d --fix %s", vim.fn.shellescape(file_path))
      local result = os.execute(eslint_cmd)

      -- Reload the buffer after fixing
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("checktime")
          vim.cmd("silent! edit!")
        end)
      end
    end

    -- Auto group for linting events
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Keymap to manually trigger fixing
    vim.keymap.set("n", "<leader>lf", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local filetype = vim.bo.filetype

      -- Determine the linter(s) for the current filetype
      local linters = lint.linters_by_ft[filetype]
      if not linters or #linters == 0 then
        vim.notify("No linter configured for filetype:", filetype)
        return
      end

      -- Use the first active linter
      local linter = linters[1]
      if not lint.linters[linter] or not lint.linters[linter].fix then
        vim.notify("Fix function not implemented for linter:", linter)
        return
      end

      vim.notify("Running fix with linter:", linter)
      lint.linters[linter].fix(bufnr)

      -- Trigger file save after fixing
      vim.cmd("write")
    end, { desc = "Trigger lint fix for the current file" })

  
  end,
}

