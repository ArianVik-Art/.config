--Welcome to my dank ass NVIM Config!

require('config.globals')
require('config.options')
require('config.autocmd')
require('config.lsp')
require('custom.cd-buffer-root')

vim.opt.clipboard:prepend { "unnamed", "unnamedplus" } -- sync yanks to system clipboard
vim.opt.virtualedit = "all"

vim.opt.winborder = "rounded"
vim.opt.hlsearch = false
vim.cmd([[set mouse=]])
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true

-- tabstops
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"

vim.opt.splitright = true
vim.opt.splitbelow = true

local map = vim.keymap.set
vim.g.mapleader = " "
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map({ 'n', 'v', 'x' }, '<leader>y', '"+y')
map({ 'n', 'v', 'x' }, '<leader>d', '"+d')
map({ 'n', 'v', 'x' }, '<leader>v', ':e $MYVIMRC<CR>')
map({ 'n', 'v', 'x' }, '<leader>s', ':e #<CR>')
map({ 'n', 'v', 'x' }, '<leader>S', ':sf #<CR>')
map({ 'n', 'v', 'x' }, 'dw', 'diw')

vim.pack.add({
 	{ src = 'https://github.com/lewis6991/gitsigns.nvim' },
 	{ src = 'https://github.com/folke/tokyonight.nvim' },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/nvim-mini/mini.sessions" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
})

require "mason".setup()

require "gitsigns".setup({
  attach_to_untracked = true,
--  debug_mode = true,  -- Enables internal debug messages; check :messages after testing
--  signcolumn = true,  -- Explicitly enable to ensure the column is available
--  on_attach = function(bufnr)
--    print("Gitsigns successfully attached to buffer " .. bufnr)
--    -- You can add custom mappings here if needed, e.g., for hunk navigation
--  end,
})
-- vim.api.nvim_create_autocmd("BufReadPost", {
--  callback = function()
--    print("bufreadpost triggered")
--    require("gitsigns").attach()
--  end,
--})

require "mini.pick".setup()
vim.ui.select = MiniPick.ui_select
vim.ui.select = function(items, opts, on_choice)
	local start_opts = { window = { config = { width = vim.o.columns } } }
	return MiniPick.ui_select(items, opts, on_choice, start_opts)
end

require "mini.sessions".setup()
require "oil".setup({ view_options = { show_hidden = true } })

map('n', '<leader>sa', function()
  vim.ui.input({prompt ="Session Name: "}, function(input)
    vim.cmd('lua MiniSessions.write("'.. input .. '")')
  end
  )
end
)

--this is a write since the last change

map('n', '<leader>sr', ':lua MiniSessions.select("read")<CR>')
map('n', '<leader>f', ":Pick files<CR>")
map('n', '<leader>h', ":Pick help<CR>")
map('n', '<leader>e', ":Oil<CR>")
map('t', '', "")
map('t', '', "")
map('n', '<leader>lf', vim.lsp.buf.format)

-- colors
require "tokyonight".setup({})
vim.cmd("colorscheme tokyonight-night") -- night moon storm day
vim.cmd(":hi statusline guibg=NONE")
