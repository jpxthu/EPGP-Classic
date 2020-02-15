local mod = EPGP:NewModule("rescale")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local DLG = LibStub("LibDialog-1.0")
local GP = LibStub("LibGearPoints-1.3")
local Utils = LibStub("LibUtils-1.0")

local function RecommendDecayIlvlString()
  local s = ""
  local standardIlvl, standardIlvlLastTier, standardIlvlNextTier = GP:GetRecommendIlvlParams()

  if standardIlvl and standardIlvlLastTier then
    local decayIlvl = standardIlvl - standardIlvlLastTier
    s = s .. string.format(
      "\n\n" .. L["Recommend value in current tier:"] ..
      "\n> " .. "decay_ilvl = %d = %d - %d",
      decayIlvl, standardIlvl, standardIlvlLastTier)
  end

  if standardIlvl and standardIlvlNextTier then
    local decayIlvl = standardIlvlNextTier - standardIlvl
    s = s .. string.format(
      "\n\n" .. L["Recommend value before next tier:"] ..
      "\n> " .. "decay_ilvl = %d = %d - %d",
      decayIlvl, standardIlvlNextTier, standardIlvl)
  end

  return s
end

-- rescale = {
--   order = 1003,
--   type = "execute",
--   name = L["Rescale GP"],
--   desc = L["Rescale GP of all members of the guild. This will reduce all main toons' GP by a tier worth of value. Use with care!"],
--   func = function() DLG:Spawn("EPGP_RESCALE_GP") end,
-- },

local function HelpPlate(desc, order)
  help = {
    order = order or 1,
    type = "description",
    name = desc,
    fontSize = "medium",
  }
  return help
end

mod.dbDefaults = {
  profile = {
    enabled = true,
  }
}

mod.optionsName = L["Rescale GP"]
mod.optionsDesc = L["Rescale GP of all members of the guild. This will reduce all main toons' GP by a tier worth of value. Use with care!"]
mod.optionsArgs = {
  help = HelpPlate(L["When a new tier comes, you may like to increase [standard_ilvl]. That can avoid large gear points. If you do that, a GP rescaling is recommended. Everyone's GP will be changed."] ..
                   "\n\n" .. "> GP_new = GP_old / 2 ^ (decay_ilvl / ilvl_denominator)" ..
                   "\n" .. "> decay_ilvl = standard_ilvl_new - standard_ilvl_old" ..
                   RecommendDecayIlvlString()),
  decayIlvl = {
    order = 2,
    type = "input",
    name = "decay_ilvl",
    pattern = "^[1-9]%d*$",
    usage = L["should be a positive integer"],
  },
  rescaleButton = {
    order = 3,
    type = "execute",
    name = L["Rescale GP"],
    func = function(info)
      if mod.db.profile.decayIlvl then
        DLG:Spawn("EPGP_RESCALE_GP", mod.db.profile.decayIlvl)
      end
    end,
  },

  resetGpHeader = {
    order = 11,
    type = "header",
    name = L["Reset GP"],
  },
  resetGpHelp = HelpPlate(L["Resets GP (not EP!) of all members of the guild. This will set all main toons' GP to 0. Use with care!"], 12),
  resetGp = {
    order = 13,
    type = "execute",
    name = L["Reset GP"],
    func = function() DLG:Spawn("EPGP_RESET_GP") end,
  },

  adjustGpHeader = {
    order = 21,
    type = "header",
    name = L["Mass Adjust GP"],
  },
  adjustGpHelp = HelpPlate(L["MASS_ADJUST_GP_DESC"], 22),
  adjustGpValue = {
    order = 23,
    type = "input",
    name = L["Value"],
    pattern = "^-?[1-9]%d*$",
    usage = L["should be a none-zero integer"],
  },
  adjustGpButton = {
    order = 24,
    type = "execute",
    name = L["Mass Adjust GP"],
    func = function()
      DLG:Spawn("EPGP_MASS_ADJUST_GP", mod.db.profile.adjustGpValue)
    end,
  },
}

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("rescale", mod.dbDefaults)
end
