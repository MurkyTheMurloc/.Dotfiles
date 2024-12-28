
vim.keymap.set("n", "<leader>gb", "<C-o>", { desc = "Go back to previous location" })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>smart_rename()<CR>', { noremap = true, silent = true })
