local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()


-- Tailwind CSS setup: Attach only to HTML and TSX files
lspconfig.tailwindcss.setup({
  filetypes = { "typescriptreact", "html" },  -- Only enable on .tsx and .html files
  capabilities = capabilities,

  settings = {
    tailwindCSS = {
      validate = true,  -- Enable validation
    },
  },
})

--require("cmp").config.formatting = {
--  format = require("tailwindcss-colorizer-cmp").formatter
--}
