local MAJOR_VERSION = "LibEPGPUI-1.0"
local MINOR_VERSION = 10000

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

function lib:CreateIconButton(name, parent, height, width, texture)
  local button = CreateFrame("Button", name, parent)
  button:SetHeight(height)
  button:SetWidth(width)
  button:SetHighlightTexture("Interface\\Buttons\\YellowOrange64_faded")
  button:SetPushedTexture("Interface\\Buttons\\YELLOWORANGE64")
  button:SetAlpha(0.25)

  button.icon = parent:CreateTexture(nil, "BACKGROUND")
  button.icon:SetTexture(texture)
  button.icon:ClearAllPoints()
  button.icon:SetAllPoints(button)

  return button
end
