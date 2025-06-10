local fuzzy = require("blink.cmp.fuzzy")
local utils = require("blink.cmp.lib.utils")
local type = require('blink.cmp.types').CompletionItemKind

local ts_utils = require("nvim-treesitter.ts_utils")


local OPENING = {
	jsx_element               = true,
	jsx_self_closing_element  = true,
	html_element              = true,
	html_self_closing_element = true,
	component                 = true, -- Astro component open
	component_self_close      = true, -- Astro self‑closing
}

local CLOSING = {
	jsx_closing_element  = true,
	html_closing_element = true,
	component_close      = true, -- Astro component close
}
local HTML_TAGS = {
	a = true,
	abbr = true,
	address = true,
	area = true,
	article = true,
	aside = true,
	audio = true,
	b = true,
	base = true,
	bdi = true,
	bdo = true,
	blockquote = true,
	body = true,
	br = true,
	button = true,
	canvas = true,
	caption = true,
	cite = true,
	code = true,
	col = true,
	colgroup = true,
	data = true,
	datalist = true,
	dd = true,
	del = true,
	details = true,
	dfn = true,
	dialog = true,
	div = true,
	dl = true,
	dt = true,
	em = true,
	embed = true,
	fieldset = true,
	figcaption = true,
	figure = true,
	footer = true,
	form = true,
	h1 = true,
	h2 = true,
	h3 = true,
	h4 = true,
	h5 = true,
	h6 = true,
	head = true,
	header = true,
	hgroup = true,
	hr = true,
	html = true,
	i = true,
	iframe = true,
	img = true,
	input = true,
	ins = true,
	kbd = true,
	label = true,
	legend = true,
	li = true,
	link = true,
	main = true,
	map = true,
	mark = true,
	menu = true,
	meta = true,
	meter = true,
	nav = true,
	noscript = true,
	object = true,
	ol = true,
	optgroup = true,
	option = true,
	output = true,
	p = true,
	param = true,
	picture = true,
	pre = true,
	progress = true,
	q = true,
	rp = true,
	rt = true,
	ruby = true,
	s = true,
	samp = true,
	script = true,
	section = true,
	select = true,
	small = true,
	source = true,
	span = true,
	strong = true,
	style = true,
	sub = true,
	summary = true,
	sup = true,
	table = true,
	tbody = true,
	td = true,
	template = true,
	textarea = true,
	tfoot = true,
	th = true,
	thead = true,
	time = true,
	title = true,
	tr = true,
	track = true,
	u = true,
	ul = true,
	var = true,
	video = true,
	wbr = true,
}

local function get_target_and_closing(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local node = ts_utils.get_node_at_cursor()
	if not node then return end

	-- Walk up until we find any opening element
	while node and not OPENING[node:type()] do
		node = node:parent()
	end
	if not node then return end

	-- Self‑closing case
	if node:type():find("self_closing") then
		return node, node
	end

	-- Normal element: find its closing child
	local closing = nil
	for child in node:iter_children() do
		if CLOSING[child:type()] then
			closing = child
			break
		end
	end

	if not closing then
		vim.notify("No closing tag found for " .. node:type(), vim.log.levels.ERROR)
		return
	end

	return node, closing
end


local function wrap_with_tag(wrap_tag, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local target, closing = get_target_and_closing(bufnr)
	if not target or not closing then
		vim.notify("Nothing to wrap", vim.log.levels.WARN)
		return false
	end

	-- get start/end rows
	local s_row  = select(1, target:range())
	-- select(3) gives the end_row of the closing element
	local e_row  = select(3, closing:range())

	-- detect indent
	local line   = vim.api.nvim_buf_get_lines(bufnr, s_row, s_row + 1, false)[1]
	local indent = line:match("^(%s*)") or ""

	-- wrapper lines
	local before = { indent .. "<" .. wrap_tag .. ">" }
	local after  = { indent .. "</" .. wrap_tag .. ">" }

	-- 1) remove the original opening line
	vim.api.nvim_buf_set_lines(bufnr, s_row, s_row + 1, false, {})

	-- 2) insert the wrapper’s opening tag at s_row
	vim.api.nvim_buf_set_lines(bufnr, s_row, s_row, false, before)
	local indent_len  = #indent
	local cursor_line = s_row + 1
	local cursor_col  = indent_len + 1 + #wrap_tag
	vim.api.nvim_win_set_cursor(0, { cursor_line, cursor_col })

	-- 3) insert the wrapper’s closing tag **immediately after** the JSX closing element
	--    that’s at line e_row, so we place it at e_row + 1
	vim.api.nvim_buf_set_lines(
		bufnr,
		e_row + 1,
		e_row + 1,
		false,
		after
	)

	return true
end
--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

-- `opts` table comes from `sources.providers.your_provider.opts`
-- You may also accept a second argument `config`, to get the full
-- `sources.providers.your_provider` table
function source.new(opts)
	--    vim.validate('your_source.opts.some_option', opts.some_option, { 'string' })
	--    vim.validate('your_source.opts.optional_option', opts.optional_option, { 'string' }, true)

	local self = setmetatable({}, { __index = source })
	self.opts = opts
	return self
end

-- (Optional) Enable the source in specific contexts only
function source:enabled()
	return vim.bo.filetype == 'html' or vim.bo.filetype == "astro" or
			vim.bo.filetype == "typescriptreact"
end

-- (Optional) Non-alphanumeric characters that trigger the source
--function source:get_trigger_characters() return { '<' } end

function source:get_completions(ctx, callback)
	local bufnr    = ctx.bufnr
	local row, col = ctx.cursor[1] - 1, ctx.cursor[2]
	local line     = ctx.line or ctx.get_line()
	local params   = { textDocument = { uri = vim.uri_from_bufnr(bufnr) }, position = { line = row, character = col } }


	vim.lsp.buf_request(bufnr, "textDocument/completion", params, function(err, result)
		if err or not result then
			return callback({ items = {}, is_incomplete = false })
		end

		-- Normalize to flat list
		local raw = {}
		if vim.islist(result) then
			vim.list_extend(raw, result)
		elseif result.items then
			vim.list_extend(raw, result.items)
		end

		-- 3) decorate each raw item into a blink.cmp.CompletionItem
		for i, item in ipairs(raw) do
			raw[i] = vim.tbl_extend("force", {
				source_name   = "lsp",
				source_id     = "lsp",
				cursor_column = col,
			}, item)
		end
		local haystacks_by_provider = {
			lsp = raw,
		}


		-- you can pass `nil` for range and blink will default to matching the whole word
		local scored = fuzzy.fuzzy(line, col, haystacks_by_provider, "full")


		local top_10 = {}


		for i = 1, math.min(5, #scored) do
			table.insert(top_10, scored[i])
			local deep_copy = utils.shallow_copy(scored[i])
			local label = deep_copy.label
			if HTML_TAGS[label] or label:match("^[A-Z]") or label:match("<>") then
				deep_copy.label      = "wrap inside " .. label
				deep_copy.filterText = label
				deep_copy.sortText   = label
				deep_copy.score      = deep_copy.score - 1
				deep_copy.kind       = type.Function
				deep_copy.data       = { wrap_tag = label }
				table.insert(top_10, deep_copy)
			end
		end

		return callback({
			items = top_10,
			-- Whether blink.cmp should request items when deleting characters
			-- from the keyword (i.e. "foo|" -> "fo|")
			-- Note that any non-alphanumeric characters will always request
			-- new items (excluding `-` and `_`)
			is_incomplete_backward = false,
			-- Whether blink.cmp should request items when adding characters
			-- to the keyword (i.e. "fo|" -> "foo|")
			-- Note that any non-alphanumeric characters will always request
			-- new items (excluding `-` and `_`)
			is_incomplete_forward = false,
		})

		-- The callback _MUST_ be called at least once. The first time it's called,
		-- blink.cmp will show the results in the completion menu. Subsequent calls
		-- will append the results to the menu to support streaming results.
	end)




	-- (Optional) Return a function which cancels the request
	-- If you have long running requests, it's essential you support cancellation
	return function() end
end

-- (Optional) Before accepting the item or showing documentation, blink.cmp will call this function
-- so you may avoid calculating expensive fields (i.e. documentation) for only when they're actually needed
function source:resolve(item, callback)
	item = vim.deepcopy(item)

	-- Shown in the documentation window (<C-space> when menu open by default)
	item.documentation = {
		kind = 'markdown',
		value = '# Foo\n\nBar',
	}



	callback(item)
end

-- Called immediately after applying the item's textEdit/insertText
function source:execute(ctx, item, callback, default_implementation)
	-- By default, your source must handle the execution of the item itself,
	-- but you may use the default implementation at any time
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.fn.getline(row)

	-- Simulate the line after the character is inserted
	local before_cursor = line:sub(1, col) .. vim.v.char

	local label = item.label
	if label:match("%f[%a]wrap%f[%A]") then
		local success = wrap_with_tag(item.filterText, ctx.bufnr)
		if success then

		else
			vim.notify("default")
			default_implementation(ctx, item)
		end
	else
		default_implementation(ctx, item)
	end




	-- The callback _MUST_ be called once
	callback()
end

return source
