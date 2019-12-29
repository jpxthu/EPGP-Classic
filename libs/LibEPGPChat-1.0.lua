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
