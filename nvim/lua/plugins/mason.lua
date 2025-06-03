return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",

    },
    config = function()
        -- Mason setup
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })

        -- Mason LSP Config setup
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "astro",
                "cssls",
                "vtsls",         -- TypeScript/JavaScript
                "pyrefly",       -- Python
                -- "gop_ls",      -- Go
                "rust_analyzer", -- Rust
                "clangd",        -- C/C++
                "html",          -- HTML
                "svelte",        -- Svelte
                "tailwindcss",   -- Tailwind CSS
                "graphql",       -- GraphQL
                "sqls",          -- SQL
                "denols",        -- Deno
                "ltex",          -- Grammar
                "dockerls",
                "docker_compose_language_service",
                "biome",
                --                "eslint_d",
                "ruff",

            },
            automatic_installation = false,
        })
    end,
}
