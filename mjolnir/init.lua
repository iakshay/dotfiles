local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local screen = require "mjolnir.screen"
local fnutils = require "mjolnir.fnutils"
local geometry = require "mjolnir.geometry"
local pathwatcher = require "mjolnir._asm.pathwatcher"
local alert = require "mjolnir.alert"
alert.show("Hello from Mjolnir")

pathwatcher.new(os.getenv("HOME") .. "/.mjolnir/", function()
  alert.show("Reloaded config")
  mjolnir.reload()
end):start()

local mash = {"cmd", "alt", "ctrl"}

-- fullscreen
hotkey.bind(mash, "F", function()
  local win = window.focusedwindow()
  win:maximize();
end)

-- 50% vertical
hotkey.bind(mash, "1", function()
  local win = window.focusedwindow()
  local frame = win:screen():frame()
  win:setframe(geometry.rect(0, 0, 0.5 * frame.w, frame.h));
end)

hotkey.bind(mash, "2", function()
  local win = window.focusedwindow()
  local frame = win:screen():frame()
  win:setframe(geometry.rect(0.5 * frame.w, 0, 0.5 * frame.w, frame.h));
end)

-- open console
hotkey.bind(mash, "c", function()
  mjolnir.openconsole()
end)
