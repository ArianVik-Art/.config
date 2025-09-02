-- ~/.config/nvim/lua/recent-projects.lua
local recent_file = vim.fn.stdpath("data") .. "/recent-projects.json"
local recent_projects = {}
local M = {}

local function load_projects()
  if vim.fn.filereadable(recent_file) == 1 then
    local lines = vim.fn.readfile(recent_file)
    if not vim.tbl_isempty(lines) then
      local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
      if ok and type(decoded) == "table" then recent_projects = decoded end
    end
  end
end

local function save_projects()
  local ok, encoded = pcall(vim.json.encode, recent_projects)
  if ok then vim.fn.writefile({ encoded }, recent_file) end
end


local function get_git_root()
  -- Get absolute path of the buffer's directory
  local buf_dir = vim.fn.expand('%:p:h')

  -- Find .git directory upwards from buf_dir
  local git_dir = vim.fn.finddir('.git', vim.fn.escape(buf_dir, ' ') .. ';')

  if git_dir == '' then
    vim.notify("No .git directory found", vim.log.levels.WARN)
    return
  end

  -- Get the parent directory (the repo root)
  return vim.fn.fnamemodify(git_dir, ':h')

---- Change cwd safely
--  vim.cmd.cd(vim.fn.fnameescape(git_root))
--  vim.notify("Changed directory to " .. git_root)
end

local function add_project(root)
  for i, p in ipairs(recent_projects) do
    if p == root then table.remove(recent_projects, i); break end
  end
  table.insert(recent_projects, 1, root)
  save_projects()
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local buf = vim.api.nvim_buf_get_name(0)
    if buf == "" then return end
    local root = get_git_root(buf)
    if root then add_project(root) end
  end,
})

function M.open_picker()
  local ok, pick = pcall(require, "mini.pick")
  if not ok then vim.notify("mini.pick not installed", vim.log.levels.WARN); return end
  pick.start({
    source = { items = recent_projects },
    actions = { default = function(item)
      if not item then return end
      if vim.fn.isdirectory(item) == 0 then vim.notify("Missing: "..item, vim.log.levels.WARN); return end
      vim.api.nvim_set_current_dir(item); vim.cmd("edit .")
    end }
  })
end

-- small helper for testing
function M.get_recent_projects() return vim.deepcopy(recent_projects) end

-- optional mapping
vim.keymap.set("n", "<leader>r", function() M.open_picker() end, { desc = "Pick recent project" })

load_projects()
return M
