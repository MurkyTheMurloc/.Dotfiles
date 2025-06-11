local M = {}

local ts_utils = require('nvim-treesitter.ts_utils')
local parsers = require('nvim-treesitter.parsers')

-- Helper function to get the 0-indexed range of a node
local function get_node_range(node)
	local start_row, start_col, end_row, end_col = node:range()
	return {
		start = { line = start_row, col = start_col },
		finish = { line = end_row, col = end_col },
	}
end

-- Helper function to delete a text range (0-indexed)
local function delete_range(bufnr, range)
	vim.api.nvim_buf_set_text(bufnr, range.start.line, range.start.col, range.finish.line, range.finish.col, {})
end

function M.delete_current_tag_pair()
	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	local lang = parsers.ft_to_lang(filetype)

	if not lang then
		vim.notify("DeleteTagPair: Treesitter parser not found for filetype: " .. filetype, vim.log.levels.WARN)
		return
	end

	-- Ensure the parser is installed and available for the current buffer's language
	if not parsers.has_parser(lang) then
		vim.notify(
			"DeleteTagPair: Treesitter parser not installed or readily available for language: " ..
			lang .. ". Try :TSInstall " .. lang, vim.log.levels.WARN)
		return
	end

	local parser = parsers.get_parser(bufnr, lang) -- Pass bufnr for buffer-specific parser if available
	if not parser then
		vim.notify("DeleteTagPair: Treesitter parser could not be loaded for language: " .. lang, vim.log.levels.WARN)
		return
	end

	local tree = parser:parse()[1]
	if not tree then
		vim.notify("DeleteTagPair: Could not parse buffer.", vim.log.levels.WARN)
		return
	end

	local root = tree:root()
	local current_node_at_cursor = ts_utils.get_node_at_cursor()

	if not current_node_at_cursor then
		return -- No Treesitter node at cursor, do nothing silently
	end

	-- Define query patterns for different languages/tag types
	local queries = {
		html = {
			element = [[(element (start_tag) @opening_tag (end_tag)? @closing_tag) @element]],
			self_closing_element = [[(self_closing_tag) @self_closing]],
			comment = [[(comment) @comment]]
		},
		astro = { -- Astro uses HTML syntax for tags primarily
			element = [[(element (start_tag) @opening_tag (end_tag)? @closing_tag) @element]],
			self_closing_element = [[(self_closing_tag) @self_closing]],
			comment =
			[[(comment) @comment]] -- Astro comments .. [[(frontmatter) @comment]] -- Treat frontmatter as off-limits
		},
		typescriptreact = {   -- TSX/JSX
			element = [[(jsx_element (jsx_opening_element) @opening_tag (jsx_closing_element)? @closing_tag) @element]],
			self_closing_element = [[(jsx_self_closing_element) @self_closing]],
			comment = [[ [(comment) (string_fragment)] @comment ]] -- string_fragment for template literal comments
		},
		javascriptreact = {                                   -- JSX in JS files
			element = [[(jsx_element (jsx_opening_element) @opening_tag (jsx_closing_element)? @closing_tag) @element]],
			self_closing_element = [[(jsx_self_closing_element) @self_closing]],
			comment = [[ [(comment) (string_fragment)] @comment ]]
		},
		vue = { -- Vue templates are similar to HTML
			element = [[(element (start_tag) @opening_tag (end_tag)? @closing_tag) @element]],
			self_closing_element = [[(self_closing_tag) @self_closing]],
			comment = [[(comment) @comment]]
		},
		svelte = { -- Svelte templates are similar to HTML
			element = [[(element (start_tag) @opening_tag (end_tag)? @closing_tag) @element]],
			self_closing_element = [[(self_closing_tag) @self_closing]],
			comment = [[(comment) @comment]]
		}
	}

	local lang_queries = queries[filetype]
	if not lang_queries then
		-- Fallback to HTML if specific queries are not defined, or notify
		if queries.html then
			lang_queries = queries.html
			vim.notify("DeleteTagPair: Using HTML queries as fallback for filetype: " .. filetype, vim.log.levels.INFO)
		else
			vim.notify("DeleteTagPair: No tag queries defined for filetype: " .. filetype, vim.log.levels.WARN)
			return
		end
	end

	-- Function to check if cursor is within a node's range (0-indexed cursor)
	local function is_cursor_in_node(node, cursor_row, cursor_col)
		if not node then return false end
		local srow, scol, erow, ecol = node:range()
		return cursor_row >= srow and cursor_row <= erow and
				cursor_col >= scol and cursor_col <= ecol
	end

	local cursor_pos_api = vim.api.nvim_win_get_cursor(0) -- {row, col} 1-indexed
	local cursor_row_zero_based = cursor_pos_api[1] - 1
	local cursor_col_zero_based = cursor_pos_api[2]


	-- 1. Check if cursor is inside a comment node
	if lang_queries.comment then
		local comment_ts_query = vim.treesitter.query.parse(lang, lang_queries.comment)
		if comment_ts_query then
			for _, node, _ in comment_ts_query:iter_captures(root, bufnr, 0, -1) do
				if is_cursor_in_node(node, cursor_row_zero_based, cursor_col_zero_based) then
					-- vim.notify("DeleteTagPair: Cursor is inside a comment, no action.", vim.log.levels.INFO)
					return -- Do nothing if inside a comment
				end
			end
		end
	end

	local opening_tag_node = nil
	local closing_tag_node = nil
	local self_closing_tag_node = nil
	local found_element_node = nil

	-- Iterate upwards from the current node at cursor to find the encompassing element
	local search_node_iter = current_node_at_cursor
	while search_node_iter do
		-- Check for self-closing tags first
		if lang_queries.self_closing_element then
			local query_sc = vim.treesitter.query.parse(lang, lang_queries.self_closing_element)
			if query_sc then
				for _, node_capture, _ in query_sc:iter_captures(search_node_iter, bufnr) do
					if is_cursor_in_node(node_capture, cursor_row_zero_based, cursor_col_zero_based) then
						self_closing_tag_node = node_capture
						goto process_tags -- Jump to processing
					end
				end
			end
		end

		-- Check for regular elements (opening/closing pair)
		if lang_queries.element then
			local query_el = vim.treesitter.query.parse(lang, lang_queries.element)
			if query_el then
				for _, node_capture, _ in query_el:iter_captures(search_node_iter, bufnr) do
					local capture_name = query_el.captures
							[select(2, query_el:iter_captures(search_node_iter, bufnr, search_node_iter:start_row(), search_node_iter:end_row()))[select('#', query_el:iter_captures(search_node_iter, bufnr, search_node_iter:start_row(), search_node_iter:end_row())) - 1]] -- Get name of last capture for the match

					-- We are interested in the overall "@element" if cursor is within it
					if query_el.captures[select(2, query_el:iter_captures(node_capture, bufnr, node_capture:start_row(), node_capture:end_row()))[select('#', query_el:iter_captures(node_capture, bufnr, node_capture:start_row(), node_capture:end_row())) - 1]] == "element" and is_cursor_in_node(node_capture, cursor_row_zero_based, cursor_col_zero_based) then
						found_element_node = node_capture -- This is the main <element>...</element> node
						break
					end
				end
			end
		end

		if found_element_node then break end -- Found the encompassing element
		search_node_iter = search_node_iter:parent()
	end

	::process_tags::

	if self_closing_tag_node then
		-- Only one tag to delete
		local range = get_node_range(self_closing_tag_node)
		delete_range(bufnr, range)
		-- vim.notify("DeleteTagPair: Self-closing tag deleted.", vim.log.levels.INFO)
		return
	end

	if found_element_node then
		-- Query within the found_element_node for its opening and closing parts
		if lang_queries.element then
			local query_el_inner = vim.treesitter.query.parse(lang, lang_queries.element)
			if query_el_inner then
				for _, inner_node, _ in query_el_inner:iter_captures(found_element_node, bufnr) do
					local inner_capture_name = query_el_inner.captures
							[select(2, query_el_inner:iter_captures(inner_node, bufnr, inner_node:start_row(), inner_node:end_row()))[select('#', query_el_inner:iter_captures(inner_node, bufnr, inner_node:start_row(), inner_node:end_row())) - 1]]
					if inner_capture_name == "opening_tag" then
						opening_tag_node = inner_node
					elseif inner_capture_name == "closing_tag" then
						closing_tag_node = inner_node
					end
				end
			end
		end
	else
		-- vim.notify("DeleteTagPair: Cursor is not on a recognized tag element.", vim.log.levels.INFO)
		return
	end

	if not opening_tag_node then
		-- vim.notify("DeleteTagPair: Could not identify an opening tag to delete.", vim.log.levels.INFO)
		return
	end

	local ranges_to_delete = {}
	if closing_tag_node then -- Closing tag is optional (e.g. void elements, or just not present)
		table.insert(ranges_to_delete, get_node_range(closing_tag_node))
	end
	table.insert(ranges_to_delete, get_node_range(opening_tag_node))


	if #ranges_to_delete == 0 then
		return
	end

	-- Sort ranges by start line and column in descending order for safe deletion
	table.sort(ranges_to_delete, function(a, b)
		if a.start.line == b.start.line then
			return a.start.col > b.start.col
		end
		return a.start.line > b.start.line
	end)

	-- Apply deletions
	for _, range in ipairs(ranges_to_delete) do
		delete_range(bufnr, range)
	end
	-- vim.notify("DeleteTagPair: Tag pair deleted.", vim.log.levels.INFO)
end

function M.setup(opts)
	opts = opts or {}
	local keymap = opts.keymap or "dt"

	vim.api.nvim_create_user_command(
		'DeleteTagPair',
		M.delete_current_tag_pair,
		{ desc = "Delete current HTML/JSX tag pair" }
	)

	local group = vim.api.nvim_create_augroup("DeleteTagPairKeymapGroup", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "html", "astro", "typescriptreact", "javascriptreact", "vue", "svelte" },
		group = group,
		callback = function(args)
			vim.keymap.set("n", keymap, M.delete_current_tag_pair,
				{ noremap = true, silent = true, buffer = args.buf, desc = "Delete HTML/JSX tag pair" })
		end,
	})
end

return M
