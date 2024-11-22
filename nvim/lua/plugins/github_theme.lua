local colors = {
    string = "#67A771",
    keyword = "#F4766B",
    boolean = "#f69d50",
}

local github_dark_dimmed = {
    ---treesitter
    ["@string"] = {fg = colors.string},
    ["@keyword"] = {fg = colors.keyword},
    ["@boolean"] = {fg = colors.boolean},
    ["@constant.builtin"]  = {fg = colors.boolean},
    ['@keyword.exception']   ={fg = colors.boolean},
    ['@keyword.conditional'] = {fg = colors.boolean},
 
}
return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- Load during startup
  priority = 1000, -- Load before other plugins
  config = function()
    require('github-theme').setup({
      -- Add your theme-specific configurations here

    })

    vim.cmd('colorscheme github_dark_dimmed') -- Set the colorscheme
for group, conf in pairs(github_dark_dimmed) do
    vim.api.nvim_set_hl(0, group, conf)
end
  end,
}
