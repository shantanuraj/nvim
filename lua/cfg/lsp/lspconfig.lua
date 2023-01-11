-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
	return
end

local wk = require("which-key")

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- set keybinds
	wk.register({
		["g"] = {
			name = "+Go to",
			f = { "<cmd>Lspsaga lsp_finder<CR>", "LSP Finder" },
			D = { "<Cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
			d = { "<cmd>Lspsaga peek_definition<CR>", "Peek Definition" },
			i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
		},
		["<leader>"] = {
			["d"] = { "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Show Diagnostics" },
			["D"] = { "<cmd>Lspsaga show_line_diagnostics<CR>", "Show Line Diagnostics" },
			["o"] = { "<cmd>Lspsaga outline<CR>", "Outline" },
			["r"] = {
				name = "+Refactor",
				["r"] = { "<cmd>Lspsaga rename<CR>", "Rename" },
				["a"] = { "<cmd>Lspsaga code_action<CR>", "Code Action" },
			},
		},
		["[d"] = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Jump to Previous Diagnostic" },
		["]d"] = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "Jump to Next Diagnostic" },
		["K"] = { "<cmd>Lspsaga hover_doc<CR>", "Hover Doc" },
	}, { buffer = bufnr })

	-- typescript specific keymaps (e.g. rename file and update imports)
	if client.name == "tsserver" then
		wk.register({
			["r"] = {
				["f"] = { ":TypescriptRenameFile<CR>", "Rename File" },
				["i"] = { ":TypescriptOrganizeImports<CR>", "Organize Imports" },
				["u"] = { ":TypescriptRemoveUnused<CR>", "Remove Unused" },
			},
		}, { buffer = bufnr, prefix = "<leader>" })
	end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure css server
lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure deno server
-- lspconfig["denols"].setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })

-- configure emmet language server
lspconfig["emmet_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = {
		"astro",
		"html",
		"typescriptreact",
		"javascriptreact",
		"css",
		"sass",
		"scss",
		"less",
		"svelte",
	},
})

-- configure gopls server
lspconfig["gopls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure markdown server
lspconfig["marksman"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure rust server
lspconfig["rust_analyzer"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure svelte server
lspconfig["svelte"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure lua server (with special settings)
lspconfig["sumneko_lua"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure typescript server with plugin
typescript.setup({
	server = {
		capabilities = capabilities,
		on_attach = on_attach,
	},
})