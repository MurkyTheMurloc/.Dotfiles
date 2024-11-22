
local capabilities = require("blink.cmp").get_lsp_capabilities()

local nvim_lsp = require('lspconfig')
nvim_lsp.denols.setup {
  on_attach = on_attach,
  root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
}
nvim_lsp.ts_ls.setup({
  root_dir = function(fname)
    local util = lspconfig.util
    -- Check for TypeScript root (package.json, tsconfig.json, or jsconfig.json)
    local root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)

    -- Check for Deno root (deno.json or deno.jsonc)
    local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
    
    -- If it's a Deno project, we don't want to run ts_ls for it
    if deno_root then
      print("Deno project detected, ts_ls will not be started.")
      return nil  -- Prevent ts_ls from starting for Deno projects
    end

    -- If a TypeScript root directory is found, return the root
    if root then
      return root
    end

    -- If no root is found, return nil and prevent LSP from starting
    return nil
  end,
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  single_file_support = false,
  autostart = false,  -- Prevent automatic restarts
})
