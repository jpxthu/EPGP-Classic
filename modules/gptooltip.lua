local mod = EPGP:NewModule("gptooltip", "AceHook-3.0")

local GP = LibStub("LibGearPoints-1.3")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LUI = LibStub("LibEPGPUI-1.0")
local ItemUtils = LibStub("LibItemUtils-1.0")

local function TooltipAddGpLine(tooltip, i, gp, c)
  if not gp then return false end
  local c = c or ""
  if gp == 0 and c == "" then return false end
  local s = ("GP%d: %d"):format(i, gp)
  if c ~= "" then
    s = s .. " (" .. c .. ")"
  end
  tooltip:AddLine(s)
  return true
end

local function TooltipAddGpLines(tooltip, itemlink)
  local gp1, c1, gp2, c2, gp3, c3 = GP:GetValue(itemlink)
  if not TooltipAddGpLine(tooltip, 1, gp1, c1) then return end
  if not TooltipAddGpLine(tooltip, 2, gp2, c2) then return end
  if not TooltipAddGpLine(tooltip, 3, gp3, c3) then return end
end

local function OnTooltipSetItem(tooltip, ...)
  local _, itemlink = tooltip:GetItem()
  if not itemlink then return end

  if mod.db.profile.ilvl then
    local ilvl = select(4, GetItemInfo(itemlink))
    if ilvl then
      tooltip:AddLine("ilvl: " .. tostring(ilvl))
    end
  end

  TooltipAddGpLines(tooltip, itemlink)

  local item_log = EPGP:GetModule("log"):ItemLog(itemlink)
  if item_log then
    tooltip:AddLine(" ")
    for i, v in pairs(item_log) do
      tooltip:AddLine(v)
    end
  end
end

mod.dbDefaults = {
  profile = {
    enabled = true,
    threshold = 4, -- Epic
    ilvl = false,
  }
}

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("gptooltip", mod.dbDefaults)
end

mod.optionsName = L["Tooltip"]
mod.optionsDesc = L["GP on tooltips"]
mod.optionsArgs = {
  help = {
    order = 1,
    type = "description",
    name = L["Provide a proposed GP value of armor on tooltips. Quest items or tokens that can be traded for armor will also have a proposed GP value."],
    fontSize = "medium",
  },
  threshold = {
    order = 10,
    type = "select",
    name = L["Quality threshold"],
    desc = L["Only display GP values for items at or above this quality."],
    values = {
      [0] = ITEM_QUALITY0_DESC, -- Poor
      [1] = ITEM_QUALITY1_DESC, -- Common
      [2] = ITEM_QUALITY2_DESC, -- Uncommon
      [3] = ITEM_QUALITY3_DESC, -- Rare
      [4] = ITEM_QUALITY4_DESC, -- Epic
      [5] = ITEM_QUALITY5_DESC, -- Legendary
      [6] = ITEM_QUALITY6_DESC, -- Artifact
    },
    get = function() return GP:GetQualityThreshold() end,
    set = function(info, itemQuality)
      info.handler.db.profile.threshold = itemQuality
      GP:SetQualityThreshold(itemQuality)
    end,
  },
  spacer1 = LUI:OptionsSpacer(11, 0.001),
  ilvl = {
    order = 20,
    type = "toggle",
    name = L["Show item level"],
  },
}

function mod:OnEnable()
  GP:SetQualityThreshold(self.db.profile.threshold)

  local obj = EnumerateFrames()
  while obj do
    if obj:IsObjectType("GameTooltip") and obj ~= ItemUtils.tooltip then
      assert(obj:HasScript("OnTooltipSetItem"))
      self:HookScript(obj, "OnTooltipSetItem", OnTooltipSetItem)
    end
    obj = EnumerateFrames(obj)
  end
end
