
local nvim_lsp = require('lspconfig')
local util = nvim_lsp.util
local capabilities = require('blink.cmp').get_lsp_capabilities()

local deno_root = util.root_pattern("deno.json", "deno.lock", "deno.jsonc")
local node_root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")

-- Notify function using vim.notify and wait for Enter to continue
local function notify(msg, level)
  vim.schedule(function()

    -- After notification, wait for the user to press Enter to continue
    vim.ui.input({ prompt = msg}, function() end)
  end)
end






local function on_attach_deno(client, bufnr)
  -- Determine the project type
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local is_deno = deno_root(fname)
  local is_node = node_root(fname)

 -- notify(is_node)
  -- If both are detected, prefer Deno
  if string.len(is_node)> string.len(is_deno) then
        client.stop()
        return nil
end

end

local function on_attach_node(client, bufnr)
  -- Determine the project type
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local is_deno = deno_root(fname)
  local is_node = node_root(fname)

  notify(is_deno)
 -- notify(is_node)
  -- If both are detected, prefer Deno
  if string.len(is_node)< string.len(is_deno) then
        client.stop()
        return nil
end
    end
local function on_root_dir_deno(cliebt,bufnr)
  -- Determine the project type
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local is_deno = deno_root(fname)
  local is_node = node_root(fname)

  --notify(is_deno)
 -- notify(is_node)
  -- If both are detected, prefer Deno
  if string.len(is_node)> string.len(is_deno) then
                return nil
end
    return is_deno
end
local function on_root_dir_node(cliebt,bufnr)
  -- Determine the project type
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local is_deno = deno_root(fname)
  local is_node = node_root(fname)

  --notify(is_deno)
 -- notify(is_node)
  -- If both are detected, prefer Deno
  if string.len(is_node)< string.len(is_deno) then
                return nil
end
    return is_node
end
-- Configure Deno LSP
nvim_lsp.denols.setup({
  on_attach = on_attach_deno,
  capabilities = capabilities,
  root_dir = on_root_dir_deno,
})

-- Configure TypeScript LSP (vtsls)
nvim_lsp.vtsls.setup({
  on_attach = on_attach_node,
  capabilities = capabilities,
  root_dir = on_root_dir_node,
  single_file_support = false,
})

nvim_lsp.astro.setup({
 capabilities = capabilities

})
