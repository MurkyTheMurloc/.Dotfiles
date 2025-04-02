-- Load options
require("config.options")
require("config.quit_pre")
local status, err = pcall(require, "config.delete_swap_files")
if not status then
    vim.notify("Error loading config.delete_swap_files: " .. err, vim.log.levels.ERROR)
end


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

--require("config.smart_rename")
require("keymaps.file_browser")
require("keymaps.bindings")

require("config.surreal_ql_lsp").setup()
require("config.auto_save").setup({ interval = 3000 })


local status, err = pcall(require, "config.re_open")
if not status then
    vim.notify("Error loading config.re_open: " .. err, vim.log.levels.ERROR)
end
