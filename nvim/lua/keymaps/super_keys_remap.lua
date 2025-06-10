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
