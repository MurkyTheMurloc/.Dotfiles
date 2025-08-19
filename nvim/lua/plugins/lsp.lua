-- TODO: Keymap



local function find_root_iterative(startpath)
	local path = vim.fs.dirname(startpath) and startpath or vim.fs.dirname(startpath)

	while path do
		-- Prüfe ob tsconfig.json oder package.json im aktuellen Verzeichnis sind
		local has_tsconfig = vim.uv.fs_stat(table.concat(path, "tsconfig.json"))
		local has_package = vim.uv.fs_stat(table.concat(path, "package.json"))

		if has_tsconfig or has_package then
			return path
		end

		local parent = vim.fs.dirname(path)
		if parent == path then -- erreicht Root-Verzeichnis
			vim.notify("path: " .. path)
			break
		end
		path = parent
	end

	vim.notify("path: " .. path)
	return nil
end
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local lsp = require("lspconfig")
			local util = require("lspconfig.util")

			-- Astro `npm:@astrojs/language-server`
			lsp.astro.setup({
				capabilities = capabilities,
				filetypes = { "astro" }
			})


			-- C `brew:llvm`
			lsp.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--offset-encoding=utf-16",
				},
				filetypes = { "c", "cpp", "objc", "objcpp" }
			})
			lsp.tailwindcss.setup({
				filetypes    = { "html", "astro", "typescriptreact" },
				capabilities = capabilities,
				root_dir     = function(fname)
					return util.root_pattern("package.json", "deno.jsonc", "tailwind.css")(fname)
				end
			})
			lsp.graphql.setup({
				cmd = { "graphql-lsp", "server", "-m", "stream" },
				filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
				root_dir = require('lspconfig').util.root_pattern(".graphqlrc*", ".graphql.config.*", "package.json"),
			})


			-- Nix `nil`
			lsp.nil_ls.setup({
				capabilities = capabilities,
			})

			lsp.nushell.setup({
				capabilities = capabilities,
			})
			lsp.ltex.setup({
				settings = {
					ltex = {
						language = "en",    -- Set the grammar language to English
						additionalRules = {
							enablePickyRules = true, -- Enable more advanced grammar rules
						},
					},
				},
				capabilities = capabilities, -- Include Blink.cmp capabilities
			})

			-- CSS `npm:vscode-langservers-extracted`
			lsp.cssls.setup({
				capabilities = capabilities,
				filetypes = { "css", "scss", "less" },
			})


			-- Deno `brew:deno`
			lsp.denols.setup({
				capabilities        = capabilities,
				single_file_support = false,
				on_init             = function(client, init_result)
					-- if our root_dir function returned nil, bail out
					if not client.config.root_dir then
						vim.notify("stoping deno")

						client.stop()
					end
				end,
				root_dir            = function(startpath)
					local deno_root = util.root_pattern("deno.json", "deno.jsonc")(startpath)
					-- is there a deno.json?
					if not deno_root then
						-- no deno.json found -> disable denols
						return nil
					end
					-- found a deno.json
					local ts_root =
							util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(
								startpath
							)
					-- is there a tsconfig.json or package.json?
					if not ts_root then
						-- no tsconfig.json or package.json found -> enable denols
						return deno_root
					end
					if string.len(ts_root) > string.len(deno_root) then
						-- tsconfig.json or package.json is deeper than deno.json -> disable denols
						return nil
					end
					-- tsconfig.json or package.json is either the same or shallower than deno.json -> enable denols
					return deno_root
				end,
			})
			lsp.vtsls.setup({
				capabilities = capabilities,
				settings     = {
					completions = {
						completeFunctionCalls = true,
					},
				},
				on_init      = function(client, init_result)
					-- if our root_dir function returned nil, bail out
					if not client.config.root_dir then
						client.stop()
					end
				end,
				root_dir     = function(startpath)
					local ts_root =
							util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(
								startpath
							)
					if not ts_root then return nil end
					local deno_root = util.root_pattern("deno.json", "deno.jsonc")(startpath)
					if not deno_root then return ts_root end
					if string.len(deno_root) >= string.len(ts_root) then return nil end

					--return find_root_iterative(vim.api.nvim_buf_get_name(0))
					return ts_root
				end,
			})




			-- Docker `npm:dockerfile-language-server-nodejs`
			lsp.dockerls.setup({
				capabilities = capabilities,
				root_dir = util.root_pattern(
					"containerfile",
					"Containerfile",
					"dockerfile",
					"Dockerfile"
				),
			})



			-- Gleam `brew:gleam`
			--lsp.gleam.setup({
			--	capabilities = capabilities,
			--})

			-- Go `brew:go`
			lsp.gopls.setup({
				capabilities = capabilities,
				filetypes = { "go" }
			})

			-- HTML `npm:vscode-langservers-extracted`
			lsp.html.setup({
				capabilities = capabilities,
				filetypes = { "html" }
			})

			-- JSON `npm:vscode-langservers-extracted`
			lsp.jsonls.setup({
				capabilities = capabilities,
				init_options = {
					provideFormatter = false,
				},
			})

			-- Lua `brew:lua-language-server`
			lsp.lua_ls.setup({
				capabilities = capabilities,
				filetypes = { "lua" }
			})

			-- Python `npm:pyright`
			lsp.pyright.setup({
				capabilities = capabilities,
				filetypes = { "python" },
				settings = {
					pyright = {
						-- using ruff's import organizer
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- ignore all files for analysis to exclusively use ruff for linting
							ignore = { "*" },
						},
					},
				},
			})

			-- Python (Linter/Formatter) `brew:ruff`
			lsp.ruff.setup({
				filetypes = { "python" },
				capabilities = capabilities,
				on_init = function(client) client.server_capabilities.hoverProvider = false end,
			})

			-- Rust `brew:rust-analyzer`
			lsp.rust_analyzer.setup({
				capabilities = capabilities,
				filetypes = { "rust" },
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = { command = "clippy" },
					},
				},
				cmd = {
					"rustup", "run", "stable", "rust-analyzer",
				}


			})


			-- WSGL `cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgsl_analyzer`
			lsp.wgsl_analyzer.setup({
				capabilities = capabilities,
			})
		end,
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }
					--vim.keymap.set("n", "k", function() vim.lsp.buf.hover(float_opts) end, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					vim.keymap.set("n", "gb", "<C-o>", opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "g.", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "cd", vim.lsp.buf.rename, opts)
				end,
			})
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
