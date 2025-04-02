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

M.start = function()
    vim.lsp.set_log_level 'debug'
    require('vim.lsp.log').set_format_func(vim.inspect)

    local lsp_bin = find_rust_bin()
    if not lsp_bin then
        return
    end

    local client = vim.lsp.start {
        name = 'surrealql',
        cmd = { lsp_bin },
        capabilities = require("blink.cmp").get_lsp_capabilities()
    }

    if not client then
        vim.notify('Failed to start surrealql-lsp-server', vim.log.levels.ERROR)
        return
    end

    vim.lsp.buf_attach_client(0, client)
end

local group = vim.api.nvim_create_namespace 'surrealql'

M.setup = function()
    vim.api.nvim_clear_autocmds { group = group }

    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'surql',
        callback = M.start,
    })
end

return M
