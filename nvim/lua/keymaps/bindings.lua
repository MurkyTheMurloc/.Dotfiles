vim.keymap.set("n", "<leader>gb", "<C-o>", { desc = "Go back to previous location" })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>smart_rename()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "d", '"_d', { noremap = true })
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("v", "d", '"_d', { noremap = true })
vim.keymap.set("v", "c", '"_c', { noremap = true })
vim.keymap.set("n", "dy", "d", { noremap = true })
vim.keymap.set("v", "dy", "d", { noremap = true })

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)

-- Window navigation with Ctrl + h/j/k/l
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', opts)

-- Close current split
vim.api.nvim_set_keymap('n', '<leader>q', ':close<CR>', opts)


local pairs_map = {
    ['()'] = '(',
    ['[]'] = '[',
    ['{}'] = '{',
    ['<>'] = '<',
    -- add more pairs here if you want
}

local function map_pair_command(cmd)
    for fullpair, openchar in pairs(pairs_map) do
        local lhs = cmd .. fullpair
        local rhs = cmd .. openchar
        vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
    end
end

for _, cmd in ipairs({ 'di', 'da', 'vi', 'va' }) do
    map_pair_command(cmd)
end


vim.keymap.set("n", "K", function()
    require("pretty_hover").hover()
end, { desc = "Pretty Hover" })
