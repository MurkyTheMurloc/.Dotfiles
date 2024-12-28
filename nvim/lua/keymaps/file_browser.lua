return vim.keymap.set("n", "<leader>ee", function()
	require("telescope").extensions.file_browser.file_browser({
 path = vim.fn.getcwd(), -- Set the root to the current working directory
        cwd_to_path = true, -- Restrict navigation to the cwd
    })
end)
