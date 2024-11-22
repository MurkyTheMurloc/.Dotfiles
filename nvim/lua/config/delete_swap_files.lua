
return  vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local swap_dir = vim.fn.stdpath("state") .. "/swap/"
    vim.fn.mkdir(swap_dir, "p") -- Ensure the swap directory exists
    vim.o.directory = swap_dir
    -- Clean up old swap files
    vim.cmd("silent! call delete(glob(swap_dir .. '*.swp'), 'rf')")
  end,
})
