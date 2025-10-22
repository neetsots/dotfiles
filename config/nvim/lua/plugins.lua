-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Thème + UI premium
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "nvim-lualine/lualine.nvim" },
	{ "nvim-tree/nvim-web-devicons" },

	--- test
	{ "akinsho/bufferline.nvim" },
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },

	-- Finder & nav
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- Syntax & code actions
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "lewis6991/gitsigns.nvim" },
	{ "folke/trouble.nvim", opts = {} },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "echasnovski/mini.align", version = false, opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

	-- LSP / Completion / Tools
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "L3MON4D3/LuaSnip" },
	{ "neovim/nvim-lspconfig" }, -- fallback 0.10
	{ "williamboman/mason.nvim", config = true },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "stevearc/conform.nvim" }, -- formatters
	{ "saecki/crates.nvim", ft = { "rust", "toml" }, opts = {} },
	{ "mrcjkb/rustaceanvim", version = "^5" }, -- Rust UX moderne

	-- GIT Setup
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = function(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(gs.next_hunk)
					return "<Ignore>"
				end, { expr = true })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(gs.prev_hunk)
					return "<Ignore>"
				end, { expr = true })
				map("n", "<leader>hs", gs.stage_hunk)
				map("n", "<leader>hr", gs.reset_hunk)
				map("n", "<leader>hp", gs.preview_hunk)
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end)
			end,
		},
	},
})
