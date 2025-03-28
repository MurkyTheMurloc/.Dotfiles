return {
    {
        'saghen/blink.cmp',
        --priority = 1000,
        event = { "InsertEnter" },
        lazy = false,
        dependencies = { 'saghen/blink.compat' },
        version = 'v0.*',
        opts = {
            keymap = { preset = 'enter' },
            appearance = { use_nvim_cmp_as_default = true },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            completion = {

                trigger = {
                    show_on_insert_on_trigger_character = true,
                },
                list = {
                    selection = {
                        auto_insert = true,
                        preselect = true
                    },
                },

                menu = {
                    draw = {
                        columns = {
                            { "label",     "label_description", gap = 1 },
                            { "kind_icon", "kind" }
                        },
                        treesitter = { 'lsp' },
                    }
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    treesitter_highlighting = true,
                    window = {
                        border = "rounded",
                        winblend = 50,
                    },
                },
                ghost_text = {
                    enabled = false,

                },
            },
        },

        opts_extend = { "sources.default" }





    }
}
