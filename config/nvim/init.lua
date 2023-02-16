-- NEOVIM Formatting
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.clipboard="unnamedplus"
vim.opt.listchars= {
	tab = "→ " ,
	eol = "↲",
	nbsp = "␣",
	trail = "•",
	extends = "⟩",
	precedes = "⟨",
	space = "•"
}
vim.opt.list = true
vim.wo.number = true
vim.g.splitright = true
vim.g.splitbelow = true
vim.g.mapleader = " "
vim.g.noswapfile = true
vim.g.lazyredraw   = true
vim.g.mouse = "a"

require("packer").startup(function(use)
  -- Packer managing itself
  use { "wbthomason/packer.nvim" }

  -- Color scheme
  use { "projekt0n/github-nvim-theme" }
  use { "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } }
  use { "nvim-treesitter/nvim-treesitter" }

  -- LSP
  use {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    requires = {
      -- LSP Support
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},

      -- Autocompletion
      {"hrsh7th/nvim-cmp"},
      {"hrsh7th/cmp-buffer"},
      {"hrsh7th/cmp-path"},
      {"saadparwaiz1/cmp_luasnip"},
      {"hrsh7th/cmp-nvim-lsp"},
      {"hrsh7th/cmp-nvim-lua"},

      -- Snippets
      {"L3MON4D3/LuaSnip"},
      {"rafamadriz/friendly-snippets"},
    }
  }
  
  -- Use ripgrep
  use { "jremmen/vim-ripgrep" }

  -- Use autotags
  use { "craigemery/vim-autotag" }

  -- Use fzf
  use { "junegunn/fzf", run = ":call fzf#install()" }
  use { "simrat39/rust-tools.nvim" }

  -- Use git
  use { "tpope/vim-fugitive" }
  use { "junegunn/gv.vim" }
  use { "nvim-lua/plenary.nvim" }
  use { "sindrets/diffview.nvim" }

  -- formatter
  use { "andrejlevkovitch/vim-lua-format" }
end)

local lsp = require("lsp-zero").preset({
  name = "minimal",
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.nvim_workspace()
lsp.setup()

-- ===== LANGUAGE SERVERS ====
-- make sure this servers are installed
-- see :help lsp-zero.ensure_installed()
lsp.ensure_installed({
  "rust_analyzer",
  "gopls",
})

-- don"t initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.skip_server_setup({"rust_analyzer"})
lsp.setup({"gopls"})


-- initialize rust_analyzer with rust-tools
-- see :help lsp-zero.build_options()
local rust_lsp = lsp.build_options("rust_analyzer", {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print("hello rust-tools")
  end
})

require("rust-tools").setup({server = rust_lsp})

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end)

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
  end
})

function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- ==== Keymaps ====
map("n", "<Leader>f", ":FZF<CR>")
map("n", "<Leader>R", ":Rg<CR>")
map("n", "<Leader>s", ":Rg <C-r><C-w><CR>")

-- splits
map("n", "<Leader>v", ":vsp<CR>")
map("n", "<Leader>h", ":sp<CR>")
map("n", "<C-j>", "<C-W><C-J>")
map("n", "<C-k>", "<C-W><C-K>")
map("n", "<C-l>", "<C-W><C-L>")
map("n", "<C-h>", "<C-W><C-H>")

-- replace
map("n", "<Leader>r", ":%s/\\<<C-r><C-w>\\>/")
map("n", "<C-e>", "<C-n><C-p>")

-- copy
map("", "<C-C>", "<Esc>")
map("n", "<Leader>Y", "*y<CR>")
map("n", "<Leader>y", "+y<CR>")
map("n", "<Leader>1", ":set background=dark <bar> colorscheme github_dark <bar> e ~/.config/kitty/kitty.conf <bar> %s/_.*.conf/_Dark.conf/g <bar> w <bar> bd <CR><CR>")
map("n", "<Leader>2", ":set background=light <bar> colorscheme github_light <bar> e ~/.config/kitty/kitty.conf <bar> %s/_.*.conf/_Light.conf/g <bar> w <bar> bd <CR><CR>")

-- formatting
function format()
  if vim.bo.filetype == "go" then
     vim.cmd("!go run mvdan.cc/gofumpt -w -extra .")
  elseif vim.bo.filetype == "python" then
     vim.cmd("%!black %")
  elseif vim.bo.filetype == "rust" then
     vim.cmd("%!cargo fmt")
  elseif vim.bo.filetype == "json" then
     vim.cmd("%!jq '.'")
  elseif vim.bo.filetype == "lua" then
     vim.cmd("call LuaFormat()")
  end
end
map("", "<Leader>F", "<cmd>:lua format()<CR>")

-- ==== Colorscheme ====


require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the four listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "go", "rust", "yaml", "python", "json", "help" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

local github_theme = require"lualine.themes.github_dark"
require("lualine").setup {
 options = { theme = github_theme },
}
require("github-theme").setup()
