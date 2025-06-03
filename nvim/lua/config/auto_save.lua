local M = {}

M.enabled = true -- Auto-save is enabled by default

-- Function to save only if in visual mode and buffer is modified
local function save_if_modified()
    if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then -- Visual, Line, Block mode
        if vim.bo.modified and vim.bo.filetype ~= "" then
            vim.cmd("silent! write")
        end
    end
end

-- Toggle auto-save on/off
function M.toggle()
    M.enabled = not M.enabled
    print("Auto-save: " .. (M.enabled and "ON" or "OFF"))
end

-- Setup auto-save
function M.setup()
    vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:v,*:V,*:\22", -- Any mode entering Visual modes
        callback = function()
            if M.enabled then
                save_if_modified()
            end
        end
    })
end

return M
