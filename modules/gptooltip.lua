local mod = EPGP:NewModule("gptooltip", "AceHook-3.0")

local GP = LibStub("LibGearPoints-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local ItemUtils = LibStub("LibItemUtils-1.0")

function OnTooltipSetItem(tooltip, ...)
  local _, itemlink = tooltip:GetItem()
  local gp1, c1, gp2, c2, gp3, c3 = GP:GetValue(itemlink)

  if not gp1 then return end
  tooltip:AddLine(
    ("GP1: %d (%s)"):format(gp1, c1),
    NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
  if not gp2 then return end
  tooltip:AddLine(
    ("GP2: %d (%s)"):format(gp2, c2),
    NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
  if not gp3 then return end
  tooltip:AddLine(
    ("GP3: %d (%s)"):format(gp3, c3),
    NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

mod.dbDefaults = {
  profile = {
    enabled = true,
    threshold = 4, -- Epic
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
