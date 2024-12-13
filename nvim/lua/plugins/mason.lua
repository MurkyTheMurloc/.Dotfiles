
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
        "vtsls",      -- TypeScript/JavaScript
        "pyright",       -- Python
        "gopls",         -- Go
        "rust_analyzer", -- Rust
        "clangd",        -- C/C++
        "html",          -- HTML
        "cssls",         -- CSS
        "svelte",        -- Svelte
        "tailwindcss",   -- Tailwind CSS
        "graphql",       -- GraphQL
        "sqls",          -- SQL
        "denols",        -- Deno
        "ltex",          -- Grammar
         "dockerls",
            "docker_compose_language_service",
                "biome"
      },
      automatic_installation = true,
    })

   

 
  end,
}

