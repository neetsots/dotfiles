-- NEOVIM Formatting
vim.opt.tabstop     = 2
vim.opt.shiftwidth  = 2
vim.opt.softtabstop = 2
vim.opt.expandtab   = true
vim.opt.clipboard   = "unnamedplus"
vim.opt.listchars   = {
  tab = "→ ",
  eol = "↲",
  nbsp = "␣",
  trail = "•",
  extends = "⟩",
  precedes = "⟨",
  space = "•"
}
vim.opt.list        = true
vim.wo.number       = true
vim.g.splitright    = true
vim.g.splitbelow    = true
vim.g.mapleader     = " "
vim.g.lazyredraw    = true
vim.g.mouse         = "a"
vim.g.shell         = "/usr/bin/zsh"
vim.opt.swapfile    = false

require("packer").startup(function(use)
  -- Packer managing itself
  use { "wbthomason/packer.nvim" }
  use { "neovim/nvim-lspconfig" }

  -- Color scheme
  use { "projekt0n/github-nvim-theme" }
  use { "neetsots/rosh" }
  use { "catppuccin/nvim", as = "catppuccin" }
  use { "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons", opt = true } }
  use { "nvim-treesitter/nvim-treesitter" }

  -- Tags
  -- use { "craigemery/vim-autotag" }
  use { "liuchengxu/vista.vim" }
  --
  -- LSP
  use {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    }
  }
  use { "ray-x/go.nvim" }
  use({
    "ray-x/navigator.lua",
    requires = {
      { "ray-x/guihua.lua",     run = "cd lua/fzy && make" },
      { "neovim/nvim-lspconfig" },
    },
  })

  -- Use ripgrep
  use { "jremmen/vim-ripgrep" }

  -- Use fzf
  use { "junegunn/fzf" }
  use { "simrat39/rust-tools.nvim" }

  -- Use git
  use { "tpope/vim-fugitive" }
  use { "junegunn/gv.vim" }
  use { "nvim-lua/plenary.nvim" }
  use { "sindrets/diffview.nvim" }
  use({
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    requires = {
      "nvim-lua/plenary.nvim",
    },
  })

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

vim.diagnostic.config({
  virtual_text = true,
  sign = true,
  update_in_insert = true,
  underline = true,
  severity_sort = false,
  float = true,
})

-- formatting
function format()
  if vim.bo.filetype == "go" then
    vim.cmd("!gofumpt -w -extra .")
  elseif vim.bo.filetype == "python" then
    vim.cmd("silent !black --line-length 80 .")
  elseif vim.bo.filetype == "rust" then
    vim.cmd("%!cargo fmt")
  elseif vim.bo.filetype == "json" then
    vim.cmd("%!jq '.'")
  elseif vim.bo.filetype == "lua" then
    vim.cmd("lua vim.lsp.buf.format()")
  end
end

-- ===== LANGUAGE SERVERS ====
-- make sure this servers are installed
-- see :help lsp-zero.ensure_installed()
lsp.ensure_installed({
  "rust_analyzer",
  "gopls",
})

-- don"t initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.setup({ "rust_analyzer" })
lsp.setup({ "gopls" })


-- initialize rust_analyzer with rust-tools
-- see :help lsp-zero.build_options()
-- local rust_lsp = lsp.build_options("rust_analyzer", {
--   single_file_support = false,
--   on_attach = function(_, _)
--     print("hello rust-tools")
--   end
-- })
-- 
-- require("rust-tools").setup({ server = rust_lsp })
require("navigator").setup({
  mason = true,
})
-- on_attach = function(_)
--   vim.cmd([[nunmap <silent><buffer> <Space>ff]])
-- end,

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end)

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
  end
})

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- ==== Keymaps ====
map("n", "<Leader>f", ":FZF<CR>")
map("n", "<Leader>g", ":LazyGit<CR>")
map("n", "<Leader>F", ":lua format()<CR>")
map("n", "<Leader>R", ":Rg<CR>")
map("n", "<Leader>s", ":Rg <C-r><C-w><CR>")
map("n", "<Leader>t", ":Vista!!<CR>")

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

function set_theme()
  if string.match(vim.g.colors_name or "", "_light") then
    vim.cmd(":lua vim.cmd.colorscheme \"rosh\"")
    vim.cmd(":e ~/.config/kitty/kitty.conf")
    vim.cmd(":%s/_.*.conf/_Dark.conf/g")
  else
    vim.cmd(":lua vim.cmd.colorscheme \"github_light\"")
    vim.cmd(":e ~/.config/kitty/kitty.conf")
    vim.cmd(":%s/_.*.conf/_Light.conf/g")
  end
  vim.cmd(":w")
  vim.cmd(":bd")
  vim.cmd(":silent !kill -SIGUSR1 $(pgrep kitty)")
  vim.cmd(":lua require('lualine').setup { options = { theme = vim.g.colors_name },}")
end

-- copy
map("n", "<C-c>", "<Esc>")
map("n", "<Leader>Y", "*y<CR>")
map("n", "<Leader>y", "+y<CR>")
map("n", "<Leader>1", ":lua set_theme()<CR><CR>")
-- ==== Colorscheme ====


require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the four listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "go", "rust", "yaml", "python", "json" },

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
    disable = function(_, buf)
      local max_filesize = 500 * 1024 -- 100 KB
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

-- vim.cmd.colorscheme "catppuccin-macchiato"
vim.cmd('colorscheme rosh')

-- local github_theme = require "lualine.themes.github_light"
require("lualine").setup()
