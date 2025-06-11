require("config.vim")
local status, err = pcall(require, "config.delete_swap_files")
if not status then
	vim.notify("Error loading config.delete_swap_files: " .. err, vim.log.levels.ERROR)
end
local status, err = pcall(require, "config.quit_pre")
if not status then
	vim.notify("Error loading config.quit_pre: " .. err, vim.log.levels.ERROR)
end
--[[
local status, err = pcall(require, "config.re_open")
if not status then
    vim.notify("Error loading config.re_open: " .. err, vim.log.levels.ERROR)
end
]]

--require("config.surql_lsp")
require("config.lazy")
require("config.diagnostic")

if vim.g.neovide then require("config.neovide") end

require("config.re_open")

require("config.auto_closing_tags")
require("config.delete_paired_tags").setup()
require("config.blink_cmp_wrap_in_tag")
