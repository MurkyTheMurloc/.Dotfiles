return {
    {
        'saghen/blink.cmp',
        --priority = 1000,
        event = { "InsertEnter" },
        lazy = false,
        dependencies = {
            "saghen/blink.compat",
            "niuiic/blink-cmp-rg.nvim",
            {
                "Kaiser-Yang/blink-cmp-dictionary",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
            "xzbdmw/colorful-menu.nvim",
            "alexandre-abrioux/blink-cmp-npm.nvim"

        },

        version = '1.2.0',

        opts = {
            keymap = {
                preset = 'enter',
                ["<Tab>"] = { function(cmp)
                    cmp.select_and_accept({ auto_insert = false })
                end, }
            },
            appearance = { use_nvim_cmp_as_default = true },
            sources = {
                default = { 'buffer', 'lsp', 'path', "snippets", "npm" }, -- 'ripgrep'
                per_filetype = {
                    html = { 'tagwrap' },
                    astro = { 'tagwrap' },
                    typescriptreact = { 'tagwrap' },

                },
                providers = {
                    tagwrap = {
                        name = "tags",
                        module = "config.blink_cmp_wrap_in_tag",
                    },
                    npm = {
                        name = "npm",
                        module = "blink-cmp-npm",
                        async = true,
                        -- optional - make blink-cmp-npm completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                        -- optional - blink-cmp-npm config
                        ---@module "blink-cmp-npm"
                        ---@type blink-cmp-npm.Options
                        opts = {
                            ignore = {},
                            only_semantic_versions = true,
                            only_latest_version = false,
                        }
                    },

                    dictionary = {
                        module = "blink-cmp-dictionary",
                        name = "Dict",
                        min_keyword_length = 3,
                        opts = {
                            dictionary_files = { vim.fn.expand("~/.config/nvim/dictionary/words.dict") },
                            -- Alternatively, specify a directory:
                            -- dictionary_directories = { vim.fn.expand("~/.config/nvim/dictionary") },
                        },
                    },

                    --[[
                    ripgrep = {
                        module = "blink-cmp-rg",
                        name = "Ripgrep",
                        -- options below are optional, these are the default values
                        opts = {
                            -- `min_keyword_length` only determines whether to show completion items in the menu,
                            -- not whether to trigger a search. And we only has one chance to search.
                            prefix_min_len = 3,
                            get_command = function(context, prefix)
                                return {
                                    "rg",
                                    "--no-config",
                                    "--json",
                                    "--word-regexp",
                                    "--ignore-case",
                                    "--",
                                    prefix .. "[\\w_-]+",
                                    vim.fs.root(0, ".git") or vim.fn.getcwd(),
                                }
                            end,
                            get_prefix = function(context)
                                return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                            end,
                        },
                    },
                    ]]
                },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        completion = {

            trigger = {
                show_on_insert_on_trigger_character = true,
            },
            list = {
                selection = {
                    auto_insert = true,
                    preselect = true
                },
                accept = {
                    -- Write completions to the `.` register
                    dot_repeat = true,
                    -- Create an undo point when accepting a completion item
                    create_undo_point = true,
                    -- How long to wait for the LSP to resolve the item with additional information before continuing as-is
                    resolve_timeout_ms = 100,
                    -- Experimental auto-brackets support
                    auto_brackets = {
                        -- Whether to auto-insert brackets for functions
                        enabled = true,
                        -- Default brackets to use for unknown languages
                        default_brackets = { '(', ')' },
                        -- Overrides the default blocked filetypes
                        -- See: https://github.com/Saghen/blink.cmp/blob/main/lua/blink/cmp/completion/brackets/config.lua#L5-L9
                        override_brackets_for_filetypes = {},
                        -- Synchronously use the kind of the item to determine if brackets should be added
                        kind_resolution = {
                            enabled = true,
                            blocked_filetypes = { 'typescriptreact', 'astro', 'vue' },
                        },
                        -- Asynchronously use semantic token to determine if brackets should be added
                        semantic_token_resolution = {
                            enabled = true,
                            blocked_filetypes = { 'java' },
                            -- How long to wait for semantic tokens to return before assuming no brackets should be added
                            timeout_ms = 400,
                        },
                    },
                },
            },

            menu = {
                draw = {
                    treesitter = { 'lsp' },
                    -- We don't need label_description now because label and label_description are already
                    -- combined together in label by colorful-menu.nvim.
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                },
            },

            ghost_text = {
                enabled = false,

            },
        },
        opts_extend = { "sources.default" },
    },







}
