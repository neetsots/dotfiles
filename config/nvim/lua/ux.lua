-- lua/ux.lua

-- ==== Thème (Catppuccin) ====
-- Assure-toi d'avoir le plugin "catppuccin/nvim"
vim.g.catppuccin_flavour = "mocha" -- latte/macchiato/mocha/frappe
vim.cmd.colorscheme("catppuccin")

-- Toggle light/dark rapide
local ui_state = { dark = true }
vim.api.nvim_create_user_command("UIToggleTheme", function()
	ui_state.dark = not ui_state.dark
	vim.g.catppuccin_flavour = ui_state.dark and "mocha" or "latte"
	vim.cmd.colorscheme("catppuccin")
	-- Recharger lualine pour le thème
	pcall(function()
		require("lualine").setup({ 
        sections = { lualine_b = {'branch', 'diff', 'diagnostics'}, },
        options = { theme = "catppuccin", globalstatus = true } 
      })
	end)
end, {})

-- ==== Lualine (statusline) ====
pcall(function()
	require("lualine").setup({
		options = {
			theme = "catppuccin",
			globalstatus = true,
			component_separators = { left = "│", right = "│" },
			section_separators = { left = " ", right = " " },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end)

-- ==== Diagnostics : icônes & affichage ====
local signs = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

-- ==== Fenêtres flottantes arrondies (LSP, help, etc.) ====
local _open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return _open_floating_preview(contents, syntax, opts, ...)
end

-- ==== Telescope (si installé) : bordures propres ====
pcall(function()
	require("telescope").setup({
		defaults = {
			layout_config = { prompt_position = "top" },
			sorting_strategy = "ascending",
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			results_title = false,
			prompt_title = false,
			preview_title = false,
		},
	})
end)

-- ==== Petits plus : options visuelles cohérentes ====
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes" -- déjà présent, on confirme
vim.opt.cursorline = true
