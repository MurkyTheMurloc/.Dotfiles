local M = {}

M.enabled = true  -- Auto-save is enabled by default
M.interval = 4000 -- Auto-save interval in milliseconds (2s)

-- Function to save if the buffer is modified
local function save_if_modified()
    if vim.bo.modified and vim.bo.filetype ~= "" then
        vim.cmd("silent! write")
    end
end

-- Toggle auto-save on/off
function M.toggle()
    M.enabled = not M.enabled
    print("Auto-save: " .. (M.enabled and "ON" or "OFF"))
end

-- Setup auto-save
function M.setup(opts)
    if opts and opts.interval then
        M.interval = opts.interval
    end

    -- Auto-save when leaving insert mode
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            if M.enabled then
                save_if_modified()
            end
        end
    })

    -- Auto-save every few seconds
    vim.fn.timer_start(M.interval, function()
        if M.enabled then
            save_if_modified()
        end
    end, { ["repeat"] = -1 })
end

return M
