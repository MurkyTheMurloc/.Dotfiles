-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local uv = vim.loop

-- Utility: Check if a path is a directory using uv.fs_stat
local function is_dir(path)
    if not path then return false end
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory" or false
end

-- Directories to skip
local skip_dirs = {
    [".astro"] = true,
    ["node_modules"] = true,
    [".git"] = true,
    [".svn"] = true,
    ["target"] = true
}

-- Check if a file is binary by reading the first 1024 bytes for a null character.
local function is_binary_file(filepath)
    local fd = uv.fs_open(filepath, "r", 438)
    if not fd then return false end
    local data = uv.fs_read(fd, 1024, 0) or ""
    uv.fs_close(fd)
    return data:find("%z") ~= nil
end

-- Check if a file appears to be a swap file.
local function is_swap_file(filepath)
    local basename = filepath:match("([^/\\]+)$") or filepath
    return basename:match("^%.#") or basename:match("%.sw[op]$")
end

-- Check if the file appears to be related to Neovim configuration.
local function is_neovim_related(filepath)
    local lower = filepath:lower()
    return lower:find("nvim") or lower:find("vimrc") or lower:find("init%%.vim") or lower:find("init%%.lua")
end

-- Check if a file should be skipped
local function should_skip_file(filepath)
    return is_binary_file(filepath) or is_swap_file(filepath) or is_neovim_related(filepath)
end

-- Get subdirectories matching "src"
local function get_scan_directories(project_dir, project_real)
    local dirs = {}
    local handle = uv.fs_scandir(project_dir)
    if not handle then
        return { project_dir }
    end

    while true do
        local name, t = uv.fs_scandir_next(handle)
        if not name then break end
        if t == "directory" and name:match("^src") then
            local full_path = project_dir .. "/" .. name
            local real = uv.fs_realpath(full_path)
            if real and real:sub(1, #project_real) == project_real then
                table.insert(dirs, full_path)
            end
        end
    end

    return #dirs > 0 and dirs or { project_dir }
end

-- Recursively scan a directory and collect file paths (using fs_scandir)
local function scan_dir_recursive(dir, project_real)
    local files = {}

    local function scan(current_dir)
        local handle = uv.fs_scandir(current_dir)
        if not handle then return end

        while true do
            local name, t = uv.fs_scandir_next(handle)
            if not name then break end

            if name ~= "." and name ~= ".." then
                local full_path = current_dir .. "/" .. name
                if t == "directory" then
                    if not skip_dirs[name] then
                        local real = uv.fs_realpath(full_path)
                        if real and real:sub(1, #project_real) == project_real then
                            scan(full_path)
                        end
                    end
                elseif t == "file" then
                    table.insert(files, full_path)
                end
            end
        end
    end

    scan(dir)
    return files
end

-- Find the most recently modified file (excluding ignored files)
local function get_last_modified_file(dirs, project_real)
    local all_files = {}

    for _, dir in ipairs(dirs) do
        local files = scan_dir_recursive(dir, project_real)
        for _, file in ipairs(files) do
            local stat = uv.fs_stat(file)
            if stat and stat.mtime then
                table.insert(all_files, { path = file, mtime = stat.mtime.sec })
            end
        end
    end

    -- Sort by modification time (newest first)
    table.sort(all_files, function(a, b) return a.mtime > b.mtime end)

    for _, file in ipairs(all_files) do
        if not should_skip_file(file.path) then
            return file.path
        end
    end

    return nil
end

-- Main: Open last modified file when Neovim starts with a directory
if #vim.fn.argv() == 1 and is_dir(vim.fn.argv()[1]) then
    local project_dir = vim.fn.argv()[1]

    if is_dir(project_dir) then
        local project_real = uv.fs_realpath(project_dir)
        if not project_real then
            vim.notify("Could not resolve real path: " .. project_dir, vim.log.levels.ERROR)
            return
        end

        local scan_dirs = get_scan_directories(project_dir, project_real)
        local last_file = get_last_modified_file(scan_dirs, project_real)

        if last_file then
            local resolved_path = vim.loop.fs_realpath(last_file) or last_file

            vim.cmd("edit " .. resolved_path)
            return
        else
            vim.notify("No suitable file found in directories: " .. table.concat(scan_dirs, ", "), vim.log.levels.WARN)
        end
    end
end
