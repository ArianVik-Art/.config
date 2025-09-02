local recent_file = vim.fn.stdpath("data") .. "/recent-projects.json"
local recent_projects = {}

-- Load/save using vim.json
local function load_projects()
  if vim.fn.filereadable(recent_file) == 1 then
    local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(recent_file)))
    if ok and type(decoded) == "table" then
      recent_projects = decoded
    end
  end
end

local function save_projects()
  local ok, encoded = pcall(vim.json.encode, recent_projects)
  if ok then
    vim.fn.writefile({ encoded }, recent_file)
  end
end

local function get_git_root(path)
  if not path or path == "" then return nil end

  local dir = (vim.fs and vim.fs.dirname) and vim.fs.dirname(path) or vim.fn.fnamemodify(path, ":p:h")

  if vim.fs and vim.fs.find then
    -- catches both .git directories and .git files (worktrees)
    local results = vim.fs.find(".git", { path = dir, upward = true })
    if #results > 0 then
      return vim.fs.dirname(results[1])
    end
    return nil
  else
    -- fallback for older Neovim: normalize possible table result
    local gitdir = vim.fn.finddir(".git", dir .. ";")
    if type(gitdir) == "table" then gitdir = gitdir[1] end
    if gitdir ~= "" then
      return vim.fn.fnamemodify(gitdir, ":h")
    end
    return nil
  end
end

-- Insert project at top
local function add_project(root)
  for i, p in ipairs(recent_projects) do
    if p == root then table.remove(recent_projects, i) break end
  end
  table.insert(recent_projects, 1, root)
  save_projects()
end

-- Track on buffer enter
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local buf = vim.api.nvim_buf_get_name(0)
    if buf == "" then return end
    local root = get_git_root(buf)
    if root then add_project(root) end
  end,
})

-- Picker
local M = {}
function M.open_picker()
  local pick = require("mini.pick")
  pick.start({
    source = { items = recent_projects },
    actions = {
      default = function(item)
        vim.api.nvim_set_current_dir(item)
        vim.cmd("edit .")
      end,
    },
  })
end

vim.keymap.set("n", "<leader>r", M.open_picker, { desc = "Pick recent project" })

load_projects()
return M

