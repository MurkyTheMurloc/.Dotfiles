return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",

    },
    config = function()
        -- Mason setup
        require("mason").setup()

        -- Mason LSP Config setup
        require("mason-lspconfig").setup({
            ensure_installed = {
                "astro",
                "vtsls",         -- TypeScript/JavaScript
                "pyright",       -- Python
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
                "eslint",
                "ruff",

            },
            automatic_installation = true,
        })
    end,
}
