-- Pull in the wezterm API
local wezterm = require("wezterm")

local io = require("io")
local os = require("os")
local mux = wezterm.mux
local act = wezterm.action

-- NOTE: some help/reminders:
--
-- Add logs with wezterm.log_info("hello")
-- See logs from wezterm: CTRL+SHIFT+L
--
-- Update all plugins:
-- wezterm.plugin.update_all()

-- References:
-- https://github.com/fredrikaverpil/dotfiles/blob/d360c964518f274320b1363f4c4d0de808ec4805/stow/shared/.wezterm.lua
-- https://wezfurlong.org/wezterm/config/files.html
local config = wezterm.config_builder()
config.color_scheme = "Tokyo Night"

-- Set leader key to Ctrl-a (like tmux)
config.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 2000,
}

local function is_on_battery()
	local power_source = io.popen("pmset -g batt | grep 'AC Power'")
	local power_source_content = power_source:read("*a")
	power_source:close()

	local is_battery = string.find(power_source_content, "Battery Power")
	return is_battery
end

if is_on_battery() then
	config.max_fps = 60
else
	config.max_fps = 60
end

-- colorschemes
-- https://wezfurlong.org/wezterm/colorschemes/
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local function get_appearance()
	-- Always return "Dark" to force dark theme
	-- if wezterm.gui then
	-- 	return wezterm.gui.get_appearance() -- "Dark" or "Light"
	-- end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night Moon"
	else
		return "dayfox"
		-- return "Tokyo Night Day"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = scheme_for_appearance(get_appearance())
	window:set_config_overrides(overrides)
	window:toast_notification("wezterm", "configuration reloaded!", nil, 4000)
	-- Manually trigger status update on config reload
	window:perform_action(act.EmitEvent("update-status"), pane)
end)

--[[ Possible Modifier labels are:

 * `SUPER`, `CMD`, `WIN` - these are all equivalent: on macOS the `Command` key,
   on Windows the `Windows` key, on Linux this can also be the `Super` or `Hyper`
   key.  Left and right are equivalent.
 * `CTRL` - The control key.  Left and right are equivalent.
 * `SHIFT` - The shift key.  Left and right are equivalent.
 * `ALT`, `OPT`, `META` - these are all equivalent: on macOS the `Option` key,
   on other systems the `Alt` or `Meta` key.  Left and right are equivalent.
 * `LEADER` - a special modal modifier state managed by `wezterm`. See [Leader Key](#leader-key) for more information.
 * `VoidSymbol` - This keycode is emitted in special cases where the original
   function of the key has been removed. Such as in Linux and using `setxkbmap`.
   `setxkbmap -option caps:none`. The `CapsLock` will no longer function as
   before in all applications, instead emitting `VoidSymbol`.

You can combine modifiers using the `|` symbol ]]

config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.enable_tab_bar = true -- Explicitly enable tab bar
config.window_decorations = "RESIZE"

-- Enable mouse support (like tmux mouse on)
config.enable_scroll_bar = false

-- Track last active tab for MRU updates
local last_active_tab = {}
-- MRU (Most Recently Used) tab tracking
local tab_mru = {}

-- periodically update the status bar
wezterm.on("update-status", function(window, pane)
	local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
	local workspace = window:active_workspace()

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#7aa2f7" } }, -- Tokyo Night blue
		{ Text = workspace },
		{ Foreground = { Color = "#565f89" } }, -- Tokyo Night comment
		{ Text = " | " },
		{ Foreground = { Color = "#9ece6a" } }, -- Tokyo Night green
		{ Text = date .. " " }, -- Add padding to the right
	}))

	-- Update MRU when active tab changes
	local window_id = window:window_id()
	local tab = window:active_tab()
	if tab then
		local current_tab_id = tab:tab_id()
		if last_active_tab[window_id] ~= current_tab_id then
			wezterm.log_info(
				"Status: Tab changed from "
					.. tostring(last_active_tab[window_id])
					.. " to "
					.. tostring(current_tab_id)
			)
			last_active_tab[window_id] = current_tab_id

			-- Directly update MRU instead of emitting event
			if not tab_mru[window_id] then
				tab_mru[window_id] = {}
				wezterm.log_info("Status: Initialized MRU list for window " .. window_id)
			end

			local mru_list = tab_mru[window_id]

			-- Remove tab_id if it exists in the list
			for i, id in ipairs(mru_list) do
				if id == current_tab_id then
					table.remove(mru_list, i)
					break
				end
			end

			-- Insert at the front (most recent)
			table.insert(mru_list, 1, current_tab_id)

			-- Clean up: remove entries for tabs that no longer exist
			local valid_tabs = {}
			for _, t in ipairs(window:mux_window():tabs()) do
				valid_tabs[t:tab_id()] = true
			end

			local cleaned_list = {}
			for _, id in ipairs(mru_list) do
				if valid_tabs[id] then
					table.insert(cleaned_list, id)
				end
			end
			tab_mru[window_id] = cleaned_list

			wezterm.log_info(
				"Status: Updated MRU list, length=" .. #cleaned_list .. ", list=" .. table.concat(cleaned_list, ",")
			)
		end
	end
end)

-- Set update interval to 1 second (1000ms) for real-time clock
config.status_update_interval = 1000

config.font_size = 16

-- config.font = wezterm.font("IBM Plex Mono", {
-- 	weight = "Regular",
-- 	italic = false,
-- })
-- --
config.line_height = 1.1
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Enable automatic tab numbering (like tmux base-index 1)
config.tab_max_width = 25

-- Custom tab title formatting (remove + and * signs)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_title
	-- If no explicit title is set, use the active pane's title
	if title and #title > 0 then
		title = title
	else
		title = tab.active_pane.title
	end

	-- Clean up the title - remove common prefixes and trim
	title = title:gsub("^[^@]+@[^:]+:", "") -- Remove user@host: prefix (SSH format)
	title = title:gsub("^~/", "") -- Remove home directory prefix
	title = title:gsub("^/Users/[^/]+/", "") -- Remove /Users/username/ prefix
	title = title:gsub("^/home/[^/]+/", "") -- Remove /home/username/ prefix (remote)
	title = title:gsub("^workspace/", "") -- Remove workspace/ prefix
	title = title:gsub("^SSH:", "") -- Remove SSH: domain prefix
	title = title:gsub("^SSHMUX:", "") -- Remove SSHMUX: domain prefix

	-- Check if any pane in the tab is zoomed
	local is_zoomed = false
	for _, pane in ipairs(tab.panes) do
		if pane.is_zoomed then
			is_zoomed = true
			break
		end
	end

	-- Add zoom indicator after tab number
	local zoom_indicator = is_zoomed and "[Z] " or ""

	-- Format: tab_index [Z] | title (Z indicates zoomed)
	return {
		{ Text = string.format(" %d %s| %s ", tab.tab_index + 1, zoom_indicator, title) },
	}
end)

-- Mux
-- https://wezterm.org/multiplexing.html
-- config.unix_domains = {
-- 	{
-- 		name = "unix",
-- 	},
-- }
--
-- -- Connect automatically to the mux server if it is running
-- config.default_gui_startup_args = { "connect", "unix" }

-- SSH domains are auto-populated from ~/.ssh/config
-- devbox will be available as "SSHMUX:devbox" (multiplexing) and "SSH:devbox" (plain)

-- Session management

local session_manager = require("wezterm-session-manager/session-manager")
wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

-- Update MRU order when a tab is activated
wezterm.on("update-mru", function(window, pane)
	local window_id = window:window_id()
	local tab = window:active_tab()
	if not tab then
		wezterm.log_info("MRU Update: No active tab")
		return
	end

	local tab_id = tab:tab_id()

	-- Initialize MRU list for this window if it doesn't exist
	if not tab_mru[window_id] then
		tab_mru[window_id] = {}
		wezterm.log_info("MRU Update: Initialized MRU list for window " .. window_id)
	end

	local mru_list = tab_mru[window_id]

	-- Remove tab_id if it exists in the list
	for i, id in ipairs(mru_list) do
		if id == tab_id then
			table.remove(mru_list, i)
			break
		end
	end

	-- Insert at the front (most recent)
	table.insert(mru_list, 1, tab_id)

	-- Clean up: remove entries for tabs that no longer exist
	local valid_tabs = {}
	for _, t in ipairs(window:mux_window():tabs()) do
		valid_tabs[t:tab_id()] = true
	end

	local cleaned_list = {}
	for _, id in ipairs(mru_list) do
		if valid_tabs[id] then
			table.insert(cleaned_list, id)
		end
	end
	tab_mru[window_id] = cleaned_list

	wezterm.log_info("MRU Update: tab_id=" .. tab_id .. ", mru_list=" .. table.concat(cleaned_list, ","))
end)

-- Cycle to next tab in MRU order
local function activate_mru_tab(window, pane, direction)
	local window_id = window:window_id()
	local current_tab = window:active_tab()
	if not current_tab then
		wezterm.log_info("MRU: No active tab")
		return
	end

	local current_tab_id = current_tab:tab_id()
	local mru_list = tab_mru[window_id] or {}

	wezterm.log_info(
		"MRU: window_id="
			.. tostring(window_id)
			.. ", current_tab_id="
			.. tostring(current_tab_id)
			.. ", mru_list_len="
			.. tostring(#mru_list)
			.. ", direction="
			.. tostring(direction)
	)

	-- If MRU list is empty or has only one tab, fall back to sequential
	if #mru_list <= 1 then
		wezterm.log_info("MRU: Falling back to sequential navigation (list too short)")
		if direction > 0 then
			window:perform_action(act.ActivateTabRelative(1), pane)
		else
			window:perform_action(act.ActivateTabRelative(-1), pane)
		end
		return
	end

	-- Find current position in MRU list
	local current_pos = nil
	for i, id in ipairs(mru_list) do
		if id == current_tab_id then
			current_pos = i
			break
		end
	end

	if not current_pos then
		-- Current tab not in MRU list, activate the most recent one
		wezterm.log_info("MRU: Current tab not in list, using position 1")
		current_pos = 1
	end

	-- Calculate next position (wrapping around)
	local next_pos = current_pos + direction
	if next_pos > #mru_list then
		next_pos = 1
	elseif next_pos < 1 then
		next_pos = #mru_list
	end

	local target_tab_id = mru_list[next_pos]
	wezterm.log_info(
		"MRU: Switching from pos " .. current_pos .. " to pos " .. next_pos .. " (tab_id=" .. target_tab_id .. ")"
	)

	-- Find and activate the target tab
	for _, tab in ipairs(window:mux_window():tabs()) do
		if tab:tab_id() == target_tab_id then
			tab:activate()
			wezterm.log_info("MRU: Tab activated successfully")
			break
		end
	end
end

-- Custom event handler for creating new lazygit tab
wezterm.on("lazygit-new-tab", function(window, pane)
	-- Get the stored directory from environment variables
	local overrides = window:get_config_overrides() or {}
	local env_vars = overrides.set_environment_variables or {}
	local cwd = env_vars.LAZYGIT_CWD or pane:get_current_working_dir().file_path

	-- Extract directory basename for tab title
	local dir_name = cwd:match("([^/]+)/?$") or "lazygit"

	window:perform_action(
		act.SpawnCommandInNewTab({
			args = { "zsh", "-l", "-c", "cd '" .. cwd .. "' && /opt/homebrew/bin/lazygit" },
			domain = "CurrentPaneDomain",
		}),
		pane
	)

	-- Set the tab title to just the directory basename
	local active_tab = window:active_tab()
	if active_tab then
		active_tab:set_title(dir_name)
	end

	-- Clean up the stored directory
	env_vars.LAZYGIT_CWD = nil
	overrides.set_environment_variables = env_vars
	window:set_config_overrides(overrides)
end)

-- Event handler for setting lazygit tab title after workspace creation
wezterm.on("set-lazygit-tab-title", function(window, pane)
	local cwd = pane:get_current_working_dir()
	local current_path = cwd and cwd.file_path or ""
	local dir_name = current_path:match("([^/]+)/?$") or "lazygit"

	local active_tab = window:active_tab()
	if active_tab then
		active_tab:set_title(dir_name)
	end
end)

-- Re-run last command in previous pane
local function rerun_last_command_in_prev_pane(window, pane)
	local tab = window:active_tab()
	local prev_pane = tab:get_pane_direction("Prev")

	if prev_pane then
		-- Send up arrow to get last command, then enter to execute
		prev_pane:send_text("\x1b[A\r")
	end
end

-- Smart-splits.nvim integration functions
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	local user_vars = pane:get_user_vars()
	return user_vars.IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.keys = {
	-- Smart-splits navigation
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- Smart-splits resizing
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	-- Keep existing CMD bindings
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "P",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateCommandPalette,
	},

	-- Tmux-style leader key bindings
	-- Send the leader key through when pressed twice
	{
		key = "a",
		mods = "LEADER",
		action = act.SendKey({ key = "a", mods = "CTRL" }),
	},

	-- Split panes (| for horizontal, - for vertical)
	{
		key = "|",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Vim-style pane navigation (leader-based fallback)
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},

	-- Pane resizing (H/J/K/L with leader)
	{
		key = "H",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "J",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "K",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "L",
		mods = "LEADER",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},

	-- Zoom pane (like tmux zoom)
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},

	-- Create new tab (like tmux new window)
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},

	-- Navigate between tabs
	{
		key = "n",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},

	-- MRU tab switching (macOS-style with Ctrl+Tab)
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			activate_mru_tab(window, pane, 1)
		end),
	},
	{
		key = "Tab",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			activate_mru_tab(window, pane, -1)
		end),
	},

	-- Switch to specific tabs with leader + number (like tmux)
	{
		key = "1",
		mods = "LEADER",
		action = act.ActivateTab(0),
	},
	{
		key = "2",
		mods = "LEADER",
		action = act.ActivateTab(1),
	},
	{
		key = "3",
		mods = "LEADER",
		action = act.ActivateTab(2),
	},
	{
		key = "4",
		mods = "LEADER",
		action = act.ActivateTab(3),
	},
	{
		key = "5",
		mods = "LEADER",
		action = act.ActivateTab(4),
	},
	{
		key = "6",
		mods = "LEADER",
		action = act.ActivateTab(5),
	},
	{
		key = "7",
		mods = "LEADER",
		action = act.ActivateTab(6),
	},
	{
		key = "8",
		mods = "LEADER",
		action = act.ActivateTab(7),
	},
	{
		key = "9",
		mods = "LEADER",
		action = act.ActivateTab(8),
	},

	-- Close pane (like tmux prefix + x)
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},

	-- Close current tab (like tmux prefix + &)
	{
		key = "&",
		mods = "LEADER",
		action = act.CloseCurrentTab({ confirm = true }),
	},

	-- Move tabs (like tmux move-window)
	{
		key = "<",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(-1),
	},
	{
		key = ">",
		mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(1),
	},

	-- Rename tab (like tmux prefix + ,)
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Copy mode (like tmux copy mode)
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},

	-- Clear screen and scrollback (like tmux Ctrl-k)
	{
		key = "k",
		mods = "LEADER|CTRL",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},

	-- Toggle status bar visibility
	{
		key = "d",
		mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			if overrides.enable_tab_bar == true then
				overrides.enable_tab_bar = false
			else
				overrides.enable_tab_bar = true
			end
			window:set_config_overrides(overrides)
		end),
	},
	-- Rename current session; analagous to command in tmux
	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},
	-- Swap panes
	{
		key = "s",
		mods = "LEADER",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	-- Session manager bindings
	-- {
	-- 	key = "s",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = act({ EmitEvent = "save_session" }),
	-- },
	-- {
	-- 	key = "L",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = act({ EmitEvent = "load_session" }),
	-- },
	-- {
	-- 	key = "R",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = act({ EmitEvent = "restore_session" }),
	-- },

	-- Pane expansion bindings (like tmux C-v, C-h, C-r)
	{
		key = "v",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local panes = tab:panes()
			if #panes > 1 then
				-- Expand current pane vertically to take full height
				local current_pane = pane
				for _, p in ipairs(panes) do
					if p:pane_id() == current_pane:pane_id() then
						-- This pane should expand vertically
						window:perform_action(act.AdjustPaneSize({ "Up", 1000 }), p)
						window:perform_action(act.AdjustPaneSize({ "Down", 1000 }), p)
					end
				end
			end
		end),
	},
	{
		key = "h",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local panes = tab:panes()
			if #panes > 1 then
				-- Expand current pane horizontally to take full width
				local current_pane = pane
				for _, p in ipairs(panes) do
					if p:pane_id() == current_pane:pane_id() then
						-- This pane should expand horizontally
						window:perform_action(act.AdjustPaneSize({ "Left", 1000 }), p)
						window:perform_action(act.AdjustPaneSize({ "Right", 1000 }), p)
					end
				end
			end
		end),
	},
	{
		key = "r",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			local panes = tab:panes()
			if #panes > 1 then
				-- Reset all panes to equal sizes by cycling through each pane
				-- and resetting its size adjustments
				for _, p in ipairs(panes) do
					-- Reset each pane's size by adjusting in all directions
					-- This effectively "equalizes" the layout
					window:perform_action(act.AdjustPaneSize({ "Left", -1000 }), p)
					window:perform_action(act.AdjustPaneSize({ "Right", -1000 }), p)
					window:perform_action(act.AdjustPaneSize({ "Up", -1000 }), p)
					window:perform_action(act.AdjustPaneSize({ "Down", -1000 }), p)
				end
			end
		end),
	},

	-- Smart lazygit: workspace toggle or new tab based on directory (leader-g)
	{
		key = "g",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local current_workspace = window:active_workspace()
			local current_cwd = pane:get_current_working_dir()
			local current_path = current_cwd and current_cwd.file_path or ""

			if current_workspace == "lazygit" then
				-- Switch back to default workspace
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			else
				-- Check if lazygit workspace exists
				local workspaces = mux.get_workspace_names()
				local lazygit_exists = false
				for _, workspace in ipairs(workspaces) do
					if workspace == "lazygit" then
						lazygit_exists = true
						break
					end
				end

				if lazygit_exists then
					-- Find lazygit workspace window and check all tabs for matching directory
					local matching_tab_found = false
					local lazygit_window = nil

					for _, win in ipairs(mux.all_windows()) do
						if win:get_workspace() == "lazygit" then
							lazygit_window = win
							local tabs = win:tabs()
							-- Check all tabs in the lazygit workspace
							for _, tab in ipairs(tabs) do
								local panes = tab:panes()
								if #panes > 0 then
									local tab_cwd = panes[1]:get_current_working_dir()
									local tab_path = tab_cwd and tab_cwd.file_path or ""
									if tab_path == current_path then
										matching_tab_found = true
										-- Activate the matching tab
										tab:activate()
										break
									end
								end
							end
							if matching_tab_found then
								break
							end
						end
					end

					if matching_tab_found then
						-- Switch to lazygit workspace (the matching tab is already activated)
						window:perform_action(act.SwitchToWorkspace({ name = "lazygit" }), pane)
					else
						-- Store the current directory in window user vars before switching
						window:set_config_overrides({
							set_environment_variables = { LAZYGIT_CWD = current_path },
						})
						-- Switch to lazygit workspace and emit custom event to create new tab
						window:perform_action(act.SwitchToWorkspace({ name = "lazygit" }), pane)
						window:perform_action(act.EmitEvent("lazygit-new-tab"), pane)
					end
				else
					-- Create new lazygit workspace with lazygit running in current directory
					local dir_name = current_path:match("([^/]+)/?$") or "lazygit"
					window:perform_action(
						act.SwitchToWorkspace({
							name = "lazygit",
							spawn = {
								args = { "zsh", "-l", "-c", "/opt/homebrew/bin/lazygit" },
								domain = "CurrentPaneDomain",
							},
						}),
						pane
					)
					-- Set tab title after creating workspace
					window:perform_action(act.EmitEvent("set-lazygit-tab-title"), pane)
				end
			end
		end),
	},

	-- Toggle between k9s workspace and default workspace (leader-k)
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local current_workspace = window:active_workspace()

			if current_workspace == "k9s" then
				-- Switch back to default workspace
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			else
				-- Create new k9s workspace with k9s running with proper environment
				window:perform_action(
					act.SwitchToWorkspace({
						name = "k9s",
						spawn = {
							args = { "zsh", "-l", "-c", "/opt/homebrew/bin/k9s" },
							domain = "CurrentPaneDomain",
						},
					}),
					pane
				)
			end
		end),
	},

	-- Toggle between gh dash workspace and default workspace (leader-p)
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local current_workspace = window:active_workspace()

			if current_workspace == "gh-dash" then
				-- Switch back to default workspace
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			else
				window:perform_action(
					act.SwitchToWorkspace({
						name = "gh-dash",
						spawn = {
							args = { "zsh", "-l", "-c", "/opt/homebrew/bin/gh dash" },
							domain = "CurrentPaneDomain",
						},
					}),
					pane
				)
			end
		end),
	},

	-- Toggle between btop workspace and default workspace (leader-t)
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local current_workspace = window:active_workspace()

			if current_workspace == "btop" then
				-- Switch back to default workspace
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			else
				-- Create new btop workspace with btop running
				window:perform_action(
					act.SwitchToWorkspace({
						name = "btop",
						spawn = {
							args = { "zsh", "-l", "-c", "/opt/homebrew/bin/btop" },
							domain = "CurrentPaneDomain",
						},
					}),
					pane
				)
			end
		end),
	},

	-- Toggle between devbox workspace and default workspace (leader+d)
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local current_workspace = window:active_workspace()

			if current_workspace == "devbox" then
				-- Switch back to default workspace
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			else
				-- Create new devbox workspace using SSH multiplexing domain
				window:perform_action(
					act.SwitchToWorkspace({
						name = "devbox",
						spawn = {
							domain = { DomainName = "SSHMUX:devbox" },
							cwd = "/home/akshay.aurora/workspace/smithdb",
						},
					}),
					pane
				)
			end
		end),
	},

	-- Cycle through workspaces with Ctrl+backtick
	{
		key = "`",
		mods = "CTRL",
		action = act.SwitchWorkspaceRelative(1),
	},
	{
		key = "`",
		mods = "CTRL|SHIFT",
		action = act.SwitchWorkspaceRelative(-1),
	},
	-- Cycle through workspaces with CMD+backtick
	{
		key = "`",
		mods = "CMD",
		action = act.SwitchWorkspaceRelative(1),
	},
	{
		key = "`",
		mods = "CMD|SHIFT",
		action = act.SwitchWorkspaceRelative(-1),
	},
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action({ SendString = "\x1b\r" }),
	},
	{
		key = "y",
		mods = "LEADER",
		action = act.PaneSelect({ show_pane_ids = true }),
	},

	-- Re-run last command in previous pane (LEADER+R)
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action_callback(rerun_last_command_in_prev_pane),
	},

	-- Re-run last command in previous pane (CMD+R)
	{
		key = "r",
		mods = "CMD",
		action = wezterm.action_callback(rerun_last_command_in_prev_pane),
	},
	{ key = "UpArrow", mods = "SHIFT", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "SHIFT", action = act.ScrollToPrompt(1) },

	-- Switch to default workspace with Escape key, or emit escape if already in default
	-- {
	-- 	key = "Escape",
	-- 	mods = "NONE",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local current_workspace = window:active_workspace()
	-- 		if current_workspace ~= "default" then
	-- 			-- Switch to default workspace if not already there
	-- 			window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
	-- 		else
	-- 			-- Emit escape key if already in default workspace
	-- 			window:perform_action(act.SendKey({ key = "Escape" }), pane)
	-- 		end
	-- 	end),
	-- },
}

-- Set copy mode to use vim keybindings (like tmux)
config.key_tables = {
	copy_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },

		-- Vim navigation
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

		-- Word movement
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },

		-- Line movement
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },

		-- Page movement
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },

		-- Selection
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },

		-- Copy (yank)
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				{ CopyMode = "Close" },
			}),
		},
	},
	search_mode = {
		-- Close search
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },

		-- Navigate matches (multiple intuitive options)
		{ key = "Enter", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "Enter", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },

		-- Page movement
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
	},
}
config.launch_menu = {
	{
		label = "Zsh",
		args = { "zsh", "-l" },
	},
}
return config
