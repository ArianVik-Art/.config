 -- A cleaner, more robust recent projects picker

-- Use vim.fs.joinpath for cross-platform compatibility
local recent_file = vim.fs.joinpath(vim.fn.stdpath("data"), "recent-projects.json")
local recent_projects = {}

-- Define the module table to avoid global pollution
local M = {}

-- 1. Use Neovim's file I/O API and add error notifications
local function load_projects()
  -- Use `vim.fn.filereadable` to check if file exists
  if vim.fn.filereadable(recent_file) == 0 then return end

  local content_lines = vim.fn.readfile(recent_file)
  -- readfile returns an empty list on read error
  if vim.tbl_isempty(content_lines) then return end

  local content = table.concat(content_lines)
  local ok, decoded = pcall(vim.json.decode, content)
  if ok and decoded then
    recent_projects = decoded
  else
    vim.notify("Could not decode recent-projects.json", vim.log.levels.WARN)
  end
end

local function save_projects()
  -- Using a pcall here is safer in case the table contains non-serializable data
  local ok, encoded = pcall(vim.json.encode, recent_projects)
  if not ok then
    vim.notify("Could not encode recent projects list", vim.log.levels.ERROR)
    return
  end
  vim.fn.writefile({ encoded }, recent_file)
end


local function get_git_root(path)
  if not path or path == "" then return nil end

  local dir = vim.fs.dirname(path)
  local results = vim.fs.find(".git", { path = dir, upward = true, type = "directory" })

  if #results > 0 then
    return vim.fs.dirname(results[1]) -- parent of `.git`
  end

  return nil
end

-- 2. Improved tracking: Move existing projects to the top
local function add_or_update_project(root)
  local index = vim.tbl_item_idx(recent_projects, root)
  -- If project already exists, remove it first
  if index then
    table.remove(recent_projects, index)
  end
  -- Insert at the top of the list to mark as most recent
  table.insert(recent_projects, 1, root)
  save_projects()
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("RecentProjectsTracker", { clear = true }),
  pattern = "*",
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    -- Guard against non-file buffers
    if buf_name == "" or vim.fn.filereadable(buf_name) == 0 then return end

    local root = get_git_root(buf_name)
    if root and (vim.tbl_isempty(recent_projects) or recent_projects[1] ~= root) then
      add_or_update_project(root)
    end
  end,
})

-- 3. Use `mini.pick` actions for more flexibility
function M.open_picker()
  local pick = require("mini.pick")
  pick.start({
    prompt = "Recent Projects ",
    source = {
      name = "Recent Git Projects",
      items = recent_projects,
    },
    actions = {
      -- Default action on <CR>
      ["default"] = function(item)
        vim.api.nvim_set_current_dir(item)
        vim.notify("Changed directory to " .. item, vim.log.levels.INFO)
        -- Open your preferred file explorer here, e.g., Neo-tree, Telescope, etc.
        -- vim.cmd("Telescope find_files")
        vim.cmd("edit .")
      end,

      -- Action on <C-d> to just change directory without opening explorer
      ["just-cd"] = function(item)
        vim.api.nvim_set_current_dir(item)
        vim.notify("Changed directory to " .. item, vim.log.levels.INFO)
      end,
    },
    mappings = {
      -- Map <C-d> to the `just-cd` action
      ["<C-d>"] = "just-cd",
    },
  })
end

-- 4. Map the namespaced function
vim.keymap.set("n", "<leader>r", M.open_picker, { desc = "Pick [R]ecent Projects" })

-- Initial load
load_projects()

-- Return the module table (good practice)
return M
