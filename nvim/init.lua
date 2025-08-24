--Welcome to my dank ass NVIM Config!
require('config.autocmd')
require('config.lsp')

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
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = 'https://github.com/NvChad/showkeys',                 opt = true },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/folke/which-key.nvim"},
	{ src = "https://github.com/kdheepak/lazygit.nvim"},
})

require "mason".setup()
require "showkeys".setup({ position = "top-right" })
require "mini.pick".setup()
require "oil".setup()

map('n', '<leader>f', ":Pick files<CR>")
map('n', '<leader>h', ":Pick help<CR>")
map('n', '<leader>e', ":Oil<CR>")
map('t', '', "")
map('t', '', "")
map('n', '<leader>lf', vim.lsp.buf.format)

-- colors
require "vague".setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

-- snippets
local ls = require("luasnip")
map({ "i" }, "<C-e>", function() ls.expand() end, { silent = true })
map({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-K>", function() ls.jump(-1) end, { silent = true })
