
  
return vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        local swap_dir = vim.fn.stdpath("state") .. "/swap/"
        vim.fn.mkdir(swap_dir, "p") -- Ensure the swap directory exists
        vim.o.directory = swap_dir

        -- Clean up old swap files using Lua
        local uv = vim.loop
        local handle = uv.fs_scandir(swap_dir)

        if handle then
            while true do
                local file = uv.fs_scandir_next(handle)
                if not file then break end
                if file:match("%.sw[p-z]$") then
                    uv.fs_unlink(swap_dir .. file)
                end
            end
        end
    end,
})
