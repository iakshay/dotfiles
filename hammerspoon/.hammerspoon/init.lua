-- https://github.com/LuciusChen/dotfiles/blob/master/.hammerspoon/conf.lua
hs.configdir = os.getenv("HOME") .. "/.hammerspoon"
package.path = table.concat({
    hs.configdir .. "/?.lua",
    hs.configdir .. "/?/init.lua",
    hs.configdir .. "/Spoons/?.spoon/init.lua",
    package.path,
}, ";")

local util = require("util")

blacklist = {"foo"}
-- reload on save: https://github.com/Porco-Rosso/PorcoSpoon/blob/main/init.lua#L1-L14
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local hyper = {"cmd", "alt", "ctrl", "shift"}

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon loaded")


-- disable hide windows shortcuts
local noop = function() end
-- hs.hotkey.bind.bind({ "cmd", "alt" }, "h", noop)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    hs.alert.show("Hello World!")
  end)

hs.urlevent.bind("someAlert", function(eventName, params)
    hs.alert.show("Received someAlert")
end)

hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall:andUse("Emojis")
spoon.Emojis:bindHotkeys({ toggle = { hyper, "2" } })


-- app not bind shortcuts
local createWindowChooser = function()
    local chooser = hs.chooser.new(function(choice)
        if choice then
            local window = hs.window.get(choice.id)
            window:focus()
        end
    end)

    hs.hotkey.bind(hyper, "space", function()
        local windows, wf = {}, hs.window.filter.new()
        local allWindows = wf:getWindows()

        for _, v in ipairs(allWindows) do
            local id = v:application():bundleID()
            -- if not util:includes(blackList, id) then
                table.insert(windows, {
                    text = v:application():name(),
                    subText = v:title(),
                    bundleID = v:application():bundleID(),
                    id = v:id(),
                })
            -- end
        end

        if #windows > 0 then
            chooser:choices(windows)
            chooser:show()
        end
    end)
end

createWindowChooser()