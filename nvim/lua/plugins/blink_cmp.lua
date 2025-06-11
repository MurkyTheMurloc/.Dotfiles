return {
	{
		'saghen/blink.cmp',
		event = { "InsertEnter" },
		lazy = false,
		dependencies = {
			"xzbdmw/colorful-menu.nvim",
			"Fildo7525/pretty_hover",
			{
				"Kaiser-Yang/blink-cmp-dictionary",
				dependencies = { "nvim-lua/plenary.nvim" },
			},
			"alexandre-abrioux/blink-cmp-npm.nvim",
			"erooke/blink-cmp-latex",
			"echasnovski/mini.icons",
		},
		version = "1.*",
		opts = {
			sources = {
				default = { 'buffer', 'lsp', 'path', "snippets", "npm", "latex" },
				per_filetype = {
					html = { 'tagwrap' },
					astro = { 'tagwrap' },
					typescriptreact = { 'tagwrap' },
					json = { "npm" },
					latex = { "latex" },
				},
				providers = {
					latex = {
						name = "Latex",
						module = "blink-cmp-latex",
						opts = {
							insert_command = false,
						},
					},
					tagwrap = {
						name = "tags",
						module = "config.blink_cmp_wrap_in_tag",
					},
					npm = {
						name = "npm",
						module = "blink-cmp-npm",
						async = true,
						score_offset = 100,
						opts = {
							ignore = {},
							only_semantic_versions = true,
							only_latest_version = false,
						},
					},
					dictionary = {
						module = "blink-cmp-dictionary",
						name = "Dict",
						min_keyword_length = 3,
						opts = {
							dictionary_files = { vim.fn.expand("~/.config/nvim/dictionary/words.dict") },
						},
					},
				},
			},
			keymap = {
				preset = 'enter',
				["<Tab>"] = {
					fn = function(cmp)
						cmp.select_and_accept({ auto_insert = false })
					end,
				},
			},
			appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
			signature = {
				enabled = true,
				window = {
					winblend = vim.g.neovide and 50 or 0,
					max_width = 100,
					border = "rounded",
					scrollbar = false,
					direction_priority = {
						menu_north = { 'n' },
						menu_east = { "n" },
						menu_south = { "n" },
						menu_west = { "n" },
					},
					treesitter_highlighting = true,
					show_documentation = true,
				},
			},
			fuzzy = { implementation = 'prefer_rust_with_warning' },
			completion = {
				accept = {
					dot_repeat = true,
					create_undo_point = true,
					resolve_timeout_ms = 100,
					auto_brackets = {
						enabled = true,
						default_brackets = { '(', ')' },
						override_brackets_for_filetypes = {},
						kind_resolution = {
							enabled = true,
							blocked_filetypes = { 'typescriptreact', 'astro', 'vue' },
						},
						semantic_token_resolution = {
							enabled = true,
							blocked_filetypes = { 'java' },
							timeout_ms = 400,
						},
					},
				},
				col_offset = -3,
				documentation = {
					winblend = vim.g.neovide and 50 or 0,
					treesitter_highlighting = true,
					auto_show = true,
					auto_show_delay_ms = 1,
					update_delay_ms = 50,
					window = {
						scrollbar = false,
						min_width = 104,
						max_width = 104,
						border = "rounded",
						win_config = {
							override = function(default_config)
								default_config.col = 0
								return default_config
							end,
						},
						direction_priority = {
							menu_north = { 'n' },
							menu_east = { "n" },
							menu_south = { "n" },
							menu_west = { "n" },
						},
					},
					draw = function(opts)
						if opts.item and opts.item.documentation then
							local out = require("pretty_hover.parser").parse(opts.item.documentation.value)
							opts.item.documentation.value = out:string()
						end
						opts.default_implementation(opts)
					end,
				},
				menu = {
					min_width = 100,
					max_width = 100,
					border = "rounded",
					treesitter_highlighting = true,
					scrollbar = false,
					draw = {
						columns = { { "kind_icon" }, { "label" } },
						components = {
							label = {
								width = { max = 100, min = 100 },
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
					},
				},
				ghost_text = {
					enabled = false,
				},
			},
			opts_extend = { "sources.default" },
		},
	},
}
