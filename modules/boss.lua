local mod = EPGP:NewModule("boss", "AceEvent-3.0")
local Debug = LibStub("LibDebug-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local Boss = EPGPGetLibBabble("LibBabble-Boss-3.0")
local Coroutine = LibStub("LibCoroutine-1.0")
local DLG = LibStub("LibDialog-1.0")
local LOor = LibStub("LibEpgpOorProfile-1.0")
local SubZone = EPGPGetLibBabble("LibBabble-SubZone-3.0")
local Utils = LibStub("LibUtils-1.0")

local in_combat = false
local auto_reward = false

mod.dbDefaults = {
  profile = {
    enabled = false,
    wipedetection = false,
    autoreward = false,
    bossreward_10n = {},
    bossreward_10h = {},
    bossreward_25n = {},
    bossreward_25h = {},
    bossreward_10n_wipe = {},
    bossreward_10h_wipe = {},
    bossreward_25n_wipe = {},
    bossreward_25h_wipe = {},
  },
}

local function ShowKillPopup(boss_name)
  while (in_combat or DLG:ActiveDialog("EPGP_BOSS_DEAD") or
         DLG:ActiveDialog("EPGP_BOSS_ATTEMPT")) do
    Coroutine:Sleep(0.1)
  end

  DLG:Spawn("EPGP_BOSS_DEAD", boss_name)
end

local function ShowWipePopup(boss_name)
  while (in_combat or DLG:ActiveDialog("EPGP_BOSS_DEAD") or
         DLG:ActiveDialog("EPGP_BOSS_ATTEMPT")) do
    Coroutine:Sleep(0.1)
  end

  DLG:Spawn("EPGP_BOSS_ATTEMPT", boss_name)
end

local function BossAttempt(event_name, boss_name)
  local boss_name = boss_name or _G.UNKNOWNOBJECT
  Debug("Boss attempt: %s %s", event_name, boss_name)
  -- Temporary fix since we cannot unregister DBM callbacks
  if not mod:IsEnabled() then return end
  if not CanEditOfficerNote() or not EPGP:IsRLorML() then return end

  if event_name == "kill" or event_name == "DBM_Kill" or event_name == "BossKilled" then
    Coroutine:RunAsync(ShowKillPopup, boss_name)
  elseif (event_name == "wipe" or event_name == "DBM_Wipe") and mod.db.profile.wipedetection then
    Coroutine:RunAsync(ShowWipePopup, boss_name)
  end
end

local has_autority = nil
local function CheckAuthority()
  if CanEditOfficerNote() and EPGP:IsRLorML() then
    if not has_autority then
      if mod.db.profile.autoreward then
        DLG:Spawn("EPGP_BOSS_AUTO_REWARD_ENABLE")
      end
    end
    has_autority = true
  else
    if auto_reward then
      auto_reward = false
      EPGP:Print(L["BOSS_AUTO_REWARD_STOP"])
    end
    has_autority = false
  end
end

local function EncounterAttempt(event_name, boss_name, encounter_id, difficulty_id)
  if not difficulty_id then
    _, _, difficulty_id, _, _, _, _, _, _, _ = GetInstanceInfo()
  end
  Debug("Encounter attempt: %s %s %s", event_name, tostring(encounter_id), tostring(difficulty_id))

  if not mod.db.profile.autoreward or
     not auto_reward or
     encounter_id == nil or
     difficulty_id == nil then
    BossAttempt(event_name, boss_name)
    return
  end

  -- Temporary fix since we cannot unregister DBM callbacks
  if not mod:IsEnabled() then return end
  if not CanEditOfficerNote() or not EPGP:IsRLorML() then return end

  local boss_name = boss_name or _G.UNKNOWNOBJECT
  if event_name == "kill" or event_name == "DBM_Kill" then
    local ep = mod:GetEncounterKillEP(encounter_id, difficulty_id)
    if ep == nil then
      -- Most likely that the auto-award EP is not set for this boss.
      Coroutine:RunAsync(ShowKillPopup, boss_name)
    elseif ep > 0 then
      EPGP:IncMassEPBy(boss_name, ep)
    else
      EPGP:Print(string.format(L["BOSS_KILL_AUTO_AWARD_0_EP_DESC"], boss_name))
    end
  elseif event_name == "wipe" or event_name == "DBM_Wipe" then
    if not mod.db.profile.wipedetection then return end
    local ep_wipe = mod:GetEncounterWipeEP(encounter_id, difficulty_id)
    if ep_wipe == nil then
      Coroutine:RunAsync(ShowWipePopup, boss_name)
    elseif ep_wipe > 0 then
      EPGP:IncMassEPBy(boss_name .. " (attempt)", ep_wipe)
    else
      EPGP:Print(string.format(L["BOSS_WIPE_AUTO_AWARD_0_EP_DESC"], boss_name))
    end
  end
end

local function AutoAwardDisabled(v)
  return not mod.db.profile.autoreward
end

local function AutoAwardWipeDisabled(v)
  return not mod.db.profile.autoreward or not mod.db.profile.wipedetection
end

-- Template for EP values in UI configuration
local function EncounterKillPlate(difficulty, order, id, locale_name)
  encounterPlate = {
    name = locale_name .. " - " .. L["kill"],
    type = "input",
    pattern = "^%d*$",
    usage = L["Should be a non-negative integer"],
    order = order * 2 - 1,
    arg = {id, true, difficulty},
    disabled = AutoAwardDisabled,
  }
  return encounterPlate
end

local function EncounterWipePlate(difficulty, order, id, locale_name)
  encounterPlate = {
    name = locale_name .. " - " .. L["wipe"],
    type = "input",
    pattern = "^%d*$",
    usage = L["Should be a non-negative integer"],
    order = order * 2,
    arg = {id, false, difficulty},
    disabled = AutoAwardWipeDisabled,
  }
  return encounterPlate
end

function mod:PLAYER_REGEN_DISABLED()
  in_combat = true
end

function mod:PLAYER_REGEN_ENABLED()
  in_combat = false
end

function mod:EnableAutoReward()
  auto_reward = true
  EPGP:Print(L["BOSS_AUTO_REWARD_START"])
end

function mod:DisableAutoReward()
  auto_reward = false
  EPGP:Print(L["BOSS_AUTO_REWARD_STOP"])
end

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("boss", mod.dbDefaults)
end

-- DifficultyID: https://wowpedia.fandom.com/wiki/DifficultyID
function mod:GetEncounterKillEP(encounter_id, difficulty_id)
  if difficulty_id == 3 or difficulty_id == 175 then
    if mod.db.profile.bossreward_10n[encounter_id] then
      return mod.db.profile.bossreward_10n[encounter_id]
    end
  elseif difficulty_id == 4 or difficulty_id == 176 then
    if mod.db.profile.bossreward_25n[encounter_id] then
      return mod.db.profile.bossreward_25n[encounter_id]
    end
  elseif difficulty_id == 5 or difficulty_id == 193 then
    if mod.db.profile.bossreward_10h[encounter_id] then
      return mod.db.profile.bossreward_10h[encounter_id]
    end
  elseif difficulty_id == 6 or difficulty_id == 194 then
    if mod.db.profile.bossreward_25h[encounter_id] then
      return mod.db.profile.bossreward_25h[encounter_id]
    end
  end
  return nil
end

function mod:GetEncounterWipeEP(encounter_id, difficulty_id)
  if difficulty_id == 3 or difficulty_id == 175 then
    if mod.db.profile.bossreward_10n_wipe[encounter_id] then
      return mod.db.profile.bossreward_10n_wipe[encounter_id]
    end
  elseif difficulty_id == 4 or difficulty_id == 176 then
    if mod.db.profile.bossreward_25n_wipe[encounter_id] then
      return mod.db.profile.bossreward_25n_wipe[encounter_id]
    end
  elseif difficulty_id == 5 or difficulty_id == 193 then
    if mod.db.profile.bossreward_10h_wipe[encounter_id] then
      return mod.db.profile.bossreward_10h_wipe[encounter_id]
    end
  elseif difficulty_id == 6 or difficulty_id == 194 then
    if mod.db.profile.bossreward_25h_wipe[encounter_id] then
      return mod.db.profile.bossreward_25h_wipe[encounter_id]
    end
  end
  return nil
end

local function SetEP(info, ep)
  local id, kill, difficulty = unpack(info.arg)
  if kill then
    if difficulty == "10N" then
      mod.db.profile.bossreward_10n[id] = tonumber(ep)
    elseif difficulty == "10H" then
      mod.db.profile.bossreward_10h[id] = tonumber(ep)
    elseif difficulty == "25N" then
      mod.db.profile.bossreward_25n[id] = tonumber(ep)
    elseif difficulty == "25H" then
      mod.db.profile.bossreward_25h[id] = tonumber(ep)
    end
  else
    if difficulty == "10N" then
      mod.db.profile.bossreward_10n_wipe[id] = tonumber(ep)
    elseif difficulty == "10H" then
      mod.db.profile.bossreward_10h_wipe[id] = tonumber(ep)
    elseif difficulty == "25N" then
      mod.db.profile.bossreward_25n_wipe[id] = tonumber(ep)
    elseif difficulty == "25H" then
      mod.db.profile.bossreward_25h_wipe[id] = tonumber(ep)
    end
  end
end

local function GetEP(info)
  local id, kill, difficulty = unpack(info.arg)
  local ep
  if kill then
    if difficulty == "10N" then
      ep = mod.db.profile.bossreward_10n[id]
    elseif difficulty == "10H" then
      ep = mod.db.profile.bossreward_10h[id]
    elseif difficulty == "25N" then
      ep = mod.db.profile.bossreward_25n[id]
    elseif difficulty == "25H" then
      ep = mod.db.profile.bossreward_25h[id]
    end
  else
    if difficulty == "10N" then
      ep = mod.db.profile.bossreward_10n_wipe[id]
    elseif difficulty == "10H" then
      ep = mod.db.profile.bossreward_10h_wipe[id]
    elseif difficulty == "25N" then
      ep = mod.db.profile.bossreward_25n_wipe[id]
    elseif difficulty == "25H" then
      ep = mod.db.profile.bossreward_25h_wipe[id]
    end
  end
  if ep then
    return tostring(ep)
  else
    return ""
  end
end

mod.optionsName = _G.BOSS
mod.optionsDesc = L["Automatic boss tracking"]

-- Encounter ID: https://wowpedia.fandom.com/wiki/DungeonEncounterID#Classic
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
    name = L["BOSS_AUTO_REWARD_NAME"],
    desc = L["BOSS_AUTO_REWARD_DESC"],
    order = 10,
    width = 30,
    disabled = function(v) return not DBM end,
  },
  autoreward_desc = {
    order = 11,
    type = "description",
    name = L["BOSS_AUTO_REWARD_DESC"],
    fontSize = "medium",
  },
  rewardHeader = {
    order = 20,
    type = "header",
    name = L["BOSS_AUTO_REWARD_NAME"],
  },
  bossrewards_naxxramas_10 = {
    type = "group",
    name = SubZone["Naxxramas"] .. " (10)",
    order = 30,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1107, Boss["Anub'Rekhan"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1107, Boss["Anub'Rekhan"]),
      kill_2  = EncounterKillPlate("10N", 2,  1110, Boss["Grand Widow Faerlina"]),
      wipe_2  = EncounterWipePlate("10N", 2,  1110, Boss["Grand Widow Faerlina"]),
      kill_3  = EncounterKillPlate("10N", 3,  1116, Boss["Maexxna"]),
      wipe_3  = EncounterWipePlate("10N", 3,  1116, Boss["Maexxna"]),
      kill_4  = EncounterKillPlate("10N", 4,  1117, Boss["Noth the Plaguebringer"]),
      wipe_4  = EncounterWipePlate("10N", 4,  1117, Boss["Noth the Plaguebringer"]),
      kill_5  = EncounterKillPlate("10N", 5,  1112, Boss["Heigan the Unclean"]),
      wipe_5  = EncounterWipePlate("10N", 5,  1112, Boss["Heigan the Unclean"]),
      kill_6  = EncounterKillPlate("10N", 6,  1115, Boss["Loatheb"]),
      wipe_6  = EncounterWipePlate("10N", 6,  1115, Boss["Loatheb"]),
      kill_7  = EncounterKillPlate("10N", 7,  1113, Boss["Instructor Razuvious"]),
      wipe_7  = EncounterWipePlate("10N", 7,  1113, Boss["Instructor Razuvious"]),
      kill_8  = EncounterKillPlate("10N", 8,  1109, Boss["Gothik the Harvester"]),
      wipe_8  = EncounterWipePlate("10N", 8,  1109, Boss["Gothik the Harvester"]),
      kill_9  = EncounterKillPlate("10N", 9,  1121, Boss["The Four Horsemen"]),
      wipe_9  = EncounterWipePlate("10N", 9,  1121, Boss["The Four Horsemen"]),
      kill_10 = EncounterKillPlate("10N", 10, 1118, Boss["Patchwerk"]),
      wipe_10 = EncounterWipePlate("10N", 10, 1118, Boss["Patchwerk"]),
      kill_11 = EncounterKillPlate("10N", 11, 1111, Boss["Grobbulus"]),
      wipe_11 = EncounterWipePlate("10N", 11, 1111, Boss["Grobbulus"]),
      kill_12 = EncounterKillPlate("10N", 12, 1108, Boss["Gluth"]),
      wipe_12 = EncounterWipePlate("10N", 12, 1108, Boss["Gluth"]),
      kill_13 = EncounterKillPlate("10N", 13, 1120, Boss["Thaddius"]),
      wipe_13 = EncounterWipePlate("10N", 13, 1120, Boss["Thaddius"]),
      kill_14 = EncounterKillPlate("10N", 14, 1119, Boss["Sapphiron"]),
      wipe_14 = EncounterWipePlate("10N", 14, 1119, Boss["Sapphiron"]),
      kill_15 = EncounterKillPlate("10N", 15, 1114, Boss["Kel'Thuzad"]),
      wipe_15 = EncounterWipePlate("10N", 15, 1114, Boss["Kel'Thuzad"]),
    }
  },
  bossrewards_naxxramas_25 = {
    type = "group",
    name = SubZone["Naxxramas"] .. " (25)",
    order = 31,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1107, Boss["Anub'Rekhan"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1107, Boss["Anub'Rekhan"]),
      kill_2  = EncounterKillPlate("25N", 2,  1110, Boss["Grand Widow Faerlina"]),
      wipe_2  = EncounterWipePlate("25N", 2,  1110, Boss["Grand Widow Faerlina"]),
      kill_3  = EncounterKillPlate("25N", 3,  1116, Boss["Maexxna"]),
      wipe_3  = EncounterWipePlate("25N", 3,  1116, Boss["Maexxna"]),
      kill_4  = EncounterKillPlate("25N", 4,  1117, Boss["Noth the Plaguebringer"]),
      wipe_4  = EncounterWipePlate("25N", 4,  1117, Boss["Noth the Plaguebringer"]),
      kill_5  = EncounterKillPlate("25N", 5,  1112, Boss["Heigan the Unclean"]),
      wipe_5  = EncounterWipePlate("25N", 5,  1112, Boss["Heigan the Unclean"]),
      kill_6  = EncounterKillPlate("25N", 6,  1115, Boss["Loatheb"]),
      wipe_6  = EncounterWipePlate("25N", 6,  1115, Boss["Loatheb"]),
      kill_7  = EncounterKillPlate("25N", 7,  1113, Boss["Instructor Razuvious"]),
      wipe_7  = EncounterWipePlate("25N", 7,  1113, Boss["Instructor Razuvious"]),
      kill_8  = EncounterKillPlate("25N", 8,  1109, Boss["Gothik the Harvester"]),
      wipe_8  = EncounterWipePlate("25N", 8,  1109, Boss["Gothik the Harvester"]),
      kill_9  = EncounterKillPlate("25N", 9,  1121, Boss["The Four Horsemen"]),
      wipe_9  = EncounterWipePlate("25N", 9,  1121, Boss["The Four Horsemen"]),
      kill_10 = EncounterKillPlate("25N", 10, 1118, Boss["Patchwerk"]),
      wipe_10 = EncounterWipePlate("25N", 10, 1118, Boss["Patchwerk"]),
      kill_11 = EncounterKillPlate("25N", 11, 1111, Boss["Grobbulus"]),
      wipe_11 = EncounterWipePlate("25N", 11, 1111, Boss["Grobbulus"]),
      kill_12 = EncounterKillPlate("25N", 12, 1108, Boss["Gluth"]),
      wipe_12 = EncounterWipePlate("25N", 12, 1108, Boss["Gluth"]),
      kill_13 = EncounterKillPlate("25N", 13, 1120, Boss["Thaddius"]),
      wipe_13 = EncounterWipePlate("25N", 13, 1120, Boss["Thaddius"]),
      kill_14 = EncounterKillPlate("25N", 14, 1119, Boss["Sapphiron"]),
      wipe_14 = EncounterWipePlate("25N", 14, 1119, Boss["Sapphiron"]),
      kill_15 = EncounterKillPlate("25N", 15, 1114, Boss["Kel'Thuzad"]),
      wipe_15 = EncounterWipePlate("25N", 15, 1114, Boss["Kel'Thuzad"]),
    }
  },
  bossrewards_the_eye_of_eternity_10 = {
    type = "group",
    name = SubZone["The Eye of Eternity"] .. " (10)",
    order = 40,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1094, Boss["Malygos"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1094, Boss["Malygos"]),
    }
  },
  bossrewards_the_eye_of_eternity_25 = {
    type = "group",
    name = SubZone["The Eye of Eternity"] .. " (25)",
    order = 41,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1094, Boss["Malygos"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1094, Boss["Malygos"]),
    }
  },
  bossrewards_the_obsidian_sanctum_10 = {
    type = "group",
    name = SubZone["The Obsidian Sanctum"] .. " (10)",
    order = 50,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1090, Boss["Sartharion"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1090, Boss["Sartharion"]),
    }
  },
  bossrewards_the_obsidian_sanctum_25 = {
    type = "group",
    name = SubZone["The Obsidian Sanctum"] .. " (25)",
    order = 51,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1090, Boss["Sartharion"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1090, Boss["Sartharion"]),
    }
  },
  bossrewards_ulduar_10 = {
    type = "group",
    name = SubZone["Ulduar"] .. " (10)",
    order = 60,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1132, Boss["Flame Leviathan"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1132, Boss["Flame Leviathan"]),
      kill_2  = EncounterKillPlate("10N", 2,  1136, Boss["Ignis the Furnace Master"]),
      wipe_2  = EncounterWipePlate("10N", 2,  1136, Boss["Ignis the Furnace Master"]),
      kill_3  = EncounterKillPlate("10N", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("10N", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("10N", 4,  1142, Boss["XT-002 Deconstructor"]),
      wipe_4  = EncounterWipePlate("10N", 4,  1142, Boss["XT-002 Deconstructor"]),
      kill_5  = EncounterKillPlate("10N", 5,  1140, Boss["Assembly of Iron"]),
      wipe_5  = EncounterWipePlate("10N", 5,  1140, Boss["Assembly of Iron"]),
      kill_6  = EncounterKillPlate("10N", 6,  1137, Boss["Kologarn"]),
      wipe_6  = EncounterWipePlate("10N", 6,  1137, Boss["Kologarn"]),
      kill_7  = EncounterKillPlate("10N", 7,  1130, Boss["Algalon the Observer"]),
      wipe_7  = EncounterWipePlate("10N", 7,  1130, Boss["Algalon the Observer"]),
      kill_8  = EncounterKillPlate("10N", 8,  1131, Boss["Auriaya"]),
      wipe_8  = EncounterWipePlate("10N", 8,  1131, Boss["Auriaya"]),
      kill_9  = EncounterKillPlate("10N", 9,  1135, Boss["Hodir"]),
      wipe_9  = EncounterWipePlate("10N", 9,  1135, Boss["Hodir"]),
      kill_10 = EncounterKillPlate("10N", 10, 1141, Boss["Thorim"]),
      wipe_10 = EncounterWipePlate("10N", 10, 1141, Boss["Thorim"]),
      kill_11 = EncounterKillPlate("10N", 11, 1133, Boss["Freya"]),
      wipe_11 = EncounterWipePlate("10N", 11, 1133, Boss["Freya"]),
      kill_12 = EncounterKillPlate("10N", 12, 1138, Boss["Mimiron"]),
      wipe_12 = EncounterWipePlate("10N", 12, 1138, Boss["Mimiron"]),
      kill_13 = EncounterKillPlate("10N", 13, 1134, Boss["General Vezax"]),
      wipe_13 = EncounterWipePlate("10N", 13, 1134, Boss["General Vezax"]),
      kill_14 = EncounterKillPlate("10N", 14, 1143, Boss["Yogg-Saron"]),
      wipe_14 = EncounterWipePlate("10N", 14, 1143, Boss["Yogg-Saron"]),
    }
  },
  bossrewards_ulduar_25 = {
    type = "group",
    name = SubZone["Ulduar"] .. " (25)",
    order = 61,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1132, Boss["Flame Leviathan"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1132, Boss["Flame Leviathan"]),
      kill_2  = EncounterKillPlate("25N", 2,  1136, Boss["Ignis the Furnace Master"]),
      wipe_2  = EncounterWipePlate("25N", 2,  1136, Boss["Ignis the Furnace Master"]),
      kill_3  = EncounterKillPlate("25N", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("25N", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("25N", 4,  1142, Boss["XT-002 Deconstructor"]),
      wipe_4  = EncounterWipePlate("25N", 4,  1142, Boss["XT-002 Deconstructor"]),
      kill_5  = EncounterKillPlate("25N", 5,  1140, Boss["Assembly of Iron"]),
      wipe_5  = EncounterWipePlate("25N", 5,  1140, Boss["Assembly of Iron"]),
      kill_6  = EncounterKillPlate("25N", 6,  1137, Boss["Kologarn"]),
      wipe_6  = EncounterWipePlate("25N", 6,  1137, Boss["Kologarn"]),
      kill_7  = EncounterKillPlate("25N", 7,  1130, Boss["Algalon the Observer"]),
      wipe_7  = EncounterWipePlate("25N", 7,  1130, Boss["Algalon the Observer"]),
      kill_8  = EncounterKillPlate("25N", 8,  1131, Boss["Auriaya"]),
      wipe_8  = EncounterWipePlate("25N", 8,  1131, Boss["Auriaya"]),
      kill_9  = EncounterKillPlate("25N", 9,  1135, Boss["Hodir"]),
      wipe_9  = EncounterWipePlate("25N", 9,  1135, Boss["Hodir"]),
      kill_10 = EncounterKillPlate("25N", 10, 1141, Boss["Thorim"]),
      wipe_10 = EncounterWipePlate("25N", 10, 1141, Boss["Thorim"]),
      kill_11 = EncounterKillPlate("25N", 11, 1133, Boss["Freya"]),
      wipe_11 = EncounterWipePlate("25N", 11, 1133, Boss["Freya"]),
      kill_12 = EncounterKillPlate("25N", 12, 1138, Boss["Mimiron"]),
      wipe_12 = EncounterWipePlate("25N", 12, 1138, Boss["Mimiron"]),
      kill_13 = EncounterKillPlate("25N", 13, 1134, Boss["General Vezax"]),
      wipe_13 = EncounterWipePlate("25N", 13, 1134, Boss["General Vezax"]),
      kill_14 = EncounterKillPlate("25N", 14, 1143, Boss["Yogg-Saron"]),
      wipe_14 = EncounterWipePlate("25N", 14, 1143, Boss["Yogg-Saron"]),
    }
  },
  bossrewards_trial_of_the_crusader_10n = {
    type = "group",
    name = SubZone["Trial of the Crusader"] .. " (10N)",
    order = 70,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1088, Boss["The Beasts of Northrend"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1088, Boss["The Beasts of Northrend"]),
      kill_2  = EncounterKillPlate("10N", 2,  1087, Boss["Lord Jaraxxus"]),
      wipe_2  = EncounterWipePlate("10N", 2,  1087, Boss["Lord Jaraxxus"]),
      kill_3  = EncounterKillPlate("10N", 3,  1086, Boss["Faction Champions"]),
      wipe_3  = EncounterWipePlate("10N", 3,  1086, Boss["Faction Champions"]),
      kill_4  = EncounterKillPlate("10N", 4,  1089, Boss["The Twin Val'kyr"]),
      wipe_4  = EncounterWipePlate("10N", 4,  1089, Boss["The Twin Val'kyr"]),
      kill_5  = EncounterKillPlate("10N", 5,  1085, Boss["Anub'arak"]),
      wipe_5  = EncounterWipePlate("10N", 5,  1085, Boss["Anub'arak"]),
    }
  },
  bossrewards_trial_of_the_crusader_10h = {
    type = "group",
    name = SubZone["Trial of the Crusader"] .. " (10H)",
    order = 71,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10H", 1,  1088, Boss["The Beasts of Northrend"]),
      wipe_1  = EncounterWipePlate("10H", 1,  1088, Boss["The Beasts of Northrend"]),
      kill_2  = EncounterKillPlate("10H", 2,  1087, Boss["Lord Jaraxxus"]),
      wipe_2  = EncounterWipePlate("10H", 2,  1087, Boss["Lord Jaraxxus"]),
      kill_3  = EncounterKillPlate("10H", 3,  1086, Boss["Faction Champions"]),
      wipe_3  = EncounterWipePlate("10H", 3,  1086, Boss["Faction Champions"]),
      kill_4  = EncounterKillPlate("10H", 4,  1089, Boss["The Twin Val'kyr"]),
      wipe_4  = EncounterWipePlate("10H", 4,  1089, Boss["The Twin Val'kyr"]),
      kill_5  = EncounterKillPlate("10H", 5,  1085, Boss["Anub'arak"]),
      wipe_5  = EncounterWipePlate("10H", 5,  1085, Boss["Anub'arak"]),
    }
  },
  bossrewards_trial_of_the_crusader_25n = {
    type = "group",
    name = SubZone["Trial of the Crusader"] .. " (25N)",
    order = 72,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1088, Boss["The Beasts of Northrend"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1088, Boss["The Beasts of Northrend"]),
      kill_2  = EncounterKillPlate("25N", 2,  1087, Boss["Lord Jaraxxus"]),
      wipe_2  = EncounterWipePlate("25N", 2,  1087, Boss["Lord Jaraxxus"]),
      kill_3  = EncounterKillPlate("25N", 3,  1086, Boss["Faction Champions"]),
      wipe_3  = EncounterWipePlate("25N", 3,  1086, Boss["Faction Champions"]),
      kill_4  = EncounterKillPlate("25N", 4,  1089, Boss["The Twin Val'kyr"]),
      wipe_4  = EncounterWipePlate("25N", 4,  1089, Boss["The Twin Val'kyr"]),
      kill_5  = EncounterKillPlate("25N", 5,  1085, Boss["Anub'arak"]),
      wipe_5  = EncounterWipePlate("25N", 5,  1085, Boss["Anub'arak"]),
    }
  },
  bossrewards_trial_of_the_crusader_25h = {
    type = "group",
    name = SubZone["Trial of the Crusader"] .. " (25H)",
    order = 73,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25H", 1,  1088, Boss["The Beasts of Northrend"]),
      wipe_1  = EncounterWipePlate("25H", 1,  1088, Boss["The Beasts of Northrend"]),
      kill_2  = EncounterKillPlate("25H", 2,  1087, Boss["Lord Jaraxxus"]),
      wipe_2  = EncounterWipePlate("25H", 2,  1087, Boss["Lord Jaraxxus"]),
      kill_3  = EncounterKillPlate("25H", 3,  1086, Boss["Faction Champions"]),
      wipe_3  = EncounterWipePlate("25H", 3,  1086, Boss["Faction Champions"]),
      kill_4  = EncounterKillPlate("25H", 4,  1089, Boss["The Twin Val'kyr"]),
      wipe_4  = EncounterWipePlate("25H", 4,  1089, Boss["The Twin Val'kyr"]),
      kill_5  = EncounterKillPlate("25H", 5,  1085, Boss["Anub'arak"]),
      wipe_5  = EncounterWipePlate("25H", 5,  1085, Boss["Anub'arak"]),
    }
  },
  bossrewards_onyxias_lair_10 = {
    type = "group",
    name = SubZone["Onyxia's Lair"] .. " (10)",
    order = 80,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1084, Boss["Onyxia"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1084, Boss["Onyxia"]),
    }
  },
  bossrewards_onyxias_lair_25 = {
    type = "group",
    name = SubZone["Onyxia's Lair"] .. " (25)",
    order = 81,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1084, Boss["Onyxia"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1084, Boss["Onyxia"]),
    }
  },
  bossrewards_icecrown_citadel_10n = {
    type = "group",
    name = SubZone["Icecrown Citadel"] .. " (10N)",
    order = 90,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1101, Boss["Lord Marrowgar"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1101, Boss["Lord Marrowgar"]),
      kill_2  = EncounterKillPlate("10N", 2,  1100, Boss["Lady Deathwhisper"]),
      wipe_2  = EncounterWipePlate("10N", 2,  1100, Boss["Lady Deathwhisper"]),
      kill_3  = EncounterKillPlate("10N", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("10N", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("10N", 4,  1096, Boss["Deathbringer Saurfang"]),
      wipe_4  = EncounterWipePlate("10N", 4,  1096, Boss["Deathbringer Saurfang"]),
      kill_5  = EncounterKillPlate("10N", 5,  1097, Boss["Festergut"]),
      wipe_5  = EncounterWipePlate("10N", 5,  1097, Boss["Festergut"]),
      kill_6  = EncounterKillPlate("10N", 6,  1104, Boss["Rotface"]),
      wipe_6  = EncounterWipePlate("10N", 6,  1104, Boss["Rotface"]),
      kill_7  = EncounterKillPlate("10N", 7,  1102, Boss["Professor Putricide"]),
      wipe_7  = EncounterWipePlate("10N", 7,  1102, Boss["Professor Putricide"]),
      kill_8  = EncounterKillPlate("10N", 8,  1095, Boss["Blood Council"]),
      wipe_8  = EncounterWipePlate("10N", 8,  1095, Boss["Blood Council"]),
      kill_9  = EncounterKillPlate("10N", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      wipe_9  = EncounterWipePlate("10N", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      kill_10 = EncounterKillPlate("10N", 10, 1098, Boss["Valithria Dreamwalker"]),
      wipe_10 = EncounterWipePlate("10N", 10, 1098, Boss["Valithria Dreamwalker"]),
      kill_11 = EncounterKillPlate("10N", 11, 1105, Boss["Sindragosa"]),
      wipe_11 = EncounterWipePlate("10N", 11, 1105, Boss["Sindragosa"]),
      kill_12 = EncounterKillPlate("10N", 12, 1106, Boss["The Lich King"]),
      wipe_12 = EncounterWipePlate("10N", 12, 1106, Boss["The Lich King"]),
    }
  },
  bossrewards_icecrown_citadel_10h = {
    type = "group",
    name = SubZone["Icecrown Citadel"] .. " (10H)",
    order = 91,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10H", 1,  1101, Boss["Lord Marrowgar"]),
      wipe_1  = EncounterWipePlate("10H", 1,  1101, Boss["Lord Marrowgar"]),
      kill_2  = EncounterKillPlate("10H", 2,  1100, Boss["Lady Deathwhisper"]),
      wipe_2  = EncounterWipePlate("10H", 2,  1100, Boss["Lady Deathwhisper"]),
      kill_3  = EncounterKillPlate("10H", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("10H", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("10H", 4,  1096, Boss["Deathbringer Saurfang"]),
      wipe_4  = EncounterWipePlate("10H", 4,  1096, Boss["Deathbringer Saurfang"]),
      kill_5  = EncounterKillPlate("10H", 5,  1097, Boss["Festergut"]),
      wipe_5  = EncounterWipePlate("10H", 5,  1097, Boss["Festergut"]),
      kill_6  = EncounterKillPlate("10H", 6,  1104, Boss["Rotface"]),
      wipe_6  = EncounterWipePlate("10H", 6,  1104, Boss["Rotface"]),
      kill_7  = EncounterKillPlate("10H", 7,  1102, Boss["Professor Putricide"]),
      wipe_7  = EncounterWipePlate("10H", 7,  1102, Boss["Professor Putricide"]),
      kill_8  = EncounterKillPlate("10H", 8,  1095, Boss["Blood Council"]),
      wipe_8  = EncounterWipePlate("10H", 8,  1095, Boss["Blood Council"]),
      kill_9  = EncounterKillPlate("10H", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      wipe_9  = EncounterWipePlate("10H", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      kill_10 = EncounterKillPlate("10H", 10, 1098, Boss["Valithria Dreamwalker"]),
      wipe_10 = EncounterWipePlate("10H", 10, 1098, Boss["Valithria Dreamwalker"]),
      kill_11 = EncounterKillPlate("10H", 11, 1105, Boss["Sindragosa"]),
      wipe_11 = EncounterWipePlate("10H", 11, 1105, Boss["Sindragosa"]),
      kill_12 = EncounterKillPlate("10H", 12, 1106, Boss["The Lich King"]),
      wipe_12 = EncounterWipePlate("10H", 12, 1106, Boss["The Lich King"]),
    }
  },
  bossrewards_icecrown_citadel_25n = {
    type = "group",
    name = SubZone["Icecrown Citadel"] .. " (25N)",
    order = 92,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1101, Boss["Lord Marrowgar"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1101, Boss["Lord Marrowgar"]),
      kill_2  = EncounterKillPlate("25N", 2,  1100, Boss["Lady Deathwhisper"]),
      wipe_2  = EncounterWipePlate("25N", 2,  1100, Boss["Lady Deathwhisper"]),
      kill_3  = EncounterKillPlate("25N", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("25N", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("25N", 4,  1096, Boss["Deathbringer Saurfang"]),
      wipe_4  = EncounterWipePlate("25N", 4,  1096, Boss["Deathbringer Saurfang"]),
      kill_5  = EncounterKillPlate("25N", 5,  1097, Boss["Festergut"]),
      wipe_5  = EncounterWipePlate("25N", 5,  1097, Boss["Festergut"]),
      kill_6  = EncounterKillPlate("25N", 6,  1104, Boss["Rotface"]),
      wipe_6  = EncounterWipePlate("25N", 6,  1104, Boss["Rotface"]),
      kill_7  = EncounterKillPlate("25N", 7,  1102, Boss["Professor Putricide"]),
      wipe_7  = EncounterWipePlate("25N", 7,  1102, Boss["Professor Putricide"]),
      kill_8  = EncounterKillPlate("25N", 8,  1095, Boss["Blood Council"]),
      wipe_8  = EncounterWipePlate("25N", 8,  1095, Boss["Blood Council"]),
      kill_9  = EncounterKillPlate("25N", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      wipe_9  = EncounterWipePlate("25N", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      kill_10 = EncounterKillPlate("25N", 10, 1098, Boss["Valithria Dreamwalker"]),
      wipe_10 = EncounterWipePlate("25N", 10, 1098, Boss["Valithria Dreamwalker"]),
      kill_11 = EncounterKillPlate("25N", 11, 1105, Boss["Sindragosa"]),
      wipe_11 = EncounterWipePlate("25N", 11, 1105, Boss["Sindragosa"]),
      kill_12 = EncounterKillPlate("25N", 12, 1106, Boss["The Lich King"]),
      wipe_12 = EncounterWipePlate("25N", 12, 1106, Boss["The Lich King"]),
    }
  },
  bossrewards_icecrown_citadel_25h = {
    type = "group",
    name = SubZone["Icecrown Citadel"] .. " (25H)",
    order = 93,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25H", 1,  1101, Boss["Lord Marrowgar"]),
      wipe_1  = EncounterWipePlate("25H", 1,  1101, Boss["Lord Marrowgar"]),
      kill_2  = EncounterKillPlate("25H", 2,  1100, Boss["Lady Deathwhisper"]),
      wipe_2  = EncounterWipePlate("25H", 2,  1100, Boss["Lady Deathwhisper"]),
      kill_3  = EncounterKillPlate("25H", 3,  1139, Boss["Razorscale"]),
      wipe_3  = EncounterWipePlate("25H", 3,  1139, Boss["Razorscale"]),
      kill_4  = EncounterKillPlate("25H", 4,  1096, Boss["Deathbringer Saurfang"]),
      wipe_4  = EncounterWipePlate("25H", 4,  1096, Boss["Deathbringer Saurfang"]),
      kill_5  = EncounterKillPlate("25H", 5,  1097, Boss["Festergut"]),
      wipe_5  = EncounterWipePlate("25H", 5,  1097, Boss["Festergut"]),
      kill_6  = EncounterKillPlate("25H", 6,  1104, Boss["Rotface"]),
      wipe_6  = EncounterWipePlate("25H", 6,  1104, Boss["Rotface"]),
      kill_7  = EncounterKillPlate("25H", 7,  1102, Boss["Professor Putricide"]),
      wipe_7  = EncounterWipePlate("25H", 7,  1102, Boss["Professor Putricide"]),
      kill_8  = EncounterKillPlate("25H", 8,  1095, Boss["Blood Council"]),
      wipe_8  = EncounterWipePlate("25H", 8,  1095, Boss["Blood Council"]),
      kill_9  = EncounterKillPlate("25H", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      wipe_9  = EncounterWipePlate("25H", 9,  1103, Boss["Blood-Queen Lana'thel"]),
      kill_10 = EncounterKillPlate("25H", 10, 1098, Boss["Valithria Dreamwalker"]),
      wipe_10 = EncounterWipePlate("25H", 10, 1098, Boss["Valithria Dreamwalker"]),
      kill_11 = EncounterKillPlate("25H", 11, 1105, Boss["Sindragosa"]),
      wipe_11 = EncounterWipePlate("25H", 11, 1105, Boss["Sindragosa"]),
      kill_12 = EncounterKillPlate("25H", 12, 1106, Boss["The Lich King"]),
      wipe_12 = EncounterWipePlate("25H", 12, 1106, Boss["The Lich King"]),
    }
  },
  bossrewards_the_ruby_sanctum_10n = {
    type = "group",
    name = SubZone["The Ruby Sanctum"] .. " (10N)",
    order = 100,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10N", 1,  1150, Boss["Halion"]),
      wipe_1  = EncounterWipePlate("10N", 1,  1150, Boss["Halion"]),
    }
  },
  bossrewards_the_ruby_sanctum_10h = {
    type = "group",
    name = SubZone["The Ruby Sanctum"] .. " (10H)",
    order = 101,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("10H", 1,  1150, Boss["Halion"]),
      wipe_1  = EncounterWipePlate("10H", 1,  1150, Boss["Halion"]),
    }
  },
  bossrewards_the_ruby_sanctum_25n = {
    type = "group",
    name = SubZone["The Ruby Sanctum"] .. " (25N)",
    order = 102,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25N", 1,  1150, Boss["Halion"]),
      wipe_1  = EncounterWipePlate("25N", 1,  1150, Boss["Halion"]),
    }
  },
  bossrewards_the_ruby_sanctum_25h = {
    type = "group",
    name = SubZone["The Ruby Sanctum"] .. " (25H)",
    order = 103,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate("25H", 1,  1150, Boss["Halion"]),
      wipe_1  = EncounterWipePlate("25H", 1,  1150, Boss["Halion"]),
    }
  },
}

local function dbmCallback(event, mod)
  Debug("dbmCallback: %s %s", event, mod.combatInfo.name)
  EncounterAttempt(event, mod.combatInfo.name, mod.combatInfo.eId, mod.engagedDiffIndex)
end

local function bwCallback(event, mod)
  Debug("bwCallback: %s %s", event, mod.displayName)
  BossAttempt(event == "BigWigs_OnBossWin" and "kill" or "wipe", mod.displayName)
end

local function dxeCallback(event, encounter)
  Debug("dxeCallback: %s %s", event, encounter.name)
  BossAttempt("kill", encounter.name)
end

function mod:OnEnable()
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("GROUP_ROSTER_UPDATE", CheckAuthority)
  self:RegisterEvent("GUILD_ROSTER_UPDATE", CheckAuthority)
  CheckAuthority()

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

function mod:CheckGuildConfig(guild, realm)
  if (guild == "Order Of Rhonin" or guild == "EPGP test") and realm == "艾隆纳亚" then
    if not mod.db.profile.bossreward then
      mod.db.profile.bossreward = {}
    end
    Utils:CopyTable(LOor:GetBossKillEp(), mod.db.profile.bossreward)
    if mod.db.profile.bossreward_wipe then
      table.wipe(mod.db.profile.bossreward_wipe)
    end
  end
end

-- Unit Test

function mod:DebugTestOne(event, id)
  local id_ = id or 0
  id_ = tonumber(id_) or 0
  local name = _G.UNKNOWNOBJECT
  EPGP:Print(string.format("BOSS test: event=[%s], name=[%s], id=[%s]",
    tostring(event), name, tostring(id)))
  EncounterAttempt(event, name, id)
end

function mod:DebugTest()
  self:DebugTestOne("BossKilled", 715)
  self:DebugTestOne("DBM_Kill", 613)
  self:DebugTestOne("DBM_Wipe", 613)
  self:DebugTestOne("kill", 1121)

  self:DebugTestOne("BossKilled", nil)
  self:DebugTestOne("DBM_Kill", -1)
  self:DebugTestOne("DBM_Wipe", -1)
  self:DebugTestOne("kill", 0)
  self:DebugTestOne("wipe", 0)
  self:DebugTestOne("kill", "abc")
  self:DebugTestOne("wipe", "abc")

  self:DebugTestOne("InvalidEvent", 1116)
  self:DebugTestOne("InvalidEvent", 790)
  self:DebugTestOne("InvalidEvent", 1113)

  self:DebugTestOne("InvalidEvent", nil)
  self:DebugTestOne("InvalidEvent", -1)
  self:DebugTestOne("InvalidEvent", 0)
  self:DebugTestOne("InvalidEvent", "abc")
end
