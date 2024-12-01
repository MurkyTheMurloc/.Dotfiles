 local lspconfig = require('lspconfig') 
local blink_cmp_capabilities = require('blink.cmp').get_lsp_capabilities()
   -- Custom settings for specific servers
lspconfig.ltex.setup({
      settings = {
        ltex = {
          language = "en", -- Set the grammar language to English
          additionalRules = {
            enablePickyRules = true, -- Enable more advanced grammar rules
          },
        },
      },
      capabilities = blink_cmp_capabilities, -- Include Blink.cmp capabilities
    })

