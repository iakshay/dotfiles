return {
	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ "lazy.nvim", words = { "lazy", "LazySpec" } },
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Configure diagnostic display
			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					prefix = "●",
					severity = {
						min = vim.diagnostic.severity.HINT,
					},
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
				underline = true,
				update_in_insert = false, -- Don't update diagnostics while typing
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)

					local opts = { buffer = event.buf }
					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition()
					end, opts)
					vim.keymap.set("n", "K", function()
						vim.lsp.buf.hover()
					end, opts)
					vim.keymap.set("n", "<leader>ws", function()
						vim.lsp.buf.workspace_symbol()
					end, opts)
					vim.keymap.set("n", "<leader>ds", function()
						vim.lsp.buf.document_symbol()
					end, opts)
					vim.keymap.set("n", "<leader>dw", function()
						vim.diagnostic.open_float()
					end, opts)
					vim.keymap.set("n", "<leader>ca", function()
						vim.lsp.buf.code_action()
					end, opts)
					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help()
					end, opts)
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.goto_next()
					end, opts)
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.goto_prev()
					end, opts)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Enable inlay hints for supported languages and add toggle
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						-- Enable inlay hints by default
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
						-- Add keybinding to toggle inlay hints
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
								{ bufnr = event.buf }
							)
						end, "[T]oggle Inlay [H]ints")
					end

					-- Document highlighting is disabled by default for performance.
					-- Uncomment the section below to enable highlighting references under cursor.
					-- Note: This can impact performance on large files.
					--
					-- if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					-- 	local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					-- 	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					-- 		buffer = event.buf,
					-- 		group = highlight_augroup,
					-- 		callback = vim.lsp.buf.document_highlight,
					-- 	})
					-- 	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					-- 		buffer = event.buf,
					-- 		group = highlight_augroup,
					-- 		callback = vim.lsp.buf.clear_references,
					-- 	})
					-- 	vim.api.nvim_create_autocmd("LspDetach", {
					-- 		group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					-- 		callback = function(event2)
					-- 			vim.lsp.buf.clear_references()
					-- 			vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
					-- 		end,
					-- 	})
					-- end

					-- Rust-specific keybindings: Open registry crate in new WezTerm tab
					if vim.bo[event.buf].filetype == "rust" then
						map("<leader>rc", function()
							local current_file = vim.api.nvim_buf_get_name(0)
							-- vim.notify("Current file: " .. current_file, vim.log.levels.INFO)

							if current_file:match("%.cargo/registry/") then
								-- vim.notify("Found cargo registry pattern", vim.log.levels.INFO)

								-- Extract crate root directory - match the full path pattern
								local crate_root = current_file:match("(.*/%.cargo/registry/src/[^/]+/[^/]+)")
								-- vim.notify("Crate root: " .. (crate_root or "nil"), vim.log.levels.INFO)

								if crate_root then
									-- Get the file path relative to the crate root
									local relative_file = current_file:gsub(
										"^" .. crate_root:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])", "%%%1") .. "/",
										""
									)
									local crate_name = crate_root:match("([^/]+)$"):gsub("-[%d%.%-]+$", "") -- Remove version suffix

									-- Build the command
									local spawn_cmd = string.format(
										"wezterm cli spawn --cwd %s -- nvim %s",
										vim.fn.shellescape(crate_root),
										vim.fn.shellescape(relative_file)
									)
									-- Open new WezTerm tab, cd to crate root, then open the file
									local result = vim.fn.system(spawn_cmd)

									-- Extract pane ID from result and set tab title
									local pane_id = result:match("(%d+)")

									if not pane_id then
										-- vim.notify("Could not extract pane ID from result", vim.log.levels.WARN)
									else
										local title_cmd = string.format(
											'wezterm cli set-tab-title --pane-id %s "%s"',
											pane_id,
											crate_name
										)
										vim.fn.system(title_cmd)
									end
								else
									-- vim.notify("Could not extract crate root", vim.log.levels.WARN)
								end
								-- vim.notify(
								-- 	string.format("Opened crate %s in new WezTerm tab", vim.fn.shellescape(crate_root)),
								-- 	vim.log.levels.INFO
								-- )
							else
								-- vim.notify("Not in a Cargo registry crate", vim.log.levels.WARN)
							end
						end, "[R]egistry [C]rate in new tab")
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Set offsetEncoding to utf-16 to avoid warnings with multiple LSP clients (e.g., Copilot + rust-analyzer)
			capabilities.offsetEncoding = { "utf-16" }

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				-- clangd = {},
				-- gopls = {},
				pyright = {
					settings = {
						python = {
							pythonPath = vim.fn.trim(vim.fn.system("which python")),
							-- pythonPath = vim.fn.exepath("python"),
							analysis = {
								indexing = true,
								typeCheckingMode = "basic",
								diagnosticMode = "workspace",
								autoImportCompletions = true,
							},
						},
					},
				},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--
				yamlls = {
					schemas = {
						kubernetes = "k8s-*.yaml",
						["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
						["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
						["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
						["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
						["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
						["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
						["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
					},
				},

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},

				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							cargo = {
								features = "all",
								-- Build only the current package, not workspace dependencies
								-- buildScripts = {
								-- 	enable = true,
								-- },
							},
							-- Enable diagnostics from cargo check (clippy disabled for performance)
							checkOnSave = {
								enable = true,
								command = "check",
							},
							-- Disable import grouping for faster analysis
							imports = {
								group = {
									enable = false,
								},
							},
							-- Disable postfix completions for cleaner suggestions
							completion = {
								postfix = {
									enable = false,
								},
							},
							-- Configure inlay hints for optimal performance and readability
							inlayHints = {
								bindingModeHints = { enable = false },
								chainingHints = { enable = true },
								closingBraceHints = { enable = true, minLines = 25 },
								closureReturnTypeHints = { enable = "never" },
								lifetimeElisionHints = { enable = "never", useParameterNames = false },
								maxLength = 25,
								parameterHints = { enable = true },
								reborrowHints = { enable = "never" },
								renderColons = true,
								typeHints = {
									enable = true,
									hideClosureInitialization = false,
									hideNamedConstructor = false,
								},
							},
							-- Performance optimizations
							procMacro = {
								enable = true,
							},
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup({
				registries = {
					"github:mason-org/mason-registry",
					-- "file:~/.config/nvim/mason-registry",
				},
			})

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"vtsls",
				"terraform-ls",
				"markdownlint-cli2",
				"prettier",
				"prettierd",
				-- "tailwindcss-language-server",
				"helm-ls",
				-- "kulala-fmt",
				"stylua", -- Used to format Lua code
				"codelldb", -- Debug adapter for Rust/C++
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"kiyoon/python-import.nvim",
		enabled = false,
		-- build = "pipx install . --force",
		build = "uv tool install . --force --reinstall",
		keys = {
			{
				"<M-CR>",
				function()
					require("python_import.api").add_import_current_word_and_notify()
				end,
				mode = { "i", "n" },
				silent = true,
				desc = "Add python import",
				ft = "python",
			},
			{
				"<M-CR>",
				function()
					require("python_import.api").add_import_current_selection_and_notify()
				end,
				mode = "x",
				silent = true,
				desc = "Add python import",
				ft = "python",
			},
			{
				"<space>i",
				function()
					require("python_import.api").add_import_current_word_and_move_cursor()
				end,
				mode = "n",
				silent = true,
				desc = "Add python import and move cursor",
				ft = "python",
			},
			{
				"<space>i",
				function()
					require("python_import.api").add_import_current_selection_and_move_cursor()
				end,
				mode = "x",
				silent = false,
				desc = "Add python import and move cursor",
				ft = "python",
			},
			{
				"<space>tr",
				function()
					require("python_import.api").add_rich_traceback()
				end,
				silent = true,
				desc = "Add rich traceback",
				ft = "python",
			},
		},
		opts = {
			-- Example 1:
			-- Default behaviour for `tqdm` is `from tqdm.auto import tqdm`.
			-- If you want to change it to `import tqdm`, you can set `import = {"tqdm"}` and `import_from = {tqdm = nil}` here.
			-- If you want to change it to `from tqdm import tqdm`, you can set `import_from = {tqdm = "tqdm"}` here.

			-- Example 2:
			-- Default behaviour for `logger` is `import logging`, ``, `logger = logging.getLogger(__name__)`.
			-- If you want to change it to `import my_custom_logger`, ``, `logger = my_custom_logger.get_logger()`,
			-- you can set `statement_after_imports = {logger = {"import my_custom_logger", "", "logger = my_custom_logger.get_logger()"}}` here.
			extend_lookup_table = {
				---@type string[]
				import = {
					-- "tqdm",
				},

				---@type table<string, string>
				import_as = {
					-- These are the default values. Here for demonstration.
					-- np = "numpy",
					-- pd = "pandas",
				},

				---@type table<string, string>
				import_from = {
					-- tqdm = nil,
					-- tqdm = "tqdm",
				},

				---@type table<string, string[]>
				statement_after_imports = {
					-- logger = { "import my_custom_logger", "", "logger = my_custom_logger.get_logger()" },
				},
			},

			---Return nil to indicate no match is found and continue with the default lookup
			---Return a table to stop the lookup and use the returned table as the result
			---Return an empty table to stop the lookup. This is useful when you want to add to wherever you need to.
			---@type fun(winnr: integer, word: string, ts_node: TSNode?): string[]?
			custom_function = function(winnr, word, ts_node)
				-- if vim.endswith(word, "_DIR") then
				--   return { "from my_module import " .. word }
				-- end
			end,
		},
	},
}
