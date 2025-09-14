--Welcome to my dank a$$ NVIM Config!
require('config.globals')
require('config.options')
require('config.autocmd')
require('config.lsp')

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

require "gitsigns".setup({ attach_to_untracked = true, })

require "mini.pick".setup()
vim.ui.select = MiniPick.ui_select
vim.ui.select = function(items, opts, on_choice)
	local start_opts = { window = { config = { width = vim.o.columns } } }
	return MiniPick.ui_select(items, opts, on_choice, start_opts)
end
map('n', '<leader>f', ":Pick files<CR>")
map('n', '<leader>h', ":Pick help<CR>")

require "mini.sessions".setup()
map('n', '<leader>sa', function()
  vim.ui.input({prompt ="Session Name: "}, function(input)
    vim.cmd('lua MiniSessions.write("'.. input .. '")')
  end
  )
end
)
map('n', '<leader>r', ':lua MiniSessions.select("read")<CR>')

require "oil".setup({ view_options = { show_hidden = true } })
map('n', '<leader>e', ":Oil<CR>")

map('t', '', "")
map('t', '', "")
map('n', '<leader>lf', vim.lsp.buf.format)

-- colors
require "tokyonight".setup({})
vim.cmd("colorscheme tokyonight-night")
vim.cmd(":hi statusline guibg=NONE")
