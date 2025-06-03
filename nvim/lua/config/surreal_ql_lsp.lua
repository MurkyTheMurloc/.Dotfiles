local M = {}

local find_rust_bin = function()
    local bin_path = '/Users/paulbose/.config/lsp/surrealql-lsp/target/debug/surrealql-lsp-server'
    if vim.fn.filereadable(bin_path) == 1 then
        return bin_path
    else
        vim.notify('LSP server executable not found: ' .. bin_path, vim.log.levels.ERROR)
        return nil
    end
end


local util = require("lspconfig.util")

M.start = function()
    vim.lsp.set_log_level 'debug'
    require('vim.lsp.log').set_format_func(vim.inspect)

    local lsp_bin = find_rust_bin()
    if not lsp_bin then return end

    local bufnr = vim.api.nvim_get_current_buf()

    -- 🔁 Avoid starting if already attached
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
        if client.name == 'surrealql' then
            return -- already attached to this buffer
        end
    end

    local root_dir = util.root_pattern(".git", "surreal.config.json")(vim.api.nvim_buf_get_name(bufnr))
        or vim.fn.getcwd()

    local client = vim.lsp.start({
        name = 'surrealql',
        cmd = { lsp_bin },
        root_dir = root_dir,
        capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    if client then
        vim.lsp.buf_attach_client(bufnr, client)
    else
        vim.notify('Failed to start surrealql-lsp-server', vim.log.levels.ERROR)
    end
end
M.setup = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "surql",
        callback = M.start,
    })
end
return M
