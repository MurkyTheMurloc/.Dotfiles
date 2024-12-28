local colors = {
    string = "#67A771",
    keyword = "#F4766B",
    boolean = "#F69d50",   
    class = "#FF6A67",
    type = "#FF9843",
    property = "#c77dff",
    html = "#7EE787",
    delimiter ="#79C0FF",
    test = "#00b4d8",
    fn = "#ffafcc",
}

local github_dark_dimmed = {
    ---treesitter
    ["@string"] = {fg = colors.string},
    ["@keyword"] = {fg = colors.keyword},
    ["@type"] = {fg = colors.class },
    ["@type.builtin"] = {fg = colors.keyword },
    ["@class"] = {fg = colors.type, bold = true},
    ["@boolean"] = {fg = colors.boolean},
    ["@keyword.control"] = {fg =  colors.keyword},
    ["@constant.builtin"]  = {fg = colors.boolean},
    ['@keyword.exception']   ={fg = colors.keyword},
    ['@keyword.conditional'] = {fg = colors.boolean},
    ["@function"] = {fg = colors.type},
    --["@function.property"} = {fg = colors.property},
    ["@property"] = { fg = colors.property }, 

    ["@punctuation.bracket"] = {fg = "#f9f7f3"},
--["@type.definition"] = {fg = colors.test} ,
    ["@tag"] = {fg = colors.type, bold =true},
    ["@tag.attribute"] = {fg = colors.property, italic =true},
    ["@tag.builtin"]  = {fg = colors.html,italic =true},
    ["@tag.delimiter"] = {fg = colors.delimiter},
}

for group, conf in pairs(github_dark_dimmed) do
   vim.api.nvim_set_hl(0, group, conf)
end
 vim.g.neovide_transparency = 0.8


