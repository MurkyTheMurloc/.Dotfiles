-- ~/.config/nvim/lua/no_duplicate_lsp.lua
-- A tiny “plugin” that kills duplicate LSP clients for the same buffer/project.

local M = {}

function M.setup()
    vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Automatically stop duplicate LSP clients",
        callback = function(args)
            local bufnr = args.buf

            -- 1) Find only the clients actually attached to this buffer
            local attached = {}
            for _, client in ipairs(vim.lsp.get_clients()) do
                if vim.lsp.buf_is_attached(bufnr, client.id) then
                    table.insert(attached, client)
                end
            end

            -- 2) Track seen servers by "name:root_dir"
            local seen = {}

            for _, client in ipairs(attached) do
                local root = (client.config and client.config.root_dir) or ""
                local key  = client.name .. ":" .. root

                if seen[key] then
                    -- 3) Stop the duplicate server entirely
                    vim.lsp.stop_client(client.id)
                    vim.notify(
                        string.format(
                            "[no_duplicate_lsp] Stopped duplicate LSP '%s' (id=%d) for root '%s'",
                            client.name,
                            client.id,
                            root ~= "" and vim.fn.fnamemodify(root, ":t") or "[no-root]"
                        ),
                        vim.log.levels.WARN,
                        { title = "no_duplicate_lsp" }
                    )
                else
                    seen[key] = true
                end
            end
        end,
    })
end

return M
