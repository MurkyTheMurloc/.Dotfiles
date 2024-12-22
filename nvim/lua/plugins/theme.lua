
return -- Or with configuration
{
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
   require('github-theme').setup({
  options = {
    -- Compiled file's destination location
    compile_path = vim.fn.stdpath('cache') .. '/github-theme',
    compile_file_suffix = '_compiled', -- Compiled file suffix
    hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer for a cleaner look
    hide_nc_statusline = true, -- Override the underline style for non-active statuslines
    transparent = true,       -- Disable setting bg (make neovim's background transparent)
    terminal_colors = true,    -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
    dim_inactive = false,      -- Non focused panes set to alternative background
    module_default = true,     -- Default enable value for modules
    styles = {                 -- Style to be applied to different syntax groups
      comments = 'NONE',       -- Value is any valid attr-list value `:help attr-list`
      functions = 'NONE',
      keywords = 'NONE',
      variables = 'NONE',
      conditionals = 'NONE',
      constants = 'NONE',
      numbers = 'NONE',
      operators = 'NONE',
      strings = 'NONE',
      types = 'NONE',
    },
    inverse = {                -- Inverse highlight for different types
      match_paren = true,
      visual = false,
      search = false,
    },
    darken = {                 -- Darken floating windows and sidebar-like windows
      floats =false,
      sidebars = {
        enable = false,
        list = {},             -- Apply dark background to specific windows
      },
    },
    modules = {                -- List of various plugins and additional options
      -- ...
    },
  },
  palettes = {},
  specs = {},
  groups = {},
})


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
   -- ["@type"] = {fg = colors.class },
   -- ["@type.builtin"] = {fg = colors.keyword },
   -- ["@class"] = {fg = colors.type, bold = true},
    ["@boolean"] = {fg = colors.boolean},
   ["@keyword.control"] = {fg =  colors.keyword},
    ["@constant.builtin"]  = {fg = colors.keyword},
    ['@keyword.exception']   ={fg = colors.keyword},
    ['@keyword.conditional'] = {fg = colors.boolean},
    --["@function"] = {fg = colors.type},
    --["@function.property"} = {fg = colors.property},
    --["@property"] = { fg = colors.property }, 

    --["@punctuation.bracket"] = {fg = "#f9f7f3"},
--["@type.definition"] = {fg = colors.test} ,
    ["@tsx.tag"] = {fg = colors.type, bold =true},
    ["tsx.@tag.attribute"] = {fg = colors.property, italic =true},
    ["tsx.@tag.builtin"]  = {fg = colors.html,italic =true},
    ["tsx.@tag.delimiter"] = {fg = colors.delimiter},
}

    vim.cmd('colorscheme github_dark_dimmed')

for group, conf in pairs(github_dark_dimmed) do
   vim.api.nvim_set_hl(0, group, conf)
end


--vim.cmd("highlight Normal guibg=#000000") -- Set the background color to black
--vim.cmd("highlight NonText guibg=#000000") -- Ensure non-text areas also use black
 vim.g.neovide_transparency = 0.7

  end,
}
