return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = { "rust" },
		init = function()
			vim.g.rustaceanvim = {
				-- Plugin configuration
				tools = {
					hover_actions = {
						auto_focus = true,
					},
					test_executor = {
						type = "background",
						auto_focus = false,
					},
				},
				-- LSP configuration
				server = {
					capabilities = (function()
						local capabilities = vim.lsp.protocol.make_client_capabilities()
						capabilities =
							vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
						-- Force UTF-16 encoding to prevent conflicts with other LSP clients
						capabilities.general = capabilities.general or {}
						capabilities.general.positionEncodings = { "utf-16" }
						capabilities.offsetEncoding = { "utf-16" }
						return capabilities
					end)(),
					on_init = function(client)
						-- Graceful error handling for rust-analyzer initialization
						if client.name == "rust_analyzer" then
							-- Set position encoding to UTF-16 to match rust-analyzer expectations
							client.offset_encoding = "utf-16"
							vim.notify("rust-analyzer initialized", vim.log.levels.INFO)
						end
					end,
					on_exit = function(code, signal, client_id)
						-- Handle LSP crashes gracefully
						if code ~= 0 then
							vim.notify(
								string.format(
									"rust-analyzer exited with code %d. Run ':RustLsp restart' to restart.",
									code
								),
								vim.log.levels.WARN
							)
						end
					end,
					settings = {
						["rust-analyzer"] = {
							cargo = {
								features = "all",
							},
							checkOnSave = {
								enable = false,
								command = "clippy",
								extraArgs = { "--", "-D", "warnings" },
							},
							imports = {
								group = {
									enable = false,
								},
							},
							completion = {
								postfix = {
									enable = false,
								},
							},
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
						},
					},
					on_attach = function(client, bufnr)
						-- Preserve your existing LSP keybindings
						local opts = { buffer = bufnr }
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

						-- Enhanced mappings using telescope for better integration
						local map = function(keys, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
						end

						map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
						map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
						map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
						map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
						map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
						map(
							"<leader>ws",
							require("telescope.builtin").lsp_dynamic_workspace_symbols,
							"[W]orkspace [S]ymbols"
						)
						map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
						map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
						map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

						-- Inlay hints toggle with end-of-line positioning
						if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
							map("<leader>th", function()
								vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
							end, "[T]oggle Inlay [H]ints")
						end

						-- Rust-specific keybindings
						map("<leader>rr", "<cmd>RustLsp runnables<cr>", "[R]ust [R]unnables")
						map("<leader>rd", "<cmd>RustLsp debuggables<cr>", "[R]ust [D]ebuggables")
						map("<leader>rt", "<cmd>RustLsp testables<cr>", "[R]ust [T]estables")
						map("<leader>re", "<cmd>RustLsp explainError<cr>", "[R]ust [E]xplain Error")
						map("<leader>rm", "<cmd>RustLsp expandMacro<cr>", "[R]ust Expand [M]acro")
						map("<leader>dt", "<cmd>RustLsp debug<cr>", "[D]ebug [T]est at cursor")

						-- LSP management keybindings
						map("<leader>rs", "<cmd>RustAnalyzer restart<cr>", "[R]ust LSP Re[s]tart")
						map("<leader>rl", "<cmd>RustLsp logFile<cr>", "[R]ust LSP [L]og File")
						map("<leader>rh", "<cmd>checkhealth rustaceanvim<cr>", "[R]ust [H]ealth Check")

						-- Open registry crate in new WezTerm tab
						map("<leader>rc", function()
							local current_file = vim.api.nvim_buf_get_name(0)
							vim.notify("Current file: " .. current_file, vim.log.levels.INFO)

							if current_file:match("%.cargo/registry/") then
								vim.notify("Found cargo registry pattern", vim.log.levels.INFO)

								-- Extract crate root directory - match the full path pattern
								local crate_root = current_file:match("(.*/%.cargo/registry/src/[^/]+/[^/]+)")
								vim.notify("Crate root: " .. (crate_root or "nil"), vim.log.levels.INFO)

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
										vim.notify("Could not extract pane ID from result", vim.log.levels.WARN)
									else
										local title_cmd = string.format(
											'wezterm cli set-tab-title --pane-id %s "%s"',
											pane_id,
											crate_name
										)
										vim.fn.system(title_cmd)
									end
								else
									vim.notify("Could not extract crate root", vim.log.levels.WARN)
								end
								vim.notify(
									string.format(
										"Opened crate %s in new WezTerm tab",
										vim.fn.shellescape(crate_root),
										vim.log.levels.INFO
									)
								)
							else
								vim.notify("Not in a Cargo registry crate", vim.log.levels.WARN)
							end
						end, "[R]egistry [C]rate in new tab")
					end,
				},
				-- DAP configuration
				dap = {
					adapter = {
						type = "server",
						port = "${port}",
						host = "127.0.0.1",
						executable = {
							command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
							args = { "--port", "${port}" },
						},
					},
				},
			}
		end,
	},
}
