-- Load options
require("config.options")

require("config.quit_pre")
require("config.delete_swap_files")
if vim.g.neovide then
    require("neovide")
end
-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load Lazy.nvim
require("lazy").setup("plugins")
--require("config.re_open").setup()

--require("config.smart_rename")
require("keymaps.file_browser")
require("keymaps.bindings")
--require("config.theme")


--vim.api.nvim_set_hl(0, 'ColorColumn', { ctermbg = 'NONE', ctermfg = 'NONE', bg = 'NONE', fg = 'NONE' })
--vim.cmd("highlight Normal guibg=#303030")


--require("config.fix_tailwind_lsp").setup()

local status, err = pcall(require, "config.re_open")
if not status then
    vim.notify("Error loading config.re_open: " .. err, vim.log.levels.ERROR)
end
