vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0

-- Visible Whitespace
vim.opt.list = true
vim.opt.listchars = {
	tab = "──",
	space = "⋅",
	trail = "⋅",
}

-- Do not break long lines
vim.opt.wrap = false

-- Sync with system clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.laststatus = 2
vim.opt.cmdheight = 1

-- Fold
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldtext = ""
vim.opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

vim.opt.shiftwidth = 2
vim.opt.colorcolumn = "80"

vim.filetype.add({
	pattern = {
		[".*/dockerfile"] = "dockerfile",
		[".*/dockerfile%.%a+"] = "dockerfile",
		[".*/containerfile"] = "dockerfile",
		[".*/containerfile%.%a+"] = "dockerfile",
	},
})
vim.filetype.add({
	extension = {
		surql = 'surql', -- Maps `.surql` files to the `surql` filetype
		astr = "astro"
	},
})
vim.keymap.set("n", "<leader>w", vim.cmd.write, { desc = "Write" })

vim.opt.guifont = "JetBrains Mono:h15"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.laststatus = 0

local pairs_map = {
	['()'] = '(',
	['[]'] = '[',
	['{}'] = '{',
	['<>'] = '<',
	-- add more pairs here if you want
}

local function map_pair_command(cmd)
	for fullpair, openchar in pairs(pairs_map) do
		local lhs = cmd .. fullpair
		local rhs = cmd .. openchar
		vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
	end
end

for _, cmd in ipairs({ 'di', 'da', 'vi', 'va' }) do
	map_pair_command(cmd)
end

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)

-- Set working directory when launching NeoVim
-- local group_cdpwd = vim.api.nvim_create_augroup("cdpwd", { clear = true })
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	pattern = "*",
-- 	group = group_cdpwd,
-- 	callback = function()
-- 		-- https://neovim.io/doc/user/builtin.html#expand()
-- 		local current_dir = vim.fn.expand("%:p:h")
-- 		vim.api.nvim_set_current_dir(current_dir)
-- 	end,
-- })·
