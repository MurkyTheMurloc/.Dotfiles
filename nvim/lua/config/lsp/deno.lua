
local nvim_lsp = require('lspconfig')

-- Configure Deno LSP
nvim_lsp.denols.setup({
  on_attach = on_attach,
  root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.lock", "deno.jsonc"),
})

-- Configure TypeScript LSP (vtsls)
nvim_lsp.vtsls.setup({
  root_dir = function(fname)
    local util = nvim_lsp.util
    local deno_root = util.root_pattern("deno.json", "deno.jsonc", "deno.lock")(fname)
    if deno_root then
      return nil -- Disable vtsls for Deno projects
    end
    return util.root_pattern("package.json",  "jsconfig.json")(fname)
  end,
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  single_file_support = false, -- Prevent single file support
  on_new_config = function(new_config, new_root)
    local util = nvim_lsp.util
    local deno_root = util.root_pattern("deno.json", "deno.jsonc", "deno.lock")(new_root)
    if deno_root then
      -- Explicitly prevent vtsls from starting
      new_config.enabled = false
    end
  end,
})


