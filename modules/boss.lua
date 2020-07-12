local mod = EPGP:NewModule("boss", "AceEvent-3.0")
local Debug = LibStub("LibDebug-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local Coroutine = LibStub("LibCoroutine-1.0")
local DLG = LibStub("LibDialog-1.0")
local Encounters = LibStub("LibEncounters")

local in_combat = false

mod.dbDefaults = {
  profile = {
    enabled = false,
    wipedetection = false,
    autoreward = false,
    bossreward = {},
  },
}

local function ShowPopup(event_name, boss_name)
  while (in_combat or DLG:ActiveDialog("EPGP_BOSS_DEAD") or
          DLG:ActiveDialog("EPGP_BOSS_ATTEMPT")) do
    Coroutine:Sleep(0.1)
  end

  local dialog
  if event_name == "kill" or event_name == "DBM_Kill" or event_name == "BossKilled" then
    DLG:Spawn("EPGP_BOSS_DEAD", boss_name)
  elseif event_name == "wipe" or event_name == "DBM_Wipe" and mod.db.profile.wipedetection then
    DLG:Spawn("EPGP_BOSS_ATTEMPT", boss_name)
  end
end

local function BossAttempt(event_name, boss_name)
  Debug("Boss attempt: %s %s", event_name, boss_name)
  -- Temporary fix since we cannot unregister DBM callbacks
  if not mod:IsEnabled() then return end

  if CanEditOfficerNote() and EPGP:IsRLorML() then
    Coroutine:RunAsync(ShowPopup, event_name, boss_name)
  end
end

local function EncounterAttempt(event_name, encounter_id)
  Debug("New Encounter attempt: %s %s", event_name, encounter_id)
  -- Temporary fix since we cannot unregister DBM callbacks
  if not mod:IsEnabled() then return end

  local encounter = Encounters:GetEncounter(encounter_id)

  if CanEditOfficerNote() and EPGP:IsRLorML() then
    if mod.db.profile.autoreward then
      ep = mod:GetEncounterEP(encounter_id)
      if ep ~= nil and encounter.name ~= nil and ep > 0 then
        EPGP:IncMassEPBy(encounter.name, ep)
      end
    else
      Coroutine:RunAsync(ShowPopup, event_name, encounter.name)
    end
  end
end

local function EncounterPlate(encounter_id, order)
  local encounter = Encounters:GetEncounter(encounter_id)
  encounterPlate = {
    name = encounter.name,
    type = "input",
    order = order,
    arg = encounter_id
  }
  return encounterPlate
end

function mod:PLAYER_REGEN_DISABLED()
  in_combat = true
end

function mod:PLAYER_REGEN_ENABLED()
  in_combat = false
end

function mod:DebugTest()
  NewBossAttempt("BossKilled", 715)
end

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("boss", mod.dbDefaults)
end

function mod:GetEncounterEP(encounter_id)
  if mod.db.profile.bossreward[encounter_id] ~= nil then
    return tonumber(mod.db.profile.bossreward[encounter_id])
  else
    return 0
  end
end

local function SetEP(info, ep)
  mod.db.profile.bossreward[info.arg] = tonumber(ep)
end

local function GetEP(info)
  if mod.db.profile.bossreward[info.arg] ~= nil then
    return tostring(mod.db.profile.bossreward[info.arg])
  else
    return ''
  end
end

mod.optionsName = _G.BOSS
mod.optionsDesc = L["Automatic boss tracking"]
mod.optionsArgs = {
  help = {
    order = 1,
    type = "description",
    name = L["Automatic boss tracking by means of a popup to mass award EP to the raid and standby when a boss is killed."],
    fontSize = "medium",
  },
  wipedetection = {
    type = "toggle",
    name = L["Wipe awards"],
    desc = L["Awards for wipes on bosses. Requires DBM, DXE, or BigWigs"],
    order = 2,
    width = 30,
    disabled = function(v) return not DBM end,
  },
  autoreward = {
    type = "toggle",
    name = L["Automatic EP Reward"],
    desc = L["Automatically reward EP to the raid after a boss kill. Requires DBM"],
    order = 3,
    width = 30,
    disabled = function(v) return not DBM end,
  },
  rewardHeader = {
    order = 4,
    type = "header",
    name = L["Automatic EP Reward"],
  },
  bossrewards_mc = {
    type = "group",
    name = Encounters:GetInstance(409).name,
    order = 5,
    set = SetEP,
    get = GetEP,
    args = {
      lucifron = EncounterPlate(663, 1),
      magmadar = EncounterPlate(664, 2),
      gehennes = EncounterPlate(665, 3),
      garr = EncounterPlate(666, 4),
      shazzrah = EncounterPlate(667, 5),
      baron = EncounterPlate(668, 6),
      sulfuron = EncounterPlate(669, 7),
      golemagg = EncounterPlate(670, 8),
      majordomo = EncounterPlate(671, 9),
      ragnaros = EncounterPlate(672, 10)
    }
  },
  bossrewards_ony = {
    type = "group",
    name = Encounters:GetInstance(249).name,
    order = 6,
    set = SetEP,
    get = GetEP,
    args = {
      onyxia = EncounterPlate(1084,1),
    }
  },
  bossrewards_bwl = {
    type = "group",
    name = Encounters:GetInstance(469).name,
    order = 7,
    set = SetEP,
    get = GetEP,
    args = {
      razorgore = EncounterPlate(610, 1),
      vaelastrasz = EncounterPlate(611, 2),
      broodlord = EncounterPlate(612, 3),
      firemaw = EncounterPlate(613, 4),
      ebonroc = EncounterPlate(614, 5),
      flamegor = EncounterPlate(615, 6),
      chromaggus = EncounterPlate(616, 7),
      nefarian = EncounterPlate(617, 8),
    }
  },
  bossrewards_zg = {
    type = "group",
    name = Encounters:GetInstance(309).name,
    order = 8,
    set = SetEP,
    get = GetEP,
    args = {
      venoxis = EncounterPlate(784, 1),
      jeklik = EncounterPlate(785, 2),
      marli = EncounterPlate(786, 3),
      mandokir = EncounterPlate(787, 4),
      hazzarah = EncounterPlate(788, 5),
      thekal = EncounterPlate(789, 6),
      gahzranka = EncounterPlate(790, 7),
      arlokk = EncounterPlate(791, 8),
      jindo = EncounterPlate(792, 9),
      hakkar = EncounterPlate(793, 10),
    }
  },
  bossrewards_aq20 = {
    type = "group",
    name = Encounters:GetInstance(509).name,
    order = 9,
    set = SetEP,
    get = GetEP,
    args = {
      kurinnaxx = EncounterPlate(718, 1),
      rajaxx = EncounterPlate(719, 2),
      moam = EncounterPlate(720, 3),
      buru = EncounterPlate(721, 4),
      ayamiss = EncounterPlate(722, 5),
      ossirian = EncounterPlate(723, 6),
    }
  },
  bossrewards_aq40 = {
    type = "group",
    name = Encounters:GetInstance(531).name,
    order = 10,
    set = SetEP,
    get = GetEP,
    args = {
      skeram = EncounterPlate(709, 1),
      bugtrio = EncounterPlate(710, 2),
      sartura = EncounterPlate(711, 3),
      fankriss = EncounterPlate(712, 4),
      viscidus = EncounterPlate(713, 5),
      huhuran = EncounterPlate(714, 6),
      twins = EncounterPlate(715, 7),
      ouro = EncounterPlate(716, 8),
      cthun = EncounterPlate(717, 9),
    }
  },
  bossrewards_naxx = {
    type = "group",
    name = Encounters:GetInstance(533).name,
    order = 11,
    set = SetEP,
    get = GetEP,
    args = {
      anub = EncounterPlate(1107, 1),
      faerlina = EncounterPlate(1110, 2),
      maexxna = EncounterPlate(1116, 3),
      noth = EncounterPlate(1117, 4),
      heigan = EncounterPlate(1112, 5),
      loatheb = EncounterPlate(1115, 6),
      razuvious = EncounterPlate(1113, 7),
      gothik = EncounterPlate(1109, 8),
      fourhorse = EncounterPlate(1121, 9),
      patchwerk = EncounterPlate(1118, 10),
      grobbulus = EncounterPlate(1111, 11),
      gluth = EncounterPlate(1108, 12),
      thaddius = EncounterPlate(1120, 13),
      sapphiron = EncounterPlate(1119, 14),
      kelthuzad = EncounterPlate(1114, 15),
    }
  }
}

local function dbmCallback(event, mod)
  Debug("dbmCallback: %s %s", event, mod.combatInfo.name)
  EncounterAttempt(event, mod.combatInfo.eId)
end

local function bwCallback(event, module)
  Debug("bwCallback: %s %s", event, module.displayName)
  BossAttempt(event == "BigWigs_OnBossWin" and "kill" or "wipe", module.displayName)
end

local function dxeCallback(event, encounter)
  Debug("dxeCallback: %s %s", event, encounter.name)
  BossAttempt("kill", encounter.name)
end

function mod:OnEnable()
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  if DBM then
    EPGP:Print(L["Using %s for boss kill tracking"]:format("DBM"))
    DBM:RegisterCallback("DBM_Kill", dbmCallback)
    DBM:RegisterCallback("DBM_Wipe", dbmCallback)
  elseif BigWigsLoader then
    EPGP:Print(L["Using %s for boss kill tracking"]:format("BigWigs"))
    BigWigsLoader.RegisterMessage(self, "BigWigs_OnBossWin", bwCallback)
    BigWigsLoader.RegisterMessage(self, "BigWigs_OnBossWipe", bwCallback)
  elseif DXE then
    EPGP:Print(L["Using %s for boss kill tracking"]:format("DXE"))
    DXE.RegisterCallback(mod, "TriggerDefeat", dxeCallback)
  end
end

function mod:OnDisable()
  if BigWigsLoader then
    BigWigsLoader.UnregisterMessage(self, "BigWigs_OnBossWin")
    BigWigsLoader.UnregisterMessage(self, "BigWigs_OnBossWipe")
  elseif DXE then
    DXE.UnregisterCallback(mod, "TriggerDefeat")
  end
end
