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
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'neovim/nvim-lspconfig',
  },
  opts = {
    defaults = {
      -- Specify find command with search_dir
      find_command = {
        'fd', '--type', 'f', '--hidden', '--exclude', '.git', '--exclude', 'node_modules', '--follow', '--max-depth', '100', search_dir
      },

      -- Live grep restricted to the specified directory
      vimgrep_arguments = {
        'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--hidden', '--glob', '!.git/*', search_dir
      },
      extensions = {
        fzf = {},
      },
      hidden = true, -- Show hidden files like .env
      file_ignore_patterns = {  ".git/" }, -- Ignore directories like node_modules and .git
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
local builtin = require("telescope.builtin")
         vim.keymap.set("n", "gd", builtin.lsp_definitions, { noremap = true, silent = true, desc = "Go to definition" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { noremap = true, silent = true, desc = "Find references" })
   -- vim.keymap.set("n", "<leader>fb", builtin.buffers, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>f.", builtin.resume, { noremap = true, silent = true })
  end,
 
}

