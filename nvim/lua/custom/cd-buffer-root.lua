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

-- leader-r calls the same command
vim.keymap.set("n", "<leader>`", function()
    vim.cmd.CdBufferRoot()
end, { desc = "cd to project root" })
