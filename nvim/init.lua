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

local status, err = pcall(require, "config.lsp.deno")
if not status then
  vim.notify("Error loading config.deno: " .. err, vim.log.levels.ERROR)
end

local status, err = pcall(require, "config.lsp.tailwind")
if not status then
  vim.notify("Error loading config.tailwind: " .. err, vim.log.levels.ERROR)
end
--local status, err = pcall(require, "config.lsp.grammar")
--if not status then
--  vim.notify("Error loading config.grammar: " .. err, vim.log.levels.ERROR)
--end
local status, err = pcall(require, "config.re_open")
if not status then
  vim.notify("Error loading config.re_open: " .. err, vim.log.levels.ERROR)
else
  require("config.re_open").setup()
end

require("config.smart_rename")
require("keymaps.file_browser")
require("keymaps.bindings")
--require("config.theme")


