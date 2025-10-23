-- init.lua — lean, fast, maintainable (Rust/Go/Python, Cargo & Bazel)
-- Requirements: ripgrep, fzf, cargo, go, python3, bazel, buildifier
-- macOS (ex): brew install ripgrep fzf lua-language-server go basedpyright rust-analyzer bazel buildifier

-- 0) Leader & basic options ---------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = false -- user preference: no relative lines
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true

-- 1) Plugin manager (lazy.nvim) ----------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
		"--branch=stable",
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Colorscheme: calm, precise, not flashy
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				compile = true,
				dimInactive = true,
				transparent = false,
				theme = "wave", -- clean; try "dragon" for higher contrast
			})
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	-- FZF: ultra‑fast file/search using ripgrep under the hood
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf = require("fzf-lua")
			fzf.setup({
				files = { cmd = "rg --files --hidden --glob !.git" },
				grep = { rg_opts = "--hidden --glob !.git -n --no-heading --color=always -S" },
				winopts = { width = 0.9, height = 0.9 },
			})
			local map = vim.keymap.set
			map("n", "<leader>ff", fzf.files, { desc = "Files (fzf)" })
			map("n", "<leader>fg", fzf.live_grep, { desc = "Grep (rg)" })
			map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
			map("n", "<leader>fh", fzf.helptags, { desc = "Help" })
			map("n", "<leader>fc", fzf.git_commits, { desc = "Git commits" })
			map("n", "<leader>fs", fzf.git_status, { desc = "Git status" })
		end,
	},

	-- Treesitter: fast syntax/AST & motions
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "vim", "vimdoc", "rust", "go", "python", "bash", "json", "yaml", "toml" },
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						node_incremental = "+",
						node_decremental = "-",
						scope_incremental = "=",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = { ["]m"] = "@function.outer" },
						goto_previous_start = { ["[m"] = "@function.outer" },
					},
				},
			})
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects", after = "nvim-treesitter" },

	-- >>> Native LSP setup (no lspconfig) <<< ---------------------------------
	-- We still use mason for managing binaries only; we start servers via vim.lsp.start
	{ "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

	-- Completion (lean): nvim-cmp + LSP + LuaSnip
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = { { name = "nvim_lsp" } },
				preselect = cmp.PreselectMode.None,
			})
		end,
	},

	-- Formatting & linting (lean)
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					rust = { "rustfmt" },
					go = { "gofumpt", "gofmt" },
					python = { "ruff_format", "black" },
					lua = { "stylua" },
					json = { "jq" },
					yaml = { "prettier" },
					bzl = { "buildifier" },
					bazel = { "buildifier" },
				},
				format_on_save = function(bufnr)
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
					if ok and stats and stats.size > 512 * 1024 then
						return nil
					end
					return { timeout_ms = 1000, lsp_fallback = true }
				end,
			})
		end,
	},

	-- Git: lightweight, powerful
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				current_line_blame = true,
			})
			local gs = require("gitsigns")
			local map = vim.keymap.set
			map("n", "]c", gs.next_hunk, { desc = "Next hunk" })
			map("n", "[c", gs.prev_hunk, { desc = "Prev hunk" })
			map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
			map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
			map("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
			map("n", "<leader>gb", ":G blame ", { desc = "Git blame" })
			map("n", "<leader>gg", ":Git ", { desc = "Git status (fugitive)" })
			map("n", "<leader>gl", ":G log --oneline --graph --decorate ", { desc = "Git log" })
			map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
		end,
	},

	-- Bazel support (syntax, :Bazel commands)
	{ "bazelbuild/vim-bazel", ft = { "bzl", "bazel", "BUILD", "WORKSPACE" } },

	-- Mini.nvim: pairs/surround/comment — tiny & fast
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.pairs").setup()
			require("mini.surround").setup()
			require("mini.comment").setup()
		end,
	},

	-- Which-key: discover keymaps (lazy)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({})
			wk.register(
				{ f = { name = "+find" }, g = { name = "+git" }, c = { name = "+cargo" }, b = { name = "+bazel" } },
				{ prefix = "<leader>" }
			)
		end,
	},
}, {
	ui = { border = "rounded" },
	change_detection = { notify = false },
})

-- 2) Minimal statusline (built‑in)
vim.opt.showmode = false
vim.o.statusline = table.concat({
	"%f",
	" %m%r%h%w",
	" %=",
	"L%l/%L C%c ",
	"[%{&filetype}]",
})

-- 2.5) Native LSP bootstrap (no lspconfig) -----------------------------------
local cmp_caps_ok, cmp_caps = pcall(function()
	return require("cmp_nvim_lsp").default_capabilities()
end)
local default_caps = cmp_caps_ok and cmp_caps or vim.lsp.protocol.make_client_capabilities()

local function first_exe(cmds)
	for _, c in ipairs(cmds) do
		if vim.fn.executable(c) == 1 then
			return c
		end
	end
end

local function make_rooter(patterns)
	return function(startpath)
		return vim.fs.root(startpath, patterns) or vim.loop.cwd()
	end
end

local function start_langserver(opts)
	local cmd = first_exe(opts.cmd)
	if not cmd then
		return
	end
	local root = make_rooter(opts.root_patterns)(vim.api.nvim_buf_get_name(0))
	vim.lsp.start({
		name = opts.name,
		cmd = { cmd, unpack(opts.cmd_args or {}) },
		root_dir = root,
		capabilities = default_caps,
		settings = opts.settings,
		on_attach = function(client, bufnr)
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end
			map("n", "gd", vim.lsp.buf.definition, "Go to definition")
			map("n", "gr", vim.lsp.buf.references, "References")
			map("n", "gi", vim.lsp.buf.implementation, "Implementation")
			map("n", "K", vim.lsp.buf.hover, "Hover")
			map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
			map("n", "[d", vim.diagnostic.goto_prev, "Prev diag")
			map("n", "]d", vim.diagnostic.goto_next, "Next diag")
			map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
			map("n", "<leader>f", function()
				require("conform").format({ async = true })
			end, "Format")
			if vim.lsp.inlay_hint then
				map("n", "<leader>ih", function()
					local enabled = vim.lsp.inlay_hint.is_enabled(bufnr)
					vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
				end, "Toggle inlay hints")
			end
		end,
	})
end

-- Rust -----------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.rs", "Cargo.toml" },
	callback = function()
		start_langserver({
			name = "rust-analyzer",
			cmd = { "rust-analyzer" },
			root_patterns = { "Cargo.toml", ".git" },
			settings = {
				["rust-analyzer"] = {
					cargo = { allTargets = true },
					check = { command = "clippy" },
				},
			},
		})
	end,
})

-- Go -------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.go", "go.mod", "go.work" },
	callback = function()
		start_langserver({
			name = "gopls",
			cmd = { "gopls" },
			root_patterns = { "go.work", "go.mod", ".git" },
			settings = {
				gopls = { analyses = { unusedparams = true }, staticcheck = true },
			},
		})
	end,
})

-- Python (basedpyright if present, fallback to pyright) ----------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.py", "pyproject.toml", "requirements.txt" },
	callback = function()
		local cmd = first_exe({ "basedpyright-langserver", "pyright-langserver" })
		if not cmd then
			return
		end
		start_langserver({
			name = (cmd:find("basedpyright") and "basedpyright" or "pyright"),
			cmd = { cmd, "--stdio" },
			root_patterns = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
			settings = cmd:find("basedpyright") and { basedpyright = { disableOrganizeImports = false } } or {},
		})
	end,
})

-- Lua (for editing this config) ----------------------------------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.lua" },
	callback = function()
		start_langserver({
			name = "lua-language-server",
			cmd = { "lua-language-server" },
			root_patterns = { ".luarc.json", ".luarc.jsonc", ".git" },
			settings = { Lua = { diagnostics = { globals = { "vim" } } } },
		})
	end,
})

-- 3) Quick helpers -----------------------------------------------------------
-- Cargo helpers (open terminal split so it doesn't block)
local function term_cmd(cmd)
	vim.cmd("botright 12split | terminal " .. cmd)
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>cr", function()
	term_cmd("cargo run")
end, { desc = "cargo run" })
vim.keymap.set("n", "<leader>cb", function()
	term_cmd("cargo build")
end, { desc = "cargo build" })
vim.keymap.set("n", "<leader>ct", function()
	term_cmd("cargo test")
end, { desc = "cargo test" })

-- Bazel examples (edit target as needed)
vim.keymap.set("n", "<leader>bb", function()
	term_cmd("bazel build //...")
end, { desc = "bazel build //..." })
vim.keymap.set("n", "<leader>bt", function()
	term_cmd("bazel test //...")
end, { desc = "bazel test //..." })

-- 4) Diagnostics: clean look + toggles
vim.diagnostic.config({ virtual_text = false, float = { border = "rounded" }, severity_sort = true })
vim.keymap.set("n", "<leader>dv", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
end, { desc = "Toggle diagnostics virtual text" })
vim.keymap.set("n", "<leader>dl", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostics → loclist" })

-- 5) Filetype niceties
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust", "go", "python" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- 6) Large file guard for Treesitter highlight
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local ok, stats = pcall(vim.uv.fs_stat, args.file)
		if ok and stats and stats.size > 1 * 1024 * 1024 then
			vim.b.ts_disabled_large = true
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		if vim.b.ts_disabled_large then
			vim.cmd("TSBufDisable highlight")
			vim.wo.foldmethod = "indent"
		end
	end,
})

-- 7) Small QoL keymaps -------------------------------------------------------
-- System clipboard (macOS) — always use + register and map common ops
vim.opt.clipboard = "unnamedplus" -- enable clipboard integration
local map = vim.keymap.set
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<leader><leader>", ":nohlsearch\n", { desc = "Clear search" })

-- Fix copy from terminal: ensure OSC52 fallback
-- Works when SSH / headless terminal: copies visually selected text via OSC52
local function copy_osc52(lines)
	local osc52 = require("vim.ui.clipboard.osc52")
	osc52.copy(lines)
end
local function paste_osc52()
	local osc52 = require("vim.ui.clipboard.osc52")
	return osc52.paste()
end

vim.g.clipboard = {
	name = "better-macos-clipboard",
	copy = {
		["+"] = copy_osc52,
		["*"] = copy_osc52,
	},
	paste = {
		["+"] = paste_osc52,
		["*"] = paste_osc52,
	},
}

--  END  ---------------------------------------------------------------------- (built‑in)
vim.opt.showmode = false
vim.o.statusline = table.concat({
	"%f", -- file path
	" %m%r%h%w", -- flags
	" %=", -- right align
	"L%l/%L C%c ", -- position
	"[%{&filetype}]", -- ft
})

-- 3) Quick helpers -----------------------------------------------------------
-- Cargo helpers (open terminal split so it doesn't block)
local function term_cmd(cmd)
	vim.cmd("botright 12split | terminal " .. cmd)
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>cr", function()
	term_cmd("cargo run")
end, { desc = "cargo run" })
vim.keymap.set("n", "<leader>cb", function()
	term_cmd("cargo build")
end, { desc = "cargo build" })
vim.keymap.set("n", "<leader>ct", function()
	term_cmd("cargo test")
end, { desc = "cargo test" })

-- Bazel examples (edit target as needed)
vim.keymap.set("n", "<leader>bb", function()
	term_cmd("bazel build //...")
end, { desc = "bazel build //..." })
vim.keymap.set("n", "<leader>bt", function()
	term_cmd("bazel test //...")
end, { desc = "bazel test //..." })

-- 4) Diagnostics: clean look + toggles
vim.diagnostic.config({
	virtual_text = false,
	float = { border = "rounded" },
	severity_sort = true,
})

-- Toggle diagnostics virtual text
vim.keymap.set("n", "<leader>dv", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
end, { desc = "Toggle diagnostics virtual text" })

-- Send diagnostics to loclist and open
vim.keymap.set("n", "<leader>dl", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostics → loclist" })

-- 5) Filetype niceties
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust", "go", "python" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- 6) Large file guard for Treesitter highlight
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local ok, stats = pcall(vim.uv.fs_stat, args.file)
		if ok and stats and stats.size > 1 * 1024 * 1024 then
			vim.b.ts_disabled_large = true
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		if vim.b.ts_disabled_large then
			vim.cmd("TSBufDisable highlight")
			vim.wo.foldmethod = "indent"
		end
	end,
})

-- 7) Small QoL keymaps -------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader><leader>", ":nohlsearch ", { desc = "Clear search" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Done. Start with :Mason to ensure tools, then <leader>ff to find files.
