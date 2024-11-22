
return vim.api.nvim_create_autocmd("QuitPre", {
  pattern = "*",
  callback = function()
    local swap_dir = vim.fn.stdpath("state") .. "/swap/"
    local swap_files = vim.fn.glob(swap_dir .. "*.swp")
    
    -- Check if there are any swap files
    if swap_files ~= "" then
      -- If there are swap files, save all files before quitting
      vim.cmd("wa")
      print("All files saved due to existing swap files.")
    end
    
    -- Proceed with quitting
    vim.cmd("quit")
  end,
})




