-- lua/lsp.lua
-- Capabilities pour nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Root helper
local function root(markers)
	return function(buf)
		return vim.fs.root(buf, markers) or vim.loop.cwd()
	end
end

-- Keymaps automatiques à l'attache du client
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
	end,
})

-- Conform (formatter)
require("conform").setup({
	formatters_by_ft = {
		rust = { "rustfmt" },
		go = { "gofumpt", "goimports" },
		lua = { "stylua" },
		python = { "ruff_format" },
	},
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		require("conform").format({ bufnr = args.buf, lsp_fallback = true })
	end,
})

-- RUST via rustaceanvim (DAP, actions, etc.) + API core
vim.g.rustaceanvim = {
	server = {
		cmd = { "rust-analyzer" },
		default_settings = {
			["rust-analyzer"] = { cargo = { allFeatures = true }, check = { command = "clippy" } },
		},
		on_attach = function(client, bufnr)
			vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", { buffer = bufnr })
			vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<cr>", { buffer = bufnr })
		end,
		capabilities = capabilities,
	},
	tools = { hover_actions = { replace_builtin_hover = true } },
}

-- GO
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(a)
		vim.lsp.start(vim.lsp.config({
			name = "gopls",
			cmd = { "gopls" },
			root_dir = root({ "go.work", "go.mod", ".git" })(a.buf),
			capabilities = capabilities,
			settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
		}))
	end,
})

-- PYTHON
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(a)
		vim.lsp.start(vim.lsp.config({
			name = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
			root_dir = root({ "pyproject.toml", "setup.py", "requirements.txt", ".git" })(a.buf),
			capabilities = capabilities,
		}))
	end,
})

-- Completion
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "buffer" },
		{ name = "codeium" },
	}),
})
