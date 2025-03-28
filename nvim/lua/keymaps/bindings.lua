vim.keymap.set("n", "<leader>gb", "<C-o>", { desc = "Go back to previous location" })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>smart_rename()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "d", '"_d', { noremap = true })
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("v", "d", '"_d', { noremap = true })
vim.keymap.set("v", "c", '"_c', { noremap = true })
vim.keymap.set("n", "dy", "d", { noremap = true })
vim.keymap.set("v", "dy", "d", { noremap = true })
