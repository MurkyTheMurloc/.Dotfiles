
-- leader key
vim.g.mapleader = " "
-- Example Neovim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
-- Set 4 spaces for indentation
vim.opt.tabstop = 4      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4   -- Number of spaces for each auto-indent
vim.opt.softtabstop = 4  -- Number of spaces for tab in insert mode
vim.opt.expandtab = true -- Convert tabs to spaces

-- Visible Whitespace
--vim.opt.list = true
--vim.opt.listchars:append("tab:⋅")
--vim.opt.listchars:append("space:⋅")
--vim.opt.listchars:append("trail:⋅")

-- Enable auto-indentation
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.laststatus = 2
vim.opt.cmdheight = 0

-- Folding
vim.opt.foldenable = true
vim.opt.foldlevel = 100
vim.opt.foldlevelstart = 100

local signs = { Error = " ", Warn = " ", Hint = "󱠂 ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.diagnostic.config({ virtual_text = false })
-- Set a maximum line width for text
vim.opt.textwidth = 80   -- Wrap lines at 80 characters
--vim.opt.colorcolumn = "80" -- Highlight the 80-character limit

vim.opt.guifont = "JetBrains Mono:h15"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.laststatus = 0

--vim.opt.termguicolors = true
--vim.cmd([[syntax off]]) -- Disable legacy syntax highlighting
--vim.cmd([[set filetype=on]]) -- Enable filetype detection



