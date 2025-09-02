 -- ~/.config/nvim/lua/custom/recent_projects.lua
-- Define project root markers.
local ROOT_PATTERNS = { ".git", ".clang-format", "pyproject.toml", "setup.py" }
-- Store file path.
local recent_file = vim.fs.joinpath(vim.fn.stdpath("data"), "recent-projects.json")
-- In-memory list of projects.
local recent_projects = {}

--- Loads projects from the JSON file.
local function load_projects()
  if vim.fn.filereadable(recent_file) ~= 1 then return end
  local file_content = vim.fn.readfile(recent_file)
  if vim.tbl_isempty(file_content) then return end
  local content_str = table.concat(file_content, "\n")
  local ok, decoded = pcall(vim.json.decode, content_str)
  if ok and type(decoded) == "table" then
    recent_projects = decoded
  end
end

--- Saves the project list to disk in a readable, indented format.
local function save_projects()
  local ok, encoded = pcall(vim.json.encode, recent_projects)
  if not ok then return end
  vim.fn.mkdir(vim.fs.dirname(recent_file), "p")
  -- Parse and reformat JSON for multi-line output
  local decoded = vim.json.decode(encoded)
  local lines = { "[" }
  for i, project in ipairs(decoded) do
    local line = "  \"" .. project .. "\""
    if i < #decoded then
      line = line .. ","
    end
    table.insert(lines, line)
  end
  table.insert(lines, "]")
  vim.fn.writefile(lines, recent_file)
end

--- Finds the project root by searching upwards for any of the defined patterns.
local function get_project_root(path)
  if not path or path == "" then return nil end
  local found = vim.fs.find(ROOT_PATTERNS, { path = path, upward = true, limit = 1 })
  if not vim.tbl_isempty(found) then
    return vim.fs.dirname(found[1])
  end
  return nil
end

--- Adds a project to the top of the list, removing any previous duplicates.
local function add_project_and_save(root)
  for i, p in ipairs(recent_projects) do
    if p == root then
      table.remove(recent_projects, i)
      break
    end
  end
  table.insert(recent_projects, 1, root)
  save_projects()
end

-- Define the public API table.
local M = {}

--- Manually adds the current file's project to the recent list.
function M.add_current_project()
  local current_buf = vim.api.nvim_buf_get_name(0)
  local root = get_project_root(current_buf)
  if root then
    add_project_and_save(root)
    vim.notify("Added project: " .. vim.fn.fnamemodify(root, ":t"), vim.log.levels.INFO)
  else
    vim.notify("No project root found.", vim.log.levels.ERROR)
  end
end

--- Opens a picker to select and switch to a recent project.
function M.open_picker()
  local ok, pick = pcall(require, "mini.pick")
  if not ok then
    vim.notify("mini.pick not available", vim.log.levels.ERROR)
    return
  end
  
  if vim.tbl_isempty(recent_projects) then
    vim.notify("No recent projects found", vim.log.levels.WARN)
    return
  end
  
  local items = {}
  for _, project in ipairs(recent_projects) do
    local short_name = vim.fn.fnamemodify(project, ":t")
    table.insert(items, {
      text = string.format("%s   %s", short_name, project),
      path = project
    })
  end
  
  pick.start({
    source = {
      items = items,
      name = "Recent Projects",
      show = function(item) return item.text end,
      choose = function(item)
        vim.api.nvim_set_current_dir(item.path)
        vim.cmd("edit .")
      end,
    }
  })
end

-- Keymaps
vim.keymap.set("n", "<leader>ra", M.add_current_project, { desc = "[R]ecent [A]dd project" })
vim.keymap.set("n", "<leader>rr", M.open_picker, { desc = "[R]ecent [R]un picker" })

-- Initialize by loading projects from disk on startup.
load_projects()

return M
