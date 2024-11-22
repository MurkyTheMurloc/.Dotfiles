
-- ~/.config/nvim/lua/last_modified_file.lua
local M = {}

-- Function to find the last modified file in the current directory
M.open_last_modified_file = function()
  local cwd = vim.fn.getcwd()

  -- Get a list of files in the current directory, excluding directories
  local files = vim.fn.glob(cwd .. '/*', false, true)
  
  -- If there are no files in the directory, do nothing
  if #files == 0 then
    print("No files found in the current directory.")
    return
  end

  -- Sort files by modification time and get the most recent one
  table.sort(files, function(a, b)
    return vim.fn.getftime(b) < vim.fn.getftime(a)
  end)

  -- Open the last modified file
  local last_modified_file = files[1]
  if last_modified_file then
    vim.cmd("edit " .. last_modified_file)
  end
end

-- Function to check if we opened Neovim in a directory (not a file)
M.open_on_directory = function()
  local args = vim.fn.argv()
  -- If we opened Vim with a directory (`vim .`), open the last modified file in that directory
  if #args == 0 or (args[1] == "." and vim.fn.isdirectory(vim.fn.getcwd()) == 1) then
    M.open_last_modified_file()
  end
end

return M

