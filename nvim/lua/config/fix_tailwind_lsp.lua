local M = {}

local function disable_tailwind_for_rust()
    local filetype = vim.bo.filetype
    if filetype ~= "rust" then return end
    local clients = vim.lsp.get_clients()

    if not next(clients) then
        return
    end
    for _, client in clients do
        if client.name == "tailwindcss" then
            vim.schedule(function()
                vim.lsp.stop_client(client.id)
                vim.notify("Disabled Tailwind LSP for Rust files", vim.log.levels.WARN)
            end)
        end
        if client.name == "denols" then
            vim.schedule(function()
                vim.lsp.stop_client(client.id)
                vim.notify("Disabled Tailwind LSP for Rust files", vim.log.levels.WARN)
            end)
        end
        if client.name == "vtsls" then
            vim.schedule(function()
                vim.lsp.stop_client(client.id)
                vim.notify("Disabled Tailwind LSP for Rust files", vim.log.levels.WARN)
            end)
        end
    end
end

function M.setup()
    -- Run on BufRead and BufNewFile to catch file openings
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = "*.rs",
        callback = disable_tailwind_for_rust,
    })
end

return M
