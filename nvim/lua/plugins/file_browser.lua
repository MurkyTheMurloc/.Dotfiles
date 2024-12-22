
return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  lazy = true,
  config = function()
    local telescope = require("telescope")
    local fb_actions = require("telescope._extensions.file_browser.actions")
    local actions_state = require("telescope.actions.state")
    local notify = vim.notify

    -- Helper to get the project root
    local function project_root_or_cwd()
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if git_root and git_root ~= "" then
        return git_root
      end
      return vim.fn.getcwd()
    end

    -- Resolve project root
    local project_root = vim.loop.fs_realpath(project_root_or_cwd()) or vim.fn.getcwd()
    notify("Project Root: " .. project_root, vim.log.levels.INFO, { title = "Debug" })

    -- Custom "goto parent directory" action
    local function safe_goto_parent_dir(prompt_bufnr)
      local current_picker = actions_state.get_current_picker(prompt_bufnr)
      if not current_picker then
        notify("Error: Unable to get current picker.", vim.log.levels.ERROR, { title = "Debug" })
        return
      end

      local current_path = vim.loop.fs_realpath(current_picker.cwd) or ""
      notify("Current Path: " .. current_path, vim.log.levels.INFO, { title = "Debug" })

      if current_path == project_root then
        notify("You are already at the project root.", vim.log.levels.WARN, { title = "Telescope File Browser" })
        return
      end

      fb_actions.goto_parent_dir(prompt_bufnr)
    end

    -- Telescope setup with custom mapping
    telescope.setup({
      extensions = {
        file_browser = {
          hijack_netrw = true,
          mappings = {
           ["i"] = {
          ["<C-c>"] = fb_actions.create,
          ["<C-r>"] = fb_actions.rename,
          ["<C-mf>"] = fb_actions.move,
          ["<C-y>"] = fb_actions.copy,
          ["<C-d>"] = fb_actions.remove,
          ["<C-o>"] = fb_actions.open,
          ["<C-g>"] = fb_actions.goto_parent_dir,
          ["<C-e>"] = fb_actions.goto_home_dir,
          ["<C-w>"] = fb_actions.goto_cwd,
          ["<C-f>"] = fb_actions.toggle_browser,
          ["<C-h>"] = fb_actions.toggle_hidden,
          ["<C-s>"] = fb_actions.toggle_all,
          ["<bs>"] = fb_actions.backspace,
        },
        
      },
                },
    }})

    -- Load extension
    telescope.load_extension("file_browser")
  end,
}

