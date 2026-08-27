local wezterm = require 'wezterm'

local action = wezterm.action
local M = {}

local function workspaces(window, pane)
  -- Here you can dynamically construct a longer list if needed

  local home = wezterm.home_dir
  local workspacesVariable = {
    { id = home, label = 'Home' },
    { id = home .. '/Developer/work', label = 'Work' },
    { id = home .. '/Developer/personal', label = 'Personal' },
    { id = home .. '/dotfiles', label = 'Dotfiles' },
  }

  window:perform_action(
    action.InputSelector {
      action = wezterm.action_callback(
        function(inner_window, inner_pane, id, label)
          if not id and not label then
            wezterm.log_info 'cancelled'
          else
            wezterm.log_info('id = ' .. id)
            wezterm.log_info('label = ' .. label)
            inner_window:perform_action(
              action.SwitchToWorkspace {
                name = label,
                spawn = {
                  label = 'Workspace: ' .. label,
                  cwd = id,
                },
              },
              inner_pane
            )
          end
        end
      ),
      title = 'Choose Workspace',
      choices = workspacesVariable,
      fuzzy = true,
      fuzzy_description = 'Fuzzy find and/or make a workspace',
    },
    pane
  )
end

M.keys = {
  -- Send C-a when pressing C-a twice
  {
    mods = 'LEADER',
    key = 'a',
    action = action.SendKey { key = 'a', mods = 'CTRL' },
  },

  { key = 'c', mods = 'LEADER', action = action.ActivateCopyMode },
  { key = ':', mods = 'LEADER', action = action.ActivateCommandPalette },
  {
    key = 's',
    mods = 'LEADER',
    action = action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  { key = 'w', mods = 'LEADER', action = action.ShowTabNavigator },
  { key = 'c', mods = 'LEADER', action = action.SpawnTab 'CurrentPaneDomain' },
  { key = 'p', mods = 'LEADER', action = action.ActivateTabRelative(-1) },
  { key = 'n', mods = 'LEADER', action = action.ActivateTabRelative(1) },
  -- Pane keybindings
  {
    key = '"',
    mods = 'LEADER',
    action = action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- SHIFT is for when caps lock is on
  {
    key = '%',
    mods = 'LEADER',
    action = action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  { key = 'h', mods = 'LEADER', action = action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = action.ActivatePaneDirection 'Up' },
  {
    key = 'l',
    mods = 'LEADER',
    action = action.ActivatePaneDirection 'Right',
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = action.CloseCurrentPane { confirm = true },
  },
  { key = 'z', mods = 'LEADER', action = action.TogglePaneZoomState },

  -- Key table for moving tabs and resizing panes
  {
    key = 'r',
    mods = 'LEADER',
    action = action.ActivateKeyTable { name = 'resize_pane', one_shot = false },
  },
  {
    key = '.',
    mods = 'LEADER',
    action = action.ActivateKeyTable { name = 'move_tab', one_shot = false },
  },

  -- Key for workspaces
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      workspaces(window, pane)
    end),
  },
  { key = 'n', mods = 'CTRL', action = action.SwitchWorkspaceRelative(1) },
  { key = 'p', mods = 'CTRL', action = action.SwitchWorkspaceRelative(-1) },
}

M.key_tables = {
  resize_pane = {
    { key = 'h', action = action.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = action.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = action.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = action.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
  move_tab = {
    { key = 'h', action = action.MoveTabRelative(-1) },
    { key = 'j', action = action.MoveTabRelative(-1) },
    { key = 'k', action = action.MoveTabRelative(1) },
    { key = 'l', action = action.MoveTabRelative(1) },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

return M
