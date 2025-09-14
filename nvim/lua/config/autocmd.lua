-- Create dir on write if it doesn't exist.
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
    vim.hl.on_yank()
  end,
})

-- cd to project root
local ROOT_PATTERNS = { ".git", ".clang-format", "pyproject.toml", "setup.py" }
local function get_project_root(path)

    if vim.startswith(path, "oil://") then
        path = path:sub(7) -- strip off "oil://"
    end

    local root = vim.fs.find(ROOT_PATTERNS, { path = path or vim.fn.expand("%:p"), upward = true })[1]
    return root and vim.fs.dirname(root) or nil
end

vim.api.nvim_create_user_command("CdBufferRoot", function()
    local root = get_project_root()
    if root then
        vim.api.nvim_set_current_dir(root)
        print("Changed directory to " .. root)
    else
        print("No project root found")
    end
end, {})

-- leader-` calls command
vim.keymap.set("n", "<leader>`", function()
    vim.cmd.CdBufferRoot()
end, { desc = "cd to project root" })

-- build project
local runners = {
  lua = { run = "lua %" }
}
