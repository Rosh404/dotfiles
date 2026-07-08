local wezterm = require 'wezterm'
local module = {}

-- local project_dir = wezterm.home_dir .. "/projects/go"

local project_dirs = {
  wezterm.home_dir .. "/projects/go",
  wezterm.home_dir .. "/projects/java"
}

local function get_all_projects()
  -- Start with your home directory as a project, 'cause you might want
  -- to jump straight to it sometimes.
  local projects = { wezterm.home_dir }
  -- Iterate through each base directory in your list
  for _, base_path in ipairs(project_dirs) do
    -- WezTerm comes with a glob function! Let's use it to get a lua table
    -- containing all subdirectories of your project folder.
    for _, dir in ipairs(wezterm.glob(base_path .. '/*')) do
      -- ... and add them to the projects table.
      table.insert(projects, dir)
    end
  end

  return projects
end

function module.choose_project()
  local choices = {}

  for _, value in ipairs(get_all_projects()) do
    table.insert(choices, { label = value })
  end

  return wezterm.action.InputSelector {
    title = "Projects",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(child_window, child_pane, id, label)
      -- "label" may be empty if nothing was selected. Don't bother doing anything
      -- when that happens.
      if not label then return end

      -- The SwitchToWorkspace action will switch us to a workspace if it already exists,
      -- otherwise it will create it for us.
      child_window:perform_action(wezterm.action.SwitchToWorkspace {
        -- We'll give our new workspace a nice name, like the last path segment
        -- of the directory we're opening up.
        name = label:match("([^/]+)$"),
        -- Here's the meat. We'll spawn a new terminal with the current working
        -- directory set to the directory that was picked.
        spawn = { cwd = label },
      }, child_pane)
    end),
  }
end

return module
