local wezterm    = require('wezterm')
local os         = require('os')
local config     = wezterm.config_builder()

local projects   = require('projects')

-- ================================================================
-- Set this to 'wsl', 'linux', or 'windows'
local TARGET_ENV = 'linux'
-- ================================================================

local is_windows = TARGET_ENV == 'windows'
local is_linux   = TARGET_ENV == 'linux'
local is_wsl     = TARGET_ENV == 'wsl'

-- Resolve home directory for new panes/tabs
local home_dir
if is_wsl then
  -- Derive WSL home from Windows username (assumes WSL username matches)
  local username = wezterm.home_dir:match('[^\\]+$')
  home_dir = '\\\\wsl.localhost\\Ubuntu\\home\\' .. username
elseif is_linux then
  home_dir = os.getenv('HOME')
else
  home_dir = wezterm.home_dir
end

-- Domain / default shell
if is_wsl then
  config.default_domain = 'WSL:Ubuntu'
elseif is_windows then
  config.default_prog = { 'powershell.exe', '-NoLogo' }
end

-- Configuration
config.automatically_reload_config = true
config.font_size = 14
config.color_scheme = 'nord'
config.line_height = 1.0
config.font = wezterm.font 'FiraCode Nerd Font'
config.window_background_opacity = 0.97

config.hide_tab_bar_if_only_one_tab = true

config.mouse_bindings = {
  -- Open URLs with Ctrl+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  }
}

config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000
config.use_dead_keys = false
config.warn_about_missing_glyphs = false
config.window_decorations = 'TITLE | RESIZE'
config.window_padding = {
  left = 9,
  right = 9,
  top = 0,
  bottom = 0,
}

-- Tab bar
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.colors = {
  tab_bar = {
    active_tab = {
      fg_color = '#073642',
      bg_color = '#2aa198',
    }
  }
}

-- Wezterm <-> nvim pane navigation
-- Linux: integrates with https://github.com/aca/wezterm.nvim (requires NVIM_LISTEN_ADDRESS)
-- Windows/WSL: directly activates pane direction (nvim socket runs on host, not in WSL)
local move_around = function(window, pane, direction_wez, direction_nvim)
  if is_linux then
    local result = os.execute("env NVIM_LISTEN_ADDRESS=/tmp/nvim" ..
      pane:pane_id() .. " wezterm.nvim.navigator " .. direction_nvim)
    if result then
      window:perform_action(wezterm.action({ SendString = "\x17" .. direction_nvim }), pane)
    else
      window:perform_action(wezterm.action({ ActivatePaneDirection = direction_wez }), pane)
    end
  else
    window:perform_action(wezterm.action.ActivatePaneDirection(direction_wez), pane)
  end
end

wezterm.on("move-left", function(w, p) move_around(w, p, "Left", "h") end)
wezterm.on("move-right", function(w, p) move_around(w, p, "Right", "l") end)
wezterm.on("move-up", function(w, p) move_around(w, p, "Up", "k") end)
wezterm.on("move-down", function(w, p) move_around(w, p, "Down", "j") end)

wezterm.on("resize-left", function(w, p) w:perform_action(wezterm.action.AdjustPaneSize({ 'Left', 5 }), p) end)
wezterm.on("resize-right", function(w, p) w:perform_action(wezterm.action.AdjustPaneSize({ 'Right', 5 }), p) end)
wezterm.on("resize-up", function(w, p) w:perform_action(wezterm.action.AdjustPaneSize({ 'Up', 5 }), p) end)
wezterm.on("resize-down", function(w, p) w:perform_action(wezterm.action.AdjustPaneSize({ 'Down', 5 }), p) end)

-- Unix domain muxing (Linux and WSL only)
if is_linux or is_wsl then
  config.unix_domains = { { name = 'unix' } }
end

config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 2000 }

config.keys = {
  -- Copy mode
  {
    key = '[',
    mods = 'LEADER',
    action = wezterm.action.ActivateCopyMode,
  },

  -- ----------------------------------------------------------------
  -- TABS
  -- ----------------------------------------------------------------

  { key = 'w', mods = 'LEADER',       action = wezterm.action.ShowTabNavigator },
  {
    key = 'c',
    mods = 'LEADER',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = home_dir,
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = ',',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then window:active_tab():set_title(line) end
      end),
    },
  },
  -- { key = 'n', mods = 'LEADER',       action = wezterm.action.ActivateTabRelative(1) },
  -- { key = 'p', mods = 'LEADER',       action = wezterm.action.ActivateTabRelative(-1) },
  { key = '&', mods = 'LEADER|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },

  -- ----------------------------------------------------------------
  -- PANES
  -- ----------------------------------------------------------------

  -- Vertical split
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
      command = { cwd = home_dir },
    },
  },
  -- Horizontal split
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
      command = { cwd = home_dir },
    },
  },

  -- CTRL + (h,j,k,l) to move between panes
  { key = 'h', mods = 'CTRL',         action = wezterm.action({ EmitEvent = "move-left" }) },
  { key = 'j', mods = 'CTRL',         action = wezterm.action({ EmitEvent = "move-down" }) },
  { key = 'k', mods = 'CTRL',         action = wezterm.action({ EmitEvent = "move-up" }) },
  { key = 'l', mods = 'CTRL',         action = wezterm.action({ EmitEvent = "move-right" }) },

  -- ALT + (h,j,k,l) to resize panes
  { key = 'h', mods = 'ALT',          action = wezterm.action({ EmitEvent = "resize-left" }) },
  { key = 'j', mods = 'ALT',          action = wezterm.action({ EmitEvent = "resize-down" }) },
  { key = 'k', mods = 'ALT',          action = wezterm.action({ EmitEvent = "resize-up" }) },
  { key = 'l', mods = 'ALT',          action = wezterm.action({ EmitEvent = "resize-right" }) },

  { key = 'x', mods = 'LEADER',       action = wezterm.action.CloseCurrentPane { confirm = true } },
  { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus" } },
  { key = 'm', mods = 'LEADER',       action = wezterm.action.TogglePaneZoomState },
  { key = ';', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection('Prev') },
  { key = 'o', mods = 'LEADER',       action = wezterm.action.ActivatePaneDirection('Next') },

  -- ----------------------------------------------------------------
  -- Workspaces
  -- ----------------------------------------------------------------

  { key = 's', mods = 'LEADER',       action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = '$',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for session',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
        end
      end),
    },
  },
  { key = 'N', mods = 'LEADER|SHIFT', action = wezterm.action.SwitchWorkspaceRelative(1) },
  { key = 'P', mods = 'LEADER|SHIFT', action = wezterm.action.SwitchWorkspaceRelative(-1) },
  {
    key = 'p',
    mods = 'LEADER',
    -- Present in to our project picker
    action = projects.choose_project(),
  },
}

-- Attach/Detach muxer keys (Linux and WSL only)
if is_linux or is_wsl then
  table.insert(config.keys, {
    key = 'a',
    mods = 'LEADER',
    action = wezterm.action.AttachDomain 'unix',
  })
  table.insert(config.keys, {
    key = 'd',
    mods = 'LEADER',
    action = wezterm.action.DetachDomain { DomainName = 'unix' },
  })
end

-- Quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i - 1)
  })
end

-- Status bar
-- Display Workspace name on the left and date/time on the right
wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace()
  local date = wezterm.strftime('%Y/%m/%d %H:%M:%S')
  window:set_left_status(' ' .. workspace .. ' ')
  window:set_right_status(' ' .. date .. ' ')
end)

return config
