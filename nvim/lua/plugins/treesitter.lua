-- Example: lua/plugins/treesitter.lua
return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- Run TSUpdate command after Treesitter is updated/installed
        build = ":TSUpdate",
        -- Lazy load on buffer open events
        event = { "BufReadPost", "BufNewFile" },
        -- List other *plugins* that Treesitter might depend on or integrate with
        dependencies = {
            "windwp/nvim-ts-autotag", -- Auto close HTML/JSX tags
            -- Add other Treesitter-related *plugins* here if needed
            -- "JoosepAlviste/nvim-ts-context-commentstring",
        },
        opts = {
            -- Ensure SurrealQL is listed here along with others
            ensure_installed = {
                "astro",
                "go",
                "lua",
                "luadoc",
                "luap",
                "rust",
                "typescript",
                "sql",
                "html",
                "css",
                "graphql",
                "svelte",
                "javascript",
                "tsx",
                "jsdoc",
                "dockerfile",
                "json",
                "json5",
                "jsonc",
                "regex",
                "toml",
                "yaml",
                "surrealdb", -- <<< ADDED HERE
            },

            -- No 'languages' key needed here

            auto_install = true, -- Automatically install missing parsers listed in ensure_installed

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            autotag = {
                enable = true, -- Config for nvim-ts-autotag (if it uses this integration)
            },
            refactor = {       -- Assuming this is for nvim-treesitter-refactor or similar
                highlight_definitions = { enable = true },
                highlight_current_scope = { enable = true },
                smart_rename = { enable = true, keymaps = { smart_rename = "<leader>rn" } },
            },
        },
        config = function(_, opts)
            -- Optional deduplication logic (keep if you like it)
            if type(opts.ensure_installed) == "table" then
                local added = {}
                opts.ensure_installed = vim.tbl_filter(function(lang)
                    if added[lang] then return false end
                    added[lang] = true
                    return true
                end, opts.ensure_installed)
            end
        end


    },

}
