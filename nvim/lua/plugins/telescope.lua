local project_root = vim.fn.systemlist('git rev-parse --show-toplevel') -- Get the root of the Git project

-- If not in a git project, fallback to the current directory
if #project_root == 0 then
  project_root = vim.fn.getcwd()
else
  project_root = vim.fn.trim(project_root[1]) -- Trim the output
end

-- Specify a package/subdirectory to restrict the search to
local search_dir = project_root .. "/packages/frontend" -- Adjust this to your subdirectory

return {
  'nvim-telescope/telescope.nvim',
    lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
 "nvim-telescope/telescope-frecency.nvim",
    'neovim/nvim-lspconfig',
  },
   opts = {
    defaults = {
            layout_strategy = 'vertical',
    layout_config = {
      mirror = false, -- Ensures preview is at the bottom
    }, 
      find_command = {
        'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--exclude', 'node_modules', '--follow'
      },
      hidden = true, -- Include hidden files
      file_ignore_patterns = { "%.git/" }, -- Ignore .git directory
      extensions = {
        fzf = {},
      },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf") 
        telescope.load_extension "frecency"
local builtin = require("telescope.builtin")
         vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { noremap = true, silent = true, desc = "Go to definition" })
    vim.keymap.set("n", "leader<gr>", builtin.lsp_references, { noremap = true, silent = true, desc = "Find references" })
   vim.keymap.set("n", "<leader>fb", builtin.buffers, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>f.", builtin.resume, { noremap = true, silent = true })
  end,
 
}

