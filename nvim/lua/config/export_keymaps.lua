local modes = { "n", "i", "v", "x", "t", "o" } -- inkl. operator-pending
local keymaps_by_plugin = {}
local known_motions = { "w", "b", "e", "ge", "0", "$", "%", "f", "F", "t", "T", "j", "k" }

for _, m in ipairs(modes) do
	for _, map in ipairs(vim.api.nvim_get_keymap(m)) do
		local plugin = map.desc and map.desc:match("%[(.-)%]") or "unknown"

		-- Kategorie bestimmen
		local category = "normal"
		if map.lhs:match("<leader>") then
			category = "leader"
		elseif map.mode == 'o' or vim.tbl_contains(known_motions, map.lhs) then
			category = "motion"
		end

		keymaps_by_plugin[plugin] = keymaps_by_plugin[plugin] or {}
		table.insert(keymaps_by_plugin[plugin], {
			lhs = map.lhs,
			rhs = map.rhs or "",
			mode = m,
			category = category,
			desc = map.desc or ""
		})
	end
end

-- Ausgabe in Datei
local lines = {}
for plugin, maps in pairs(keymaps_by_plugin) do
	table.insert(lines, "=== " .. plugin .. " ===")
	for _, m in ipairs(maps) do
		table.insert(lines, string.format("[%s][%s][%s] %s -> %s",
			m.mode, m.category, plugin, m.lhs, m.rhs))
	end
end

local out_path = vim.fn.getcwd() .. "/keymaps.txt"

-- Optional: mkdir für Unterordner (falls du z.B. "exports/keymaps.txt" willst)
-- vim.fn.mkdir(vim.fn.fnamemodify(out_path, ":h"), "p")

local ok, err = pcall(vim.fn.writefile, lines, out_path)
if not ok then
	print("❌ Fehler beim Schreiben der Datei:", err)
else
	print("✅ Keymaps exported to " .. out_path)
end
