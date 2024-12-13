
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", -- Automatically install/update parsers
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
  --  "windwp/nvim-ts-autotag",               -- Auto close HTML/JSX tags
    --"JoosepAlviste/nvim-ts-context-commentstring", -- Contextual comments
  },

  opts = {
    ensure_installed = {
       "astro",      
      "go",        -- Go
      "rust",      -- Rust
      "typescript",-- TypeScript
      "sql",       -- SQL
      "html",      -- HTML
      "css",       -- CSS
      "graphql",   -- GraphQL
      "svelte",    -- Svelte
      "javascript",-- Required for SolidJS
      "tsx",       -- JSX/TSX for SolidJS
      "jsdoc",  
	"dockerfile",
"json",
			"json5",
			"jsonc",
"regex",
"astro",
"toml",
"yaml",
    },
  sync_install = false,
  auto_install = true,
    highlight = {
      enable = true,                     -- Enable syntax highlighting
      additional_vim_regex_highlighting = false, -- Disable regex fallback for performance
    },
    indent = {
      enable = true,                     -- Enable smart indentation
    },
   -- autotag = {
   --   enable = true,                     -- Auto close and rename HTML/JSX tags
   -- },
 --refactor = {
  --      highlight_definitions = { enable = true },
 --       highlight_current_scope = { enable = true },
   --     smart_rename = { enable = true, keymaps = { smart_rename = "<leader>rn" } },
   -- },
--context_commentstring = {
 --     enable = true,                     -- Enable context-based commenting
  --    enable_autocmd = false,
   -- },
   
  },
config = function(_, opts)
		if type(opts.ensure_installed) == "table" then
			---@type table<string, boolean>
			local added = {}
			opts.ensure_installed = vim.tbl_filter(function(lang)
				if added[lang] then
					return false
				end
				added[lang] = true
				return true
			end, opts.ensure_installed)
		end
	require("nvim-treesitter.configs").setup(opts)
        
	end,
}

