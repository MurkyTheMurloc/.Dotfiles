-- plugin/last_modified.lua
--
-- This plugin disables the default netrw file tree and opens the last modified file
-- when you open Neovim with a directory.
-- It checks for any subdirectories starting with "src" (e.g. "src", "src-tauri").
-- If found, it scans all of them; otherwise, it scans the project root.
-- The recursion is constrained to the project scope, and directories for packages
-- and build artifacts (like "node_modules", "target", ".git", etc.) are skipped.
-- In addition, files that appear to be diagnostic output, binary, swap files,
-- or related to Neovim configuration are ignored.

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local uv = vim.loop

-- Utility: Check if a path is a directory using uv.fs_stat
local function is_dir(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory"
end

-- Directories to skip
local skip_dirs = {
    ["node_modules"] = true,
    [".git"] = true,
    [".svn"] = true,
    ["target"] = true, -- skip build directories like "target"
}

-- Check if a file appears to contain a diagnostic JSON message.
-- Reads the first 150 bytes and checks if it starts with '{"$message_type":'
local function is_diagnostic_file(filepath)
    local fd = uv.fs_open(filepath, "r", 438)
    if not fd then
        return false
    end
    local data = uv.fs_read(fd, 150, 0) or ""
    uv.fs_close(fd)
    return #data >= 16 and data:sub(1, 16) == '{"$message_type":'
end

-- Check if a file is binary by reading the first 1024 bytes for a null character.
local function is_binary_file(filepath)
    local fd = uv.fs_open(filepath, "r", 438)
    if not fd then
        return false
    end
    local data = uv.fs_read(fd, 1024, 0) or ""
    uv.fs_close(fd)
    return data:find("\0") ~= nil
end

-- Check if a file appears to be a swap file.
local function is_swap_file(filepath)
    local basename = filepath:match("([^/\\]+)$") or filepath
    if basename:match("^%.#") then
        return true
    end
    if basename:match("%.swp$") or basename:match("%.swo$") then
        return true
    end
    return false
end

-- Check if the file appears to be related to Neovim configuration.
local function is_neovim_related(filepath)
    local lower = filepath:lower()
    if lower:find("nvim") or lower:find("vimrc") or lower:find("init.vim") or lower:find("init.lua") then
        return true
    end
    return false
end

-- Combined check for files that should be skipped.
local function should_skip_file(filepath)
    if is_diagnostic_file(filepath) then
        return true
    end
    if is_swap_file(filepath) then
        return true
    end
    if is_binary_file(filepath) then
        return true
    end
    if is_neovim_related(filepath) then
        return true
    end
    return false
end

-- Determine the directories to scan.
-- Look for subdirectories whose names start with "src". Only include those whose real paths
-- are inside the project (to avoid following symlinks outside). If none are found, use project_dir.
local function get_scan_directories(project_dir, project_real)
    local dirs = {}
    local fd = uv.fs_opendir(project_dir, nil, 100)
    if fd then
        while true do
            local entries = uv.fs_readdir(fd)
            if not entries then break end
            for _, entry in ipairs(entries) do
                if entry.type == 'directory' and entry.name:match("^src") then
                    local full_path = project_dir .. '/' .. entry.name
                    local real = uv.fs_realpath(full_path)
                    if real and real:sub(1, #project_real) == project_real then
                        table.insert(dirs, full_path)
                    end
                end
            end
        end
        uv.fs_closedir(fd)
    end
    if #dirs > 0 then
        return dirs
    else
        return { project_dir }
    end
end

-- Recursively scan a directory and collect all file paths.
-- The recursion is constrained: we check that each subdirectory’s real path is still within the project scope,
-- and we skip directories like those in skip_dirs.
local function scan_dir_recursive(dir, project_real)
    local files = {}

    local function scan(current_dir)
        local fd = uv.fs_opendir(current_dir, nil, 100)
        if not fd then
            return
        end
        while true do
            local entries = uv.fs_readdir(fd)
            if not entries then break end
            for _, entry in ipairs(entries) do
                if entry.name ~= "." and entry.name ~= ".." then
                    local full_path = current_dir .. '/' .. entry.name
                    if entry.type == 'directory' then
                        if not skip_dirs[entry.name] then
                            local real = uv.fs_realpath(full_path)
                            if real and real:sub(1, #project_real) == project_real then
                                scan(full_path)
                            end
                        end
                    elseif entry.type == 'file' then
                        table.insert(files, full_path)
                    end
                end
            end
        end
        uv.fs_closedir(fd)
    end

    scan(dir)
    return files
end

-- Find the most recently modified file (skipping files that should be ignored)
local function get_last_modified_file(dirs, project_real)
    local all_files = {}
    for _, dir in ipairs(dirs) do
        local files = scan_dir_recursive(dir, project_real)
        for _, file in ipairs(files) do
            local stat = uv.fs_stat(file)
            if stat and stat.mtime and stat.mtime.sec then
                table.insert(all_files, { path = file, mtime = stat.mtime.sec })
            end
        end
    end

    table.sort(all_files, function(a, b)
        return a.mtime > b.mtime
    end)

    for _, file in ipairs(all_files) do
        if not should_skip_file(file.path) then
            return file.path
        end
    end

    return nil
end

-- Main logic: when Neovim is started with a single argument that is a directory,
-- ensure we stay within that project scope.
if #vim.fn.argv() == 1 then
    local project_dir = vim.fn.argv()[1]
    if is_dir(project_dir) then
        local project_real = uv.fs_realpath(project_dir)
        if not project_real then
            print("Could not resolve real path for project directory: " .. project_dir)
            return
        end
        local scan_dirs = get_scan_directories(project_dir, project_real)
        local last_file = get_last_modified_file(scan_dirs, project_real)
        if last_file then
            vim.cmd("edit " .. vim.fn.fnameescape(last_file))
        else
            print("No suitable file found in directories: " .. table.concat(scan_dirs, ", "))
        end
    end
end
