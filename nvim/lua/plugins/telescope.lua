


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
    lazy = true,
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
  end,
  keys = function()
    local builtin = require("telescope.builtin")
 local opts = { noremap = true, silent = true, buffer = bufnr }
    return {
      { "<leader>fb", builtin.buffers, desc = "Find Buffers" },
      { "<leader>ff", builtin.find_files, desc = "Find Files" },
      { "<leader>fg", builtin.live_grep, desc = "Find Grep" },
      { "<leader>fc", builtin.colorscheme, desc = "Find Colorschemes" },
      { "<leader>fd", builtin.diagnostics, desc = "Diagnostics" },
      { "<leader>f.", builtin.resume, desc = "Resume" },
      { "n", "gd", builtin.lsp_definitions,  opts},
      { "n", "gr", builtin.lsp_references, opts },
    }
  end,
}

