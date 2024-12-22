
return {
  -- Add the nvim-colorizer.lua plugin
  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    config = function()
      require("colorizer").setup({
        -- Enable for specific file types or set `*` for all file types
        "*", -- Highlights color codes in all file types
        css = { css = true }, -- Enable parsing `css` variables
      }, {
        -- Optional additional settings
        RGB      = true,  -- Enable #RGB hex codes
        RRGGBB   = true,  -- Enable #RRGGBB hex codes
        names    = false, -- Disable named colors like Blue or Red
        RRGGBBAA = true,  -- Enable #RRGGBBAA hex codes
        rgb_fn   = true,  -- Enable `rgb()` and `rgba()` functions
        hsl_fn   = true,  -- Enable `hsl()` and `hsla()` functions
        css      = true,  -- Enable CSS colors like `background-color`
        css_fn   = true,  -- Enable all CSS `functions`
      })
    end,
  },
}
