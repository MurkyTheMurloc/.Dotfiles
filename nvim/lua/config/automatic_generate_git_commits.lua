
-- Create a file in ~/.config/nvim/lua/git_auto_commit.lua

local M = {}

-- Function to generate a best practice commit message
local function generate_commit_message()
  local diff = vim.fn.system('git diff --name-status')
  local lines = vim.split(diff, '\n')
  local changes = {
    add = {},
    fix = {},
    delete = {},
    other = {}
  }

  -- Parse the diff output to categorize the changes
  for _, line in ipairs(lines) do
    local status, file = line:match("([A-Z])\t(.+)")
    if status == "A" then
      table.insert(changes.add, file)
    elseif status == "M" then
      table.insert(changes.fix, file)
    elseif status == "D" then
      table.insert(changes.delete, file)
    else
      table.insert(changes.other, file)
    end
  end

  -- Create commit message parts for each category
  local commit_message_parts = {}

  if #changes.add > 0 then
    table.insert(commit_message_parts, "add: " .. table.concat(changes.add, ", "))
  end
  if #changes.fix > 0 then
    table.insert(commit_message_parts, "fix: " .. table.concat(changes.fix, ", "))
  end
  if #changes.delete > 0 then
    table.insert(commit_message_parts, "delete: " .. table.concat(changes.delete, ", "))
  end
  if #changes.other > 0 then
    table.insert(commit_message_parts, "other: " .. table.concat(changes.other, ", "))
  end

  -- Return the final commit message
  return table.concat(commit_message_parts, "; ")
end

-- Function to check if there are changes to commit
local function has_changes()
  -- Check if there are any unstaged changes
  local result = vim.fn.system('git diff --quiet')
  return vim.v.shell_error ~= 0
end

-- Function to check if we're in a Git repository
local function is_git_repo()
  local git_status = vim.fn.system('git rev-parse --is-inside-work-tree')
  return vim.trim(git_status) == "true"
end

-- Function to perform the git commit
local function auto_commit()
  -- Ensure we're inside a Git repo
  if not is_git_repo() then
    print("Not inside a Git repository.")
    return
  end

  -- Ensure there are changes to commit
  if not has_changes() then
    print("No changes to commit.")
    return
  end

  -- Generate commit message
  local commit_message = generate_commit_message()

  -- Stage all changes and commit
  vim.fn.system('git add .')
  vim.fn.system('git commit -m "' .. commit_message .. '"')

  print("Git commit completed.")
end

-- Set the auto commit on VimLeave event
function M.setup()
  vim.api.nvim_create_autocmd('VimLeave', {
    callback = function()
      auto_commit()
    end,
  })
end

return M

