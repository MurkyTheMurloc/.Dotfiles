
local M = {}

local function get_last_modified_file()
  local handle = io.popen("find . -type f -not -path '*/\\.*' -exec stat -f '%m %N' {} + | sort -nr | head -n 1 | cut -d' ' -f2-")
  if handle then
    local result = handle:read("*a")
    handle:close()
   -- vim.notify("Found last modified file: " .. result, vim.log.levels.INFO) -- Debug log
    return result:match("^%s*(.-)%s*$") -- Trim whitespace
  end
  --vim.notify("No files found", vim.log.levels.WARN)
end

local function open_last_modified_file()
  local file = get_last_modified_file()

  -- If file is found, open it
  if file and file ~= "" then
  --  vim.notify("Opening file: " .. file, vim.log.levels.INFO)
    vim.cmd("e " .. vim.fn.fnameescape(file))
  else
   -- vim.notify("No last modified file found to open", vim.log.levels.WARN)
  end
end

function M.setup()
  -- Create an autocmd for VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local args = vim.fn.argv()
      local argc = vim.fn.argc()

     -- vim.notify("Arguments passed: " .. vim.inspect(args), vim.log.levels.DEBUG)
     -- vim.notify("Argument count: " .. argc, vim.log.levels.DEBUG)

      -- Check if no arguments or the argument is a directory
      if argc == 0 or (argc == 1 and vim.fn.isdirectory(args[1] or "") == 1) then
        -- Delay the opening of the last modified file slightly
        vim.defer_fn(function()
          -- Open the last modified file
         -- vim.notify("Opening last modified file...", vim.log.levels.INFO)
          open_last_modified_file()

          -- Disable netrw explicitly after opening the file
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
        end, 100) -- Delay for 100ms
      else
     --   vim.notify("Arguments passed, skipping re_open", vim.log.levels.INFO)
      end
    end,
  })

  -- Disable netrw explicitly only after everything else is loaded
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      --vim.notify("netrw disabled", vim.log.levels.INFO)
    end,
  })
end

return M
