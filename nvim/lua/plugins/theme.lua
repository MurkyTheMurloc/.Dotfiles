local colors = {
	string = "#67A771",
	keyword = "#F4766B",
	boolean = "#F69d50",
	class = "#FF6A67",
	type = "#FF9843",
	property = "#c77dff",
	html = "#7EE787",
	delimiter = "#79C0FF",
	test = "#00b4d8",
	fn = "#ffafcc",
	brackets = "#F0F6FC",
	--test = "#FF7B72"
}

return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	opts = {
		flavour = "mocha",                        -- Mocha als Basis für dunkles Theme
		no_italic = true,                         -- Keine Kursivschrift
		transparent_background = not vim.g.neovide, -- Transparenz außer in Neovide
		default_integrations = false,

		-- Farbüberladungen
		color_overrides = {
			all = {
				-- Vollständige Palette, gemappt an deine colors-Tabelle und GitHub Dark
				text = "#c9d1d9",       -- GitHub Dark Textfarbe
				subtext1 = "#8b949e",   -- Sekundärer Text
				subtext0 = "#6e7681",   -- Kommentare
				overlay2 = "#b1bac4",   -- Hover-Effekte
				overlay1 = "#8b949e",   -- Sekundäre Overlays
				overlay0 = colors.brackets, -- Ränder
				surface2 = "#444c56",   -- Helle Fläche
				surface1 = "#30363d",   -- Fläche für Menüs
				surface0 = "#21262d",   -- Fläche für CursorLine
				rose = colors.class,    -- Keyword (aus deiner Tabelle)
				green = "#67A771",      -- String
				peach = "#F69d50",      -- Boolean
				red = "#FF6A67",        -- Class
				yellow = "#FF9843",     -- Type
				mauve = colors.keyword, -- Property
				teal = "#00b4d8",       -- Test
				sky = "#79C0FF",        -- Delimiter
				pink = colors.fn,       -- Function
				flamingo = "#7EE787",   -- HTML
				blue = "#58a6ff",       -- Fallback für andere Blautöne
				sapphire = "#58a6ff",   -- Fallback
				lavender = colors.brackets, -- Fallback für andere Lilatöne
				maroon = "#c9d1d9",     -- Fallback für dunkleres Rot
			},
			mocha = {
				base = "#0d1117", -- GitHub Dark Hintergrund
				mantle = "#161b22", -- Statusleiste
				crust = "#010409", -- Dunkles Schwarz
			},
		},

		-- Integrationen
		integrations = {
			treesitter = true,
			native_lsp = { enabled = false },
			gitsigns = true,
			dap = true,
			dap_ui = true,
			blink_cmp = {
				style = 'bordered',
				enabled = true,
			},
			notify = true,
			snacks = {
				enabled = true,
				indent_scope_color = "peach",
			},
			lsp_trouble = false,
			mini = {
				enabled = true,
			},
			markview = true,
			nvim_surround = true,
			treesitter_context = true
		},

	},

	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
