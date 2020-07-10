local MAJOR_VERSION = "LibEPGPChat-1.0"
local MINOR_VERSION = 10000

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

function lib:Announce(medium, fmt, ...)
  if not medium then return end

  local msg = string.format(fmt, ...)
  local str = "EPGP:"
  for _,s in pairs({strsplit(" ", msg)}) do
    if #str + #s >= 250 then
      SendChatMessage(str, medium)
      str = "EPGP:"
    end
    str = str .. " " .. s
  end

  SendChatMessage(str, medium)
end

function lib:Interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function lib:Whisper(name, fmt, ...)
  local msg = string.format(fmt, ...)
  local str = "EPGP:"
  for _,s in pairs({strsplit(" ", msg)}) do
    if #str + #s >= 250 then
      SendChatMessage(str, "WHISPER", nil, name)
      str = "EPGP:"
    end
    str = str .. " " .. s
  end

  SendChatMessage(str, "WHISPER", nil, name)
end
