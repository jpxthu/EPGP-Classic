local mod = EPGP:NewModule("reminder", "AceEvent-3.0")
local DLG = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

local in_raid = false

local function EnableCombatlog()
  if not EPGP.db.profile.remind_enable_combatlog then
    return
  end
  if LoggingCombat() then
    EPGP:Print(L["COMBATLOG_IS_LOGGING"])
    return
  end
  if in_raid then
    DLG:Spawn("EPGP_REMIND_ENABLE_COMBATLOG")
  end
end

local function Init()
  in_raid = not not UnitInRaid("player")
  EnableCombatlog()
end

local function RaidtatusChanged()
  EnableCombatlog()
end

function mod:GROUP_ROSTER_UPDATE()
  local tmp = not not UnitInRaid("player")
  if in_raid ~= tmp then
    in_raid = tmp
    RaidtatusChanged()
  end
end

function mod:OnEnable()
  self:RegisterEvent("GROUP_ROSTER_UPDATE")
  Init()
end
