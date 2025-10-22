-- lua/plugins/ai.lua
return {
	-- === Inline autocomplete (Windsurf vibe) ===
	{
		"Exafunction/codeium.nvim",
		event = "InsertEnter",
		opts = {
			enable_chat = false, -- we use ChatGPT.nvim for chat
			virtual_text = {
				enabled = true,
				-- leave default highlights so it matches your colorscheme
			},
		},
		config = function(_, opts)
			require("codeium").setup(opts)
			-- Keymaps similar to Windsurf:
			vim.keymap.set("i", "<C-;>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, desc = "Codeium Accept" })
			vim.keymap.set("i", "<C-,>", function()
				return vim.fn
			end, { expr = true, desc = "Codeium Next" })
			vim.keymap.set("i", "<C-.>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, desc = "Codeium Prev" })
			vim.keymap.set("i", "<C-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, desc = "Codeium Clear" })
		end,
	},

	-- === Edit with instructions / apply diff ===
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		build = function()
			-- Optional: ensure parsers exist for better diff blocks
			pcall(vim.cmd.TSUpdate)
		end,
		opts = {
			provider = "openai", -- or "anthropic", "ollama", etc.
			openai = {
				endpoint = "https://api.openai.com/v1",
				model = "gpt-4o-mini", -- pick your model
				timeout = 30000,
				temperature = 0.2,
				max_tokens = 1200,
				-- Reads from env: OPENAI_API_KEY
			},
			behaviour = {
				auto_suggestions = false, -- we rely on Codeium for inline ghost text
				system_prompt = "You are a precise coding assistant. Keep changes minimal and explain diffs briefly.",
			},
			windows = {
				width = 0.45, -- side panel width
			},
		},
		keys = {
			-- Select a range in visual mode and:
			{
				"<leader>ae",
				mode = { "n", "x" },
				function()
					require("avante.api").edit_with_instructions()
				end,
				desc = "Avante: Edit with instructions",
			},
			-- Chat about current buffer/selection:
			{
				"<leader>ac",
				mode = { "n", "x" },
				function()
					require("avante.api").ask()
				end,
				desc = "Avante: Ask about code",
			},
			-- Apply/reject chunks:
			{ "<leader>aa", "<cmd>AvanteApply<cr>", desc = "Avante: Apply changes" },
			{ "<leader>ar", "<cmd>AvanteReset<cr>", desc = "Avante: Reset suggestion" },
		},
	},

	-- === Chat side panel / prompts ===
	{
		"jackMort/ChatGPT.nvim",
		cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTRun" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			api_key_cmd = "echo $OPENAI_API_KEY",
			openai_params = { model = "gpt-4o-mini", temperature = 0.2 },
			popup_input = { submit = "<C-Enter>" },
			chat = { keymaps = { close = { "<Esc>" } } },
			actions_paths = {}, -- you can add custom prompt files later
		},
		keys = {
			{ "<leader>gk", "<cmd>ChatGPT<cr>", desc = "ChatGPT: open chat" },
			{
				"<leader>ge",
				"<cmd>ChatGPTRun edit_with_instructions<cr>",
				mode = { "n", "x" },
				desc = "ChatGPT: edit with instructions",
			},
			{ "<leader>gd", "<cmd>ChatGPTRun docstring<cr>", mode = { "n", "x" }, desc = "ChatGPT: docstring" },
			{ "<leader>gt", "<cmd>ChatGPTRun tests<cr>", mode = { "n", "x" }, desc = "ChatGPT: gen tests" },
			{ "<leader>gr", "<cmd>ChatGPTRun fix_bugs<cr>", mode = { "n", "x" }, desc = "ChatGPT: fix bugs" },
			{ "<leader>go", "<cmd>ChatGPTRun optimize_code<cr>", mode = { "n", "x" }, desc = "ChatGPT: optimize" },
			{ "<leader>gg", "<cmd>ChatGPTRun explain_code<cr>", mode = { "n", "x" }, desc = "ChatGPT: explain" },
		},
	},
}
