-- autocmd
-- function auto_create_dir.setup()
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
 	group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
 	desc = "Auto-create parent directories before writing files",
 	callback = function(event)

   	-- Skip URIs like scp://, oil://, etc.
   	if event.match:match("^%w%w+://") then
     	return
   	end

   	-- Resolve to canonical path if possible (symlinks, etc.)
   	local file = vim.loop.fs_realpath(event.match) or event.match

		-- Create dir and parents (idempotent)
   	vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
 	end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
