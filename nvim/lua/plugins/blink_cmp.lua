local function get_centered_position_with_padding(width, height, padding)
    local editor_width = vim.o.columns
    local editor_height = vim.o.lines

    -- Calculate the effective width and height with padding
    local effective_width = width + 2 * padding
    local effective_height = height + 2 * padding

    local row = math.floor((editor_height - effective_height) / 2)
    local col = math.floor((editor_width - effective_width) / 2)

    return { row = row, col = col }
end

--[[
return {
    {
        'saghen/blink.cmp',
        --priority = 1000,
        event = { "InsertEnter" },
        lazy = false,
        dependencies = {
            "saghen/blink.compat",
            {
                "Kaiser-Yang/blink-cmp-dictionary",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
            "xzbdmw/colorful-menu.nvim",
            "Fildo7525/pretty_hover",
            "alexandre-abrioux/blink-cmp-npm.nvim",
            "erooke/blink-cmp-latex",

        },

        version = "*",

        opts = {
            keymap = {
                preset = 'enter',
                ["<Tab>"] = { function(cmp)
                    cmp.select_and_accept({ auto_insert = false })
                end, }
            },
            appearance = {border= "rounded", use_nvim_cmp_as_default = true, nerd_font_variant = "mono", },
            sources = {
                default = { 'buffer', 'lsp', 'path', "snippets", "npm", "latex" },
                per_filetype = {
                    html = { 'tagwrap' },
                    astro = { 'tagwrap' },
                    typescriptreact = { 'tagwrap' },

                },
                providers = {
                    latex = {
                        name = "Latex",
                        module = "blink-cmp-latex",
                        opts = {
                            -- set to true to insert the latex command instead of the symbol
                            insert_command = false
                        },
                    },
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


                },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },

        signature = { enabled = true },
        completion = {

            trigger = {
                show_on_insert_on_trigger_character = true,
            },
            list = {
                selection = {
                    auto_insert = true,
                    preselect = true
                },
                win_config = {
                    max_width = 60,
                    override = function(default_config)
                        local total_width = vim.api.nvim_win_get_width(0)
                        local menu_width = 60
                        local col = math.floor((total_width - menu_width) / 2)
                        default_config.col = col
                        return default_config
                    end,
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

            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,

                draw = function(opts)
                    local success, out = pcall(function()
                        if opts.item and opts.item.documentation and type(opts.item.documentation.value) == "string" then
                            local parsed = require("pretty_hover.parser").parse(opts.item.documentation.value)
                            opts.item.documentation.value = parsed:string()
                        end
                    end)
                    if not success then
                        vim.notify("Failed to parse documentation", vim.log.levels.WARN)
                    end
                    opts.default_implementation(opts)
                end

            },

            menu = {
                draw = {
                    padding = { 0, 1 },
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            width = { fill = true, max = 70 },
                            text = function(ctx)
                                local ok, result = pcall(require("colorful-menu").blink_components_text, ctx)
                                if not ok then
                                    vim.notify("colorful-menu: blink_components_text failed", vim.log.levels.WARN)
                                    return "[ERR] " .. (ctx.label or "")
                                end
                                return result or ctx.label
                            end,
                            highlight = function(ctx)
                                local ok, result = pcall(require("colorful-menu").blink_components_highlight, ctx)
                                if not ok then
                                    vim.notify("colorful-menu: blink_components_highlight failed", vim.log.levels.WARN)
                                    return "ErrorMsg"
                                end
                                return result
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
]]


return {
    {
        'saghen/blink.cmp',
        --priority = 1000,
        event = { "InsertEnter" },
        lazy = false,
        dependencies = {
            "xzbdmw/colorful-menu.nvim",
            "Fildo7525/pretty_hover",
            {
                "Kaiser-Yang/blink-cmp-dictionary",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
            "alexandre-abrioux/blink-cmp-npm.nvim",
            "erooke/blink-cmp-latex",

        },

        version = "*.",
        opts = {
            sources = {
                default = { 'buffer', 'lsp', 'path', "snippets", "npm", "latex" },
                per_filetype = {
                    html = { 'tagwrap' },
                    astro = { 'tagwrap' },
                    typescriptreact = { 'tagwrap' },
                    json = { "npm" },
                    latex = { "latex" },

                },
                providers = {
                    latex = {
                        name = "Latex",
                        module = "blink-cmp-latex",
                        opts = {
                            -- set to true to insert the latex command instead of the symbol
                            insert_command = false
                        },
                    },
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


                },
            },

            keymap = {
                preset = 'enter',
                ["<Tab>"] = { function(cmp)
                    cmp.select_and_accept({ auto_insert = false })
                end, }
            },

            appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono", },
            signature = {
                enabled = true,
                direction_priority = {
                    menu_north = { 'n', },
                    menu_east = { "n" },
                    menu_south = { "n" },
                    menu_west = { "n" },
                },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning', },
            completion = {
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

                col_offset = -3,

                documentation = {
                    treesitter_highlighting = true,
                    auto_show = true,

                    auto_show_delay_ms = 1,
                    update_delay_ms = 50,
                    window = {
                        scrollbar = false,

                        min_width = 104,
                        max_width = 104,

                        border = "rounded",

                        win_config = {
                            override = function(default_config)
                                default_config.col = 0 -- always left-aligned
                                return default_config
                            end,
                        },
                        direction_priority = {
                            menu_north = { 'n', },
                            menu_east = { "n" },
                            menu_south = { "n" },
                            menu_west = { "n" },
                        },
                    },
                    draw = function(opts)
                        if opts.item and opts.item.documentation then
                            local out = require("pretty_hover.parser").parse(opts.item.documentation.value)

                            opts.item.documentation.value = out:string()
                        end

                        opts.default_implementation(opts)
                    end,
                },


                menu = {
                    min_width = 100,
                    max_width = 100,
                    border = "rounded",
                    treesitter_highlighting = true,
                    scrollbar = false,





                    draw = {


                        columns = { { "kind_icon" }, { "label", } },
                        components = {
                            label = {
                                width = { max = 100, min = 100 },
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
}
