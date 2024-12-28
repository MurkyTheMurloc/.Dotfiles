
local ts_utils = require("nvim-treesitter.ts_utils")
local telescope = require("telescope.builtin")

local function has_export_statements()
    -- Search for common export patterns in the file
    local export_pattern = [[\v(export\s+\w+|module\.exports)]]
    local found = vim.fn.search(export_pattern, "n") -- Search without moving the cursor
    return found > 0
end

local function rename_with_treesitter(current_word, new_name)
    local bufnr = vim.api.nvim_get_current_buf()
    local root = ts_utils.get_root_for_position(0, 0, bufnr)
    local matches = {}

    if root then
        local function traverse_tree(node)
            if not node then return end
            if ts_utils.get_node_text(node, bufnr)[1] == current_word then
                local start_row, start_col = node:range()
                table.insert(matches, { row = start_row, col = start_col })
            end
            for child in node:iter_children() do
                traverse_tree(child)
            end
        end

        traverse_tree(root)
    end

    -- Replace matches in the current buffer
    for _, pos in ipairs(matches) do
        vim.api.nvim_buf_set_text(0, pos.row, pos.col, pos.row, pos.col + #current_word, { new_name })
    end

    vim.notify("Renamed " .. #matches .. " occurrences to " .. new_name, vim.log.levels.INFO)
end

local function rename_with_telescope(current_word, new_name)
    telescope.grep_string({
        search = current_word,
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local action_state = require("telescope.actions.state")
                local actions = require("telescope.actions")

                local results = action_state.get_selected_entry(prompt_bufnr)
                for _, result in ipairs(results) do
                    local file = result.filename
                    local row, col = result.lnum, result.col
                    local lines = vim.fn.readfile(file)
                    lines[row] = lines[row]:sub(1, col - 1) .. new_name .. lines[row]:sub(col + #current_word)
                    vim.fn.writefile(lines, file)
                end

                vim.notify("Renamed across project", vim.log.levels.INFO)
                actions.close(prompt_bufnr)
            end)
            return true
        end,
    })
end

local function smart_rename()
    local current_word = vim.fn.expand("<cword>")
    if not current_word or current_word == "" then
        vim.notify("No word under the cursor", vim.log.levels.ERROR)
        return
    end

    -- Prompt user for new name
    vim.ui.input({ prompt = "New name: " }, function(new_name)
        if not new_name or new_name == "" then
            vim.notify("Rename canceled", vim.log.levels.INFO)
            return
        end

        if has_export_statements() then
            rename_with_telescope(current_word, new_name)
        else
            rename_with_treesitter(current_word, new_name)
        end
    end)
end

return {
    smart_rename = smart_rename,
}
