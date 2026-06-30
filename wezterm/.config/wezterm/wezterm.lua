local wezterm = require('wezterm')
local os = require("os")
local config = wezterm.config_builder()

-- Configuration
config.automatically_reload_config = true
config.font_size = 14
config.color_scheme = 'nord'
config.line_height = 1.0
config.font = wezterm.font 'FiraCode Nerd Font'
config.window_background_opacity = 0.97

config.hide_tab_bar_if_only_one_tab = true

-- The leader is similar to how tmux defines a set of keys to hit in order to
-- invoke tmux bindings. Binding to ctrl-a here to mimic tmux
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }

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
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
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
-- You will need to install https://github.com/aca/wezterm.nvim
-- and ensure you export NVIM_LISTEN_ADDRESS per the README in that repo
local move_around = function(window, pane, direction_wez, direction_nvim)
  local result = os.execute("env NVIM_LISTEN_ADDRESS=/tmp/nvim" ..
    pane:pane_id() .. " wezterm.nvim.navigator " .. direction_nvim)
  if result then
    window:perform_action(wezterm.action({ SendString = "\x17" .. direction_nvim }), pane)
  else
    window:perform_action(wezterm.action({ ActivatePaneDirection = direction_wez }), pane)
  end
end

wezterm.on("move-left", function(window, pane)
  move_around(window, pane, "Left", "h")
end)

wezterm.on("move-right", function(window, pane)
  move_around(window, pane, "Right", "l")
end)

wezterm.on("move-up", function(window, pane)
  move_around(window, pane, "Up", "k")
end)

wezterm.on("move-down", function(window, pane)
  move_around(window, pane, "Down", "j")
end)

-- Setup muxing by default
config.unix_domains = {
  {
    name = 'unix',
  },
}

config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 2000 }

-- Custom key bindings
config.keys = {
  -- -- Disable Alt-Enter combination (already used in tmux to split pane)
  -- {
  --     key = 'Enter',
  --     mods = 'ALT',
  --     action = wezterm.action.DisableDefaultAssignment,
  -- },

  -- Copy mode
  {
    key = '[',
    mods = 'LEADER',
    action = wezterm.action.ActivateCopyMode,
  },

  -- ----------------------------------------------------------------
  -- TABS
  --
  -- Where possible, I'm using the same combinations as I would in tmux
  -- ----------------------------------------------------------------

  -- Show tab navigator; similar to listing panes in tmux
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.ShowTabNavigator,
  },
  -- Create a tab (alternative to Ctrl-Shift-Tab)
  {
    key = 'c',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  -- Rename current tab; analagous to command in tmux
  {
    key = ',',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },
  -- Move to next/previous TAB
  {
    key = 'n',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  -- Close tab
  {
    key = '&',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  -- ----------------------------------------------------------------
  -- PANES
  --
  -- These are great and get me most of the way to replacing tmux
  -- entirely, particularly as you can use "wezterm ssh" to ssh to another
  -- server, and still retain Wezterm as your terminal there.
  -- ----------------------------------------------------------------

  -- -- Vertical split
  {
    -- |
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
    },
  },
  -- Horizontal split
  {
    -- -
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
  -- CTRL + (h,j,k,l) to move between panes
  {
    key = 'h',
    mods = 'CTRL',
    action = wezterm.action({ EmitEvent = "move-left" }),
  },
  {
    key = 'j',
    mods = 'CTRL',
    action = wezterm.action({ EmitEvent = "move-down" }),
  },
  {
    key = 'k',
    mods = 'CTRL',
    action = wezterm.action({ EmitEvent = "move-up" }),
  },
  {
    key = 'l',
    mods = 'CTRL',
    action = wezterm.action({ EmitEvent = "move-right" }),
  },
  -- ALT + (h,j,k,l) to resize panes
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action({ EmitEvent = "resize-left" }),
  },
  {
    key = 'j',
    mods = 'ALT',
    action = wezterm.action({ EmitEvent = "resize-down" }),
  },
  {
    key = 'k',
    mods = 'ALT',
    action = wezterm.action({ EmitEvent = "resize-up" }),
  },
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action({ EmitEvent = "resize-right" }),
  },
  -- Close/kill active pane
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  -- Swap active pane with another one
  {
    key = '{',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus" },
  },
  -- Zoom current pane (toggle)
  {
    key = 'm',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  -- Move to next/previous pane
  {
    key = ';',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection('Prev'),
  },
  {
    key = 'o',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection('Next'),
  },

  -- ----------------------------------------------------------------
  -- Workspaces
  --
  -- These are roughly equivalent to tmux sessions.
  -- ----------------------------------------------------------------

  -- Attach to muxer
  {
    key = 'a',
    mods = 'LEADER',
    action = wezterm.action.AttachDomain 'unix',
  },

  -- Detach from muxer
  {
    key = 'd',
    mods = 'LEADER',
    action = wezterm.action.DetachDomain { DomainName = 'unix' },
  },

  -- Show list of workspaces
  {
    key = 's',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' },
  },

  -- Rename current session; analagous to command in tmux
  {
    key = '$',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for session',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(
              window:mux_window():get_workspace(),
              line
            )
          end
        end
      ),
    },
  },

  -- Move to next/previous Session
  {
    key = 'N', -- You can change this to any key you prefer
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SwitchWorkspaceRelative(1),
  },
  {
    key = 'P', -- You can change this to any key you prefer
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SwitchWorkspaceRelative(-1),
  },

}

return config
