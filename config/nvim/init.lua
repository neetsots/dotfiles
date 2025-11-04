-- init.lua — Clean Backend DX (Rust/Go/Python + Bazel/Gazelle)
-- Mode: B (Full Backend DX) — lean, fast, maintainable
-- macOS example deps:
--   brew install ripgrep fzf rust-analyzer go basedpyright bazelisk buildifier lua-language-server
--   go install github.com/tilt-dev/starlark-lsp/cmd/starlark-lsp@latest

-- 0) Leader & base options ---------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.opt.number = true
vim.opt.relativenumber = false
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
vim.opt.clipboard = "unnamedplus" -- macOS clipboard

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
	-- Theme (calm & precise)
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({ compile = true, dimInactive = true, theme = "wave" })
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	-- FZF + ripgrep
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
			vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Files" })
			vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep" })
			vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fc", fzf.git_commits, { desc = "Git commits" })
			vim.keymap.set("n", "<leader>fs", fzf.git_status, { desc = "Git status" })
		end,
	},

	-- Treesitter (with Starlark)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			if not parser_config.starlark then
				parser_config.starlark = {
					install_info = {
						url = "https://github.com/tree-sitter-grammars/tree-sitter-starlark",
						files = { "src/parser.c" },
					},
					filetype = "bzl",
				}
			end
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"rust",
					"go",
					"python",
					"bash",
					"json",
					"yaml",
					"toml",
					"starlark",
				},
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
			})
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-textobjects" },

	-- Mason (manage binaries; LSP starts natively below)
	{ "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

	-- Completion (lean)
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			-- load VSCode-style snippets lazily
			require("luasnip.loaders.from_vscode").lazy_load()

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
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "path" },
					{ name = "buffer", keyword_length = 3 },
				}),
				preselect = cmp.PreselectMode.None,
				experimental = { ghost_text = true }, -- inline suggestions (optional)
			})
		end,
	},
	-- Formatting & linting
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

	-- Git
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({ current_line_blame = true })
			local gs = require("gitsigns")
			vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next hunk" })
			vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Prev hunk" })
			vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
			vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
			vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
			vim.keymap.set("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
			vim.keymap.set("n", "<leader>gb", ":G blame ", { desc = "Git blame" })
			vim.keymap.set("n", "<leader>gg", ":Git ", { desc = "Git status" })
			vim.keymap.set("n", "<leader>gl", ":G log --oneline --graph --decorate ", { desc = "Git log" })
			vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
		end,
	},

	-- Bazel & UX
	{ "bazelbuild/vim-bazel", ft = { "bzl", "bazel", "BUILD", "WORKSPACE" } },
	{ "alexander-born/bazel.nvim", dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" } },

	-- Which-key (lazy, optional)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				mode = { "n", "v" },
				{ "<leader>f", group = "+find" },
				{ "<leader>g", group = "+git" },
				{ "<leader>c", group = "+cargo" },
				{ "<leader>b", group = "+bazel" },
			})
		end,
	},
})

-- 2) Minimal statusline ------------------------------------------------------
vim.opt.showmode = false
vim.o.statusline = table.concat({ "%f", " %m%r%h%w", " %=", "L%l/%L C%c ", "[%{&filetype}]" })

-- 2.5) Native LSP bootstrap (no lspconfig) ----------------------------------
local default_caps = (function()
	local ok, caps = pcall(function()
		return require("cmp_nvim_lsp").default_capabilities()
	end)
	return ok and caps or vim.lsp.protocol.make_client_capabilities()
end)()

local function first_exe(cmds)
	for _, c in ipairs(cmds) do
		if vim.fn.executable(c) == 1 then
			return c
		end
	end
end

local function rooter(patterns)
	return function(startpath)
		return vim.fs.root(startpath, patterns) or vim.loop.cwd()
	end
end

local function start_server(opts)
	local cmd = first_exe(opts.cmd)
	if not cmd then
		return
	end
	local root = rooter(opts.root_patterns)(vim.api.nvim_buf_get_name(0))
	vim.lsp.start({
		name = opts.name,
		cmd = { cmd, unpack(opts.cmd_args or {}) },
		root_dir = root,
		capabilities = default_caps,
		settings = opts.settings,
		on_attach = function(_, bufnr)
			local function map(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
			end
			map("gd", vim.lsp.buf.definition, "Go to definition")
			map("gr", vim.lsp.buf.references, "References")
			map("gi", vim.lsp.buf.implementation, "Implementation")
			map("K", vim.lsp.buf.hover, "Hover")
			map("<leader>rn", vim.lsp.buf.rename, "Rename")
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ca",
				vim.lsp.buf.code_action,
				{ buffer = bufnr, desc = "Code action" }
			)
			map("[d", vim.diagnostic.goto_prev, "Prev diag")
			map("]d", vim.diagnostic.goto_next, "Next diag")
			if vim.lsp.inlay_hint then
				local function ih_toggle()
					local enabled = vim.lsp.inlay_hint.is_enabled(bufnr)
					vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
				end
				vim.keymap.set("n", "<leader>ih", ih_toggle, { buffer = bufnr, desc = "Toggle inlay hints" })
			end
		end,
	})
end

vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float(nil, { focus = false })
end, { silent = true })

-- Rust
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.rs", "Cargo.toml" },
	callback = function()
		start_server({
			name = "rust-analyzer",
			cmd = { "rust-analyzer" },
			root_patterns = { "Cargo.toml", ".git" },
			settings = { ["rust-analyzer"] = { cargo = { allTargets = true }, check = { command = "clippy" } } },
		})
	end,
})

-- Go
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.go", "go.mod", "go.work" },
	callback = function()
		start_server({
			name = "gopls",
			cmd = { "gopls" },
			root_patterns = { "go.work", "go.mod", ".git" },
			settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
		})
	end,
})

-- Python (prefer basedpyright)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.py", "pyproject.toml", "requirements.txt" },
	callback = function()
		local exe = first_exe({ "basedpyright-langserver", "pyright-langserver" })
		if not exe then
			return
		end
		local name = exe:find("basedpyright") and "basedpyright" or "pyright"
		start_server({
			name = name,
			cmd = { exe, "--stdio" },
			root_patterns = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
		})
	end,
})

-- Lua (edit this config)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "*.lua" },
	callback = function()
		local fname = vim.api.nvim_buf_get_name(0)
		local nvim_cfg = vim.fn.stdpath("config")
		local root
		if fname:find(nvim_cfg, 1, true) == 1 then
			root = nvim_cfg
		else
			root = (vim.fs.root(fname, { ".luarc.json", ".luarc.jsonc", ".git" }) or vim.loop.cwd())
			if root == vim.loop.os_homedir() then
				root = vim.fs.dirname(fname)
			end
		end
		vim.lsp.start({
			name = "lua-language-server",
			cmd = { "lua-language-server" },
			root_dir = root,
			capabilities = default_caps,
			settings = {
				Lua = {
					workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME, nvim_cfg } },
					diagnostics = { globals = { "vim" } },
					telemetry = { enable = false },
				},
			},
		})
	end,
})

-- Starlark (BUILD/WORKSPACE/*.bzl)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = { "BUILD", "BUILD.bazel", "WORKSPACE", "WORKSPACE.bazel", "*.bzl" },
	callback = function()
		local exe = first_exe({ "starlark-lsp", "starlark_language_server" })
		if not exe then
			return
		end
		start_server({
			name = "starlark",
			cmd = { exe, "--stdio" },
			root_patterns = { "WORKSPACE", "MODULE.bazel", ".git" },
		})
	end,
})

-- 3) Quick helpers (commands + single-line maps) ----------------------------
local function term_cmd(cmd)
	vim.cmd("botright 12split | terminal " .. cmd)
	vim.cmd("startinsert")
end

-- Commands
vim.api.nvim_create_user_command("CargoRun", function()
	term_cmd("cargo run")
end, {})
vim.api.nvim_create_user_command("CargoBuild", function()
	term_cmd("cargo build")
end, {})
vim.api.nvim_create_user_command("CargoTest", function()
	term_cmd("cargo test")
end, {})

vim.api.nvim_create_user_command("BazelBuildAll", function()
	term_cmd("bazel build //...")
end, {})
vim.api.nvim_create_user_command("BazelTestAll", function()
	term_cmd("bazel test //...")
end, {})
vim.api.nvim_create_user_command("BazelRunApp", function()
	term_cmd("bazel run //:app")
end, {})
vim.api.nvim_create_user_command("IBazelWatchTests", function()
	term_cmd("ibazel test //...")
end, {})

vim.api.nvim_create_user_command("GazelleUpdate", function()
	term_cmd(
		[[bash -lc 'if bazel query //:gazelle >/dev/null 2>&1; then bazel run //:gazelle -- update; else bazel run @bazel_gazelle//:gazelle -- update; fi']]
	)
end, {})
vim.api.nvim_create_user_command("GazelleUpdateRepos", function()
	term_cmd(
		[[bash -lc 'if [ -f go.mod ]; then if bazel query //:gazelle >/dev/null 2>&1; then bazel run //:gazelle -- update-repos -from_file=go.mod; else bazel run @bazel_gazelle//:gazelle -- update-repos -from_file=go.mod; fi; else echo "go.mod not found"; fi']]
	)
end, {})

-- Single-line keymaps
vim.keymap.set("n", "<leader>cr", "<cmd>CargoRun<CR>", { desc = "cargo run" })
vim.keymap.set("n", "<leader>cb", "<cmd>CargoBuild<CR>", { desc = "cargo build" })
vim.keymap.set("n", "<leader>ct", "<cmd>CargoTest<CR>", { desc = "cargo test" })

vim.keymap.set("n", "<leader>bb", "<cmd>BazelBuildAll<CR>", { desc = "bazel build //..." })
vim.keymap.set("n", "<leader>bt", "<cmd>BazelTestAll<CR>", { desc = "bazel test //..." })
vim.keymap.set("n", "<leader>br", "<cmd>BazelRunApp<CR>", { desc = "bazel run //:app" })
vim.keymap.set("n", "<leader>bw", "<cmd>IBazelWatchTests<CR>", { desc = "iBazel watch tests" })
vim.keymap.set("n", "<leader>bg", "<cmd>GazelleUpdate<CR>", { desc = "Gazelle update" })
vim.keymap.set("n", "<leader>bG", "<cmd>GazelleUpdateRepos<CR>", { desc = "Gazelle update-repos" })

-- 4) Diagnostics: clean look + toggles --------------------------------------
vim.diagnostic.config({ virtual_text = false, float = { border = "rounded" }, severity_sort = true })
vim.keymap.set(
	"n",
	"<leader>dv",
	"<cmd>lua local c=vim.diagnostic.config(); vim.diagnostic.config({virtual_text = not c.virtual_text})<CR>",
	{ desc = "Toggle diagnostics virtual text" }
)
vim.keymap.set(
	"n",
	"<leader>dl",
	"<cmd>lua vim.diagnostic.setloclist({open=true})<CR>",
	{ desc = "Diagnostics → loclist" }
)

-- 5) Filetype niceties -------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust", "go", "python" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- 6) Large file guard for Treesitter -----------------------------------------
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

-- 7) QoL clipboard maps ------------------------------------------------------
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank → clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete → clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("n", "<leader><leader>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })

-- UI Background Overrides
local bg = "#0f1115" -- change to match your terminal or preferred bg

vim.api.nvim_set_hl(0, "Normal", { bg = bg })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg })
vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
vim.api.nvim_set_hl(0, "LineNr", { bg = bg })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#222222" })

-- Remove end-of-buffer ~
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg })

-- Vertical split override (no weird bright column)
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#3a3a3a", bg = bg })

-- Statusline flat & clean
vim.api.nvim_set_hl(0, "StatusLine", { bg = bg, fg = "#bbbbbb" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = bg, fg = "#555555" })

-- Tabline / Bufferline base neutral
vim.api.nvim_set_hl(0, "TabLine", { bg = bg })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = bg })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#2a2a2a" })

-- Floating menu highlights (completion / code actions)
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#2a2a2a" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#404040" })

-- Diagnostic backgrounds clean (optional)
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { bg = "NONE" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { bg = "NONE" })

-- ── Split behavior (where new splits open)
vim.opt.splitright = true -- :vsplit opens to the right
vim.opt.splitbelow = true -- :split opens below

-- ── Visible split separators
local bg = "#1e1e1e" -- match your editor/terminal bg
local sep = "#3a3a3a" -- separator line color

-- Newer Neovim uses WinSeparator; keep VertSplit for compatibility
vim.api.nvim_set_hl(0, "WinSeparator", { fg = sep, bg = "NONE" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = sep, bg = "NONE" })

-- Use box-drawing chars for clean borders
vim.opt.fillchars:append({
	vert = "│",
	horiz = "─",
	horizup = "┴",
	horizdown = "┬",
	vertleft = "┤",
	vertright = "├",
	verthoriz = "┼",
	eob = " ", -- hide ~ at end of buffer
})

-- If you want transparent background instead:

-- ── Handy keymaps (optional)
-- Create splits
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
vim.keymap.set("n", "<leader>sx", "<C-w>c", { desc = "Close split" })

-- Navigate splits
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Resize splits
vim.keymap.set("n", "<M-Left>", ":vertical resize -6<CR>", { silent = true })
vim.keymap.set("n", "<M-Right>", ":vertical resize +6<CR>", { silent = true })
vim.keymap.set("n", "<M-Down>", ":resize -3<CR>", { silent = true })
vim.keymap.set("n", "<M-Up>", ":resize +3<CR>", { silent = true })

-- Show invisible characters
vim.opt.list = true
vim.opt.listchars = {
	tab = "»·",
	space = "·",
	eol = "↴",
	trail = "•",
	extends = "›",
	precedes = "‹",
}
