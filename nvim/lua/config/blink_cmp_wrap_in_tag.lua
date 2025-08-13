local fuzzy = require("blink.cmp.fuzzy")
local utils = require("blink.cmp.lib.utils")
local type = require('blink.cmp.types').CompletionItemKind

local lsp_source = require("blink.cmp.sources.lsp") -- blink's official LSP source
local lsp = lsp_source




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
	lsp:get_completions(ctx, function(result)
		local items = result.items or {}

		local extended_items = {}

		for _, item in ipairs(items) do
			table.insert(extended_items, item)

			local label = item.label
			if HTML_TAGS[label] or label:match("^[A-Z]") or label:match("<>") then
				local wrap_item = vim.deepcopy(item)
				wrap_item.label = "wrap inside " .. label
				wrap_item.insertText = label
				wrap_item.filterText = label
				wrap_item.sortText = label
				wrap_item.score = (wrap_item.score or 0) - 1
				wrap_item.kind = type.Function
				wrap_item.data = { wrap_tag = label }
				table.insert(extended_items, wrap_item)
			end
		end

		callback({
			items = extended_items,
			is_incomplete_backward = result.is_incomplete_backward,
			is_incomplete_forward = result.is_incomplete_forward,
		})
	end)
end

function source:resolve(item, callback)
	if lsp.resolve then
		lsp:resolve(item, callback)
	else
		callback(item)
	end
end -- Called immediately after applying the item's textEdit/insertText

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
			default_implementation(ctx, item)
		end
	else
		default_implementation(ctx, item)
	end




	-- The callback _MUST_ be called once
	callback()
end

return source
