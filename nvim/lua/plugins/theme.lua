return {
{
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        require('github-theme').setup({
            -- ...
        })
        local colors = {
            string = "#67A771",
            keyword = "#F4766B",
            boolean = "#F69d50",
            class = "#FF6A67",
            type = "#FF9843",
            property = "#c77dff",
            html = "#7EE787",
            delimiter = "#79C0FF",
            test = "#00b4d8",
            fn = "#ffafcc",
        }

        local github_dark_dimmed = {
            ---treesitter
            ["@string"]              = { fg = colors.string },
            ["@keyword"]             = { fg = colors.keyword },
            -- ["@type"] = {fg = colors.class },
            -- ["@type.builtin"] = {fg = colors.keyword },
            -- ["@class"] = {fg = colors.type, bold = true},
            ["@boolean"]             = { fg = colors.boolean },
            ["@keyword.control"]     = { fg = colors.keyword },
            ["@constant.builtin"]    = { fg = colors.keyword },
            ['@keyword.exception']   = { fg = colors.keyword },
            ['@keyword.conditional'] = { fg = colors.boolean },
            --["@function"] = {fg = colors.type},
            --["@function.property"} = {fg = colors.property},
            --["@property"] = { fg = colors.property },

            --["@punctuation.bracket"] = {fg = "#f9f7f3"},
            --["@type.definition"] = {fg = colors.test} ,
            ["@tsx.tag"]             = { fg = colors.type, bold = true },
            ["tsx.@tag.attribute"]   = { fg = colors.property, italic = true },
            ["tsx.@tag.builtin"]     = { fg = colors.html, italic = true },
            ["tsx.@tag.delimiter"]   = { fg = colors.delimiter },
        }

        vim.cmd('colorscheme github_dark_default')

        for group, conf in pairs(github_dark_dimmed) do
            vim.api.nvim_set_hl(0, group, conf)
        end
        --vim.g.neovide_transparency = 0.8
        local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
        local gray = comment_hl.fg and string.format("#%06x", comment_hl.fg)

        -- Apply it to FloatBorder globally
        if gray then
            vim.api.nvim_set_hl(0, "FloatBorder", { fg = gray, bg = "NONE" })
            -- Optional: also update NormalFloat to be transparent
            vim.api.nvim_set_hl(0, "NormalFloat", { fg = gray, bg = "NONE" })

            vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = gray, link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "TelescopeSelection",
                { bg = "NONE", fg = "NONE", bold = false, sp = gray, underline = true })
            vim.api.nvim_set_hl(0, "PmenuSel",
                { bg = "NONE", fg = "NONE", bold = false, underline = true, sp = gray })
        end
    end,
}
}
