-- Pull in the wezterm API
local wezterm = require("wezterm")

local io = require("io")
local os = require("os")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

wezterm:log_info("debugging")
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Tomorrow (dark) (terminal.sexy)"

wezterm.on("window-config-reloaded", function(window, pane)
	window:toast_notification("wezterm", "configuration reloaded!", nil, 4000)
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

config.hide_tab_bar_if_only_one_tab = true
config.default_prog = { "/opt/homebrew/bin/tmux", "new", "-As0" }

-- config.launch_menu = {{
--     label = 'fish',
--     args = {'/opt/homebrew/bin/fish', '-l'}
-- }, {
--     label = 'zsh',
--     args = {'/bin/zsh', '-l'}
-- }, {
--     label = 'bash',
--     args = {'/bin/bash', '-l'}
-- }}

-- wezterm.on('gui-startup', function(cmd)
--     local tab, pane, window = mux.spawn_window(cmd or {})
--     window:gui_window():maximize()
-- end)

config.keys = {}

table.insert(config.keys, {
	key = "Enter",
	mods = "CMD",
	action = wezterm.action.ToggleFullScreen,
})

table.insert(config.keys, {
	key = "P",
	mods = "CMD|SHIFT",
	action = wezterm.action.ActivateCommandPalette,
})
config.font_size = 15

-- wezterm.on('open-uri', function(window, pane, uri)
--   wezterm.log_info uri
--   -- wezterm.log_info uri
--   -- otherwise, by not specifying a return value, we allow later
--   -- handlers and ultimately the default action to caused the
--   -- URI to be opened in the browser
--   return true
-- end)

-- wezterm.log_info wezterm.default_hyperlink_rules()

function printTable(t)
	for key, value in pairs(t) do
		if type(value) == "table" then
			print(key .. ":")
			printTable(value) -- Recursively print nested tables
		else
			print(key .. ": " .. tostring(value))
		end
	end
end

-- Example usage
myTable = {
	name = "Alice",
	age = 30,
	hobbies = { "reading", "sports" },
	address = {
		city = "Wonderland",
		zip = "12345",
	},
}

-- printTable(wezterm.default_hyperlink_rules())

config.launch_menu = {
	{
		args = { "top" },
	},
	{
		-- Optional label to show in the launcher. If omitted, a label
		-- is derived from the `args`
		label = "Bash",
		-- The argument array to spawn.  If omitted the default program
		-- will be used as described in the documentation above
		args = { "bash", "-l" },

		-- You can specify an alternative current working directory;
		-- if you don't specify one then a default based on the OSC 7
		-- escape sequence will be used (see the Shell Integration
		-- docs), falling back to the home directory.
		-- cwd = "/some/path"

		-- You can override environment variables just for this command
		-- by setting this here.  It has the same semantics as the main
		-- set_environment_variables configuration option described above
		-- set_environment_variables = { FOO = "bar" },
	},
}

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
	local scrollback_text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
	wezterm:log_info("debug")
	-- Create a temporary file to pass to vim
	local name = os.tmpname()
	local f = io.open(name, "w+")
	f:write(scrollback_text)
	f:flush()
	f:close()

	-- Open a new tab running vim and tell it to open the file
	window:perform_action(
		act.SpawnCommandInNewTab({
			args = { "vim", name },
		}),
		pane
	)

	-- Wait "enough" time for vim to read the file before we remove it.
	-- The window creation and process spawn are asynchronous wrt. running
	-- this script and are not awaitable, so we just pick a number.
	--
	-- Note: We don't strictly need to remove this file, but it is nice
	-- to avoid cluttering up the temporary directory.
	wezterm.sleep_ms(1000)
	os.remove(name)
end)

table.insert(config.keys, {
	key = "E",
	mods = "CTRL",
	-- See also https://wezfurlong.org/wezterm/config/lua/wezterm/action_callback.html
	action = act.EmitEvent("trigger-vim-with-scrollback"),
})

-- https://github.com/folke/zen-mode.nvim?tab=readme-ov-file#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
