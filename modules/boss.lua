local mod = EPGP:NewModule("boss", "AceEvent-3.0")
local Debug = LibStub("LibDebug-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local Coroutine = LibStub("LibCoroutine-1.0")
local DLG = LibStub("LibDialog-1.0")
local Encounters = LibStub("LibEncounters")
local LOor = LibStub("LibEpgpOorProfile-1.0")
local Utils = LibStub("LibUtils-1.0")

local in_combat = false
local auto_reward = false

mod.dbDefaults = {
  profile = {
    enabled = false,
    wipedetection = false,
    autoreward = false,
    bossreward = {},
    bossreward_wipe = {},
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

local function EncounterAttempt(event_name, boss_name, encounter_id)
  Debug("Encounter attempt: %s %s", event_name, tostring(encounter_id))

  if not mod.db.profile.autoreward or
     not auto_reward or
     encounter_id == nil then
    BossAttempt(event_name, boss_name)
    return
  end

  -- Temporary fix since we cannot unregister DBM callbacks
  if not mod:IsEnabled() then return end
  if not CanEditOfficerNote() or not EPGP:IsRLorML() then return end

  local boss_name = boss_name or _G.UNKNOWNOBJECT
  if event_name == "kill" or event_name == "DBM_Kill" then
    local ep = mod:GetEncounterKillEP(encounter_id)
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
    local ep_wipe = mod:GetEncounterWipeEP(encounter_id)
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
local function EncounterKillPlate(encounter_id, order)
  local encounter = Encounters:GetEncounter(encounter_id)
  if type(encounter) == "table" then
    encounterPlate = {
      name = encounter.name .. " - " .. L["kill"],
      type = "input",
      pattern = "^%d*$",
      usage = L["Should be a non-negative integer"],
      order = order * 2 - 1,
      arg = {encounter_id, true},
      disabled = AutoAwardDisabled,
    }
    return encounterPlate
  else
    return {}
  end
end

local function EncounterWipePlate(encounter_id, order)
  local encounter = Encounters:GetEncounter(encounter_id)
  if type(encounter) == "table" then
    encounterPlate = {
      name = encounter.name .. " - " .. L["wipe"],
      type = "input",
      pattern = "^%d*$",
      usage = L["Should be a non-negative integer"],
      order = order * 2,
      arg = {encounter_id, false},
      disabled = AutoAwardWipeDisabled,
    }
    return encounterPlate
  else
    return {}
  end
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

function mod:GetEncounterKillEP(encounter_id)
  if mod.db.profile.bossreward[encounter_id] then
    return mod.db.profile.bossreward[encounter_id]
  else
    return nil
  end
end

function mod:GetEncounterWipeEP(encounter_id)
  if mod.db.profile.bossreward_wipe[encounter_id] then
    return mod.db.profile.bossreward_wipe[encounter_id]
  else
    return nil
  end
end

local function SetEP(info, ep)
  local id, kill = unpack(info.arg)
  if kill then
    mod.db.profile.bossreward[id] = tonumber(ep)
  else
    mod.db.profile.bossreward_wipe[id] = tonumber(ep)
  end
end

local function GetEP(info)
  local id, kill = unpack(info.arg)
  local ep
  if kill then
    ep = mod.db.profile.bossreward[id]
  else
    ep = mod.db.profile.bossreward_wipe[id]
  end
  if ep then
    return tostring(ep)
  else
    return ""
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
  -- bossrewards_mc = {
  --   type = "group",
  --   name = Encounters:GetInstance(409).name,
  --   order = 21,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     lucifron_kill  = EncounterKillPlate(663, 1),
  --     lucifron_wipe  = EncounterWipePlate(663, 1),
  --     magmadar_kill  = EncounterKillPlate(664, 2),
  --     magmadar_wipe  = EncounterWipePlate(664, 2),
  --     gehennes_kill  = EncounterKillPlate(665, 3),
  --     gehennes_wipe  = EncounterWipePlate(665, 3),
  --     garr_kill      = EncounterKillPlate(666, 4),
  --     garr_wipe      = EncounterWipePlate(666, 4),
  --     shazzrah_kill  = EncounterKillPlate(667, 5),
  --     shazzrah_wipe  = EncounterWipePlate(667, 5),
  --     baron_kill     = EncounterKillPlate(668, 6),
  --     baron_wipe     = EncounterWipePlate(668, 6),
  --     sulfuron_kill  = EncounterKillPlate(669, 7),
  --     sulfuron_wipe  = EncounterWipePlate(669, 7),
  --     golemagg_kill  = EncounterKillPlate(670, 8),
  --     golemagg_wipe  = EncounterWipePlate(670, 8),
  --     majordomo_kill = EncounterKillPlate(671, 9),
  --     majordomo_wipe = EncounterWipePlate(671, 9),
  --     ragnaros_kill  = EncounterKillPlate(672, 10),
  --     ragnaros_wipe  = EncounterWipePlate(672, 10),
  --   }
  -- },
  -- bossrewards_ony = {
  --   type = "group",
  --   name = Encounters:GetInstance(249).name,
  --   order = 22,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     onyxia_kill = EncounterKillPlate(1084, 1),
  --     onyxia_wipe = EncounterWipePlate(1084, 1),
  --   }
  -- },
  -- bossrewards_bwl = {
  --   type = "group",
  --   name = Encounters:GetInstance(469).name,
  --   order = 23,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     razorgore_kill   = EncounterKillPlate(610, 1),
  --     razorgore_wipe   = EncounterWipePlate(610, 1),
  --     vaelastrasz_kill = EncounterKillPlate(611, 2),
  --     vaelastrasz_wipe = EncounterWipePlate(611, 2),
  --     broodlord_kill   = EncounterKillPlate(612, 3),
  --     broodlord_wipe   = EncounterWipePlate(612, 3),
  --     firemaw_kill     = EncounterKillPlate(613, 4),
  --     firemaw_wipe     = EncounterWipePlate(613, 4),
  --     ebonroc_kill     = EncounterKillPlate(614, 5),
  --     ebonroc_wipe     = EncounterWipePlate(614, 5),
  --     flamegor_kill    = EncounterKillPlate(615, 6),
  --     flamegor_wipe    = EncounterWipePlate(615, 6),
  --     chromaggus_kill  = EncounterKillPlate(616, 7),
  --     chromaggus_wipe  = EncounterWipePlate(616, 7),
  --     nefarian_kill    = EncounterKillPlate(617, 8),
  --     nefarian_wipe    = EncounterWipePlate(617, 8),
  --   }
  -- },
  -- bossrewards_zg = {
  --   type = "group",
  --   name = Encounters:GetInstance(309).name,
  --   order = 24,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     venoxis_kill   = EncounterKillPlate(784, 1),
  --     venoxis_wipe   = EncounterWipePlate(784, 1),
  --     jeklik_kill    = EncounterKillPlate(785, 2),
  --     jeklik_wipe    = EncounterWipePlate(785, 2),
  --     marli_kill     = EncounterKillPlate(786, 3),
  --     marli_wipe     = EncounterWipePlate(786, 3),
  --     mandokir_kill  = EncounterKillPlate(787, 4),
  --     mandokir_wipe  = EncounterWipePlate(787, 4),
  --     hazzarah_kill  = EncounterKillPlate(788, 5),
  --     hazzarah_wipe  = EncounterWipePlate(788, 5),
  --     thekal_kill    = EncounterKillPlate(789, 6),
  --     thekal_wipe    = EncounterWipePlate(789, 6),
  --     gahzranka_kill = EncounterKillPlate(790, 7),
  --     gahzranka_wipe = EncounterWipePlate(790, 7),
  --     arlokk_kill    = EncounterKillPlate(791, 8),
  --     arlokk_wipe    = EncounterWipePlate(791, 8),
  --     jindo_kill     = EncounterKillPlate(792, 9),
  --     jindo_wipe     = EncounterWipePlate(792, 9),
  --     hakkar_kill    = EncounterKillPlate(793, 10),
  --     hakkar_wipe    = EncounterWipePlate(793, 10),
  --   }
  -- },
  -- bossrewards_aq20 = {
  --   type = "group",
  --   name = Encounters:GetInstance(509).name,
  --   order = 25,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     kurinnaxx_kill = EncounterKillPlate(718, 1),
  --     kurinnaxx_wipe = EncounterWipePlate(718, 1),
  --     rajaxx_kill    = EncounterKillPlate(719, 2),
  --     rajaxx_wipe    = EncounterWipePlate(719, 2),
  --     moam_kill      = EncounterKillPlate(720, 3),
  --     moam_wipe      = EncounterWipePlate(720, 3),
  --     buru_kill      = EncounterKillPlate(721, 4),
  --     buru_wipe      = EncounterWipePlate(721, 4),
  --     ayamiss_kill   = EncounterKillPlate(722, 5),
  --     ayamiss_wipe   = EncounterWipePlate(722, 5),
  --     ossirian_kill  = EncounterKillPlate(723, 6),
  --     ossirian_wipe  = EncounterWipePlate(723, 6),
  --   }
  -- },
  -- bossrewards_aq40 = {
  --   type = "group",
  --   name = Encounters:GetInstance(531).name,
  --   order = 26,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     skeram_kill   = EncounterKillPlate(709, 1),
  --     skeram_wipe   = EncounterWipePlate(709, 1),
  --     bugtrio_kill  = EncounterKillPlate(710, 2),
  --     bugtrio_wipe  = EncounterWipePlate(710, 2),
  --     sartura_kill  = EncounterKillPlate(711, 3),
  --     sartura_wipe  = EncounterWipePlate(711, 3),
  --     fankriss_kill = EncounterKillPlate(712, 4),
  --     fankriss_wipe = EncounterWipePlate(712, 4),
  --     viscidus_kill = EncounterKillPlate(713, 5),
  --     viscidus_wipe = EncounterWipePlate(713, 5),
  --     huhuran_kill  = EncounterKillPlate(714, 6),
  --     huhuran_wipe  = EncounterWipePlate(714, 6),
  --     twins_kill    = EncounterKillPlate(715, 7),
  --     twins_wipe    = EncounterWipePlate(715, 7),
  --     ouro_kill     = EncounterKillPlate(716, 8),
  --     ouro_wipe     = EncounterWipePlate(716, 8),
  --     cthun_kill    = EncounterKillPlate(717, 9),
  --     cthun_wipe    = EncounterWipePlate(717, 9),
  --   }
  -- },
  -- bossrewards_naxx = {
  --   type = "group",
  --   name = Encounters:GetInstance(533).name,
  --   order = 27,
  --   set = SetEP,
  --   get = GetEP,
  --   args = {
  --     anub_kill      = EncounterKillPlate(1107, 1),
  --     anub_wipe      = EncounterWipePlate(1107, 1),
  --     faerlina_kill  = EncounterKillPlate(1110, 2),
  --     faerlina_wipe  = EncounterWipePlate(1110, 2),
  --     maexxna_kill   = EncounterKillPlate(1116, 3),
  --     maexxna_wipe   = EncounterWipePlate(1116, 3),
  --     noth_kill      = EncounterKillPlate(1117, 4),
  --     noth_wipe      = EncounterWipePlate(1117, 4),
  --     heigan_kill    = EncounterKillPlate(1112, 5),
  --     heigan_wipe    = EncounterWipePlate(1112, 5),
  --     loatheb_kill   = EncounterKillPlate(1115, 6),
  --     loatheb_wipe   = EncounterWipePlate(1115, 6),
  --     razuvious_kill = EncounterKillPlate(1113, 7),
  --     razuvious_wipe = EncounterWipePlate(1113, 7),
  --     gothik_kill    = EncounterKillPlate(1109, 8),
  --     gothik_wipe    = EncounterWipePlate(1109, 8),
  --     fourhorse_kill = EncounterKillPlate(1121, 9),
  --     fourhorse_wipe = EncounterWipePlate(1121, 9),
  --     patchwerk_kill = EncounterKillPlate(1118, 10),
  --     patchwerk_wipe = EncounterWipePlate(1118, 10),
  --     grobbulus_kill = EncounterKillPlate(1111, 11),
  --     grobbulus_wipe = EncounterWipePlate(1111, 11),
  --     gluth_kill     = EncounterKillPlate(1108, 12),
  --     gluth_wipe     = EncounterWipePlate(1108, 12),
  --     thaddius_kill  = EncounterKillPlate(1120, 13),
  --     thaddius_wipe  = EncounterWipePlate(1120, 13),
  --     sapphiron_kill = EncounterKillPlate(1119, 14),
  --     sapphiron_wipe = EncounterWipePlate(1119, 14),
  --     kelthuzad_kill = EncounterKillPlate(1114, 15),
  --     kelthuzad_wipe = EncounterWipePlate(1114, 15),
  --   }
  -- }
  bossrewards_karazhan = {
    type = "group",
    name = Encounters:GetInstance(532).name,
    order = 30,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(652, 1),
      wipe_1  = EncounterWipePlate(652, 1),
      kill_2  = EncounterKillPlate(653, 2),
      wipe_2  = EncounterWipePlate(653, 2),
      kill_3  = EncounterKillPlate(654, 3),
      wipe_3  = EncounterWipePlate(654, 3),
      kill_4  = EncounterKillPlate(655, 4),
      wipe_4  = EncounterWipePlate(655, 4),
      kill_5  = EncounterKillPlate(656, 5),
      wipe_5  = EncounterWipePlate(656, 5),
      kill_6  = EncounterKillPlate(657, 6),
      wipe_6  = EncounterWipePlate(657, 6),
      kill_7  = EncounterKillPlate(658, 7),
      wipe_7  = EncounterWipePlate(658, 7),
      kill_8  = EncounterKillPlate(659, 8),
      wipe_8  = EncounterWipePlate(659, 8),
      kill_9  = EncounterKillPlate(660, 9),
      wipe_9  = EncounterWipePlate(660, 9),
      kill_10 = EncounterKillPlate(661, 10),
      wipe_10 = EncounterWipePlate(661, 10),
      kill_11 = EncounterKillPlate(662, 11),
      wipe_11 = EncounterWipePlate(662, 11),
    }
  },
  bossrewards_magtheridon = {
    type = "group",
    name = Encounters:GetInstance(544).name,
    order = 31,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(651, 1),
      wipe_1  = EncounterWipePlate(651, 1),
    }
  },
  bossrewards_gruul = {
    type = "group",
    name = Encounters:GetInstance(565).name,
    order = 32,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(649, 1),
      wipe_1  = EncounterWipePlate(649, 1),
      kill_2  = EncounterKillPlate(650, 2),
      wipe_2  = EncounterWipePlate(650, 2),
    }
  },
  bossrewards_serpentshrine = {
    type = "group",
    name = Encounters:GetInstance(548).name,
    order = 33,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(623, 1),
      wipe_1  = EncounterWipePlate(623, 1),
      kill_2  = EncounterKillPlate(624, 2),
      wipe_2  = EncounterWipePlate(624, 2),
      kill_3  = EncounterKillPlate(625, 3),
      wipe_3  = EncounterWipePlate(625, 3),
      kill_4  = EncounterKillPlate(626, 4),
      wipe_4  = EncounterWipePlate(626, 4),
      kill_5  = EncounterKillPlate(627, 5),
      wipe_5  = EncounterWipePlate(627, 5),
      kill_6  = EncounterKillPlate(628, 6),
      wipe_6  = EncounterWipePlate(628, 6),
    }
  },
  bossrewards_tempest = {
    type = "group",
    name = Encounters:GetInstance(550).name,
    order = 34,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(730, 1),
      wipe_1  = EncounterWipePlate(730, 1),
      kill_2  = EncounterKillPlate(731, 2),
      wipe_2  = EncounterWipePlate(731, 2),
      kill_3  = EncounterKillPlate(732, 3),
      wipe_3  = EncounterWipePlate(732, 3),
      kill_4  = EncounterKillPlate(733, 4),
      wipe_4  = EncounterWipePlate(733, 4),
    }
  },
  bossrewards_hyjal = {
    type = "group",
    name = Encounters:GetInstance(534).name,
    order = 35,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(618, 1),
      wipe_1  = EncounterWipePlate(618, 1),
      kill_2  = EncounterKillPlate(619, 2),
      wipe_2  = EncounterWipePlate(619, 2),
      kill_3  = EncounterKillPlate(620, 3),
      wipe_3  = EncounterWipePlate(620, 3),
      kill_4  = EncounterKillPlate(621, 4),
      wipe_4  = EncounterWipePlate(621, 4),
      kill_5  = EncounterKillPlate(622, 5),
      wipe_5  = EncounterWipePlate(622, 5),
    }
  },
  bossrewards_black_temple = {
    type = "group",
    name = Encounters:GetInstance(564).name,
    order = 36,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(601, 1),
      wipe_1  = EncounterWipePlate(601, 1),
      kill_2  = EncounterKillPlate(602, 2),
      wipe_2  = EncounterWipePlate(602, 2),
      kill_3  = EncounterKillPlate(603, 3),
      wipe_3  = EncounterWipePlate(603, 3),
      kill_4  = EncounterKillPlate(604, 4),
      wipe_4  = EncounterWipePlate(604, 4),
      kill_5  = EncounterKillPlate(605, 5),
      wipe_5  = EncounterWipePlate(605, 5),
      kill_6  = EncounterKillPlate(606, 6),
      wipe_6  = EncounterWipePlate(606, 6),
      kill_7  = EncounterKillPlate(607, 7),
      wipe_7  = EncounterWipePlate(607, 7),
      kill_8  = EncounterKillPlate(608, 8),
      wipe_8  = EncounterWipePlate(608, 8),
      kill_9  = EncounterKillPlate(609, 9),
      wipe_9  = EncounterWipePlate(609, 9),
    }
  },
  bossrewards_sunwell = {
    type = "group",
    name = Encounters:GetInstance(580).name,
    order = 37,
    set = SetEP,
    get = GetEP,
    args = {
      kill_1  = EncounterKillPlate(724, 1),
      wipe_1  = EncounterWipePlate(724, 1),
      kill_2  = EncounterKillPlate(725, 2),
      wipe_2  = EncounterWipePlate(725, 2),
      kill_3  = EncounterKillPlate(726, 3),
      wipe_3  = EncounterWipePlate(726, 3),
      kill_4  = EncounterKillPlate(727, 4),
      wipe_4  = EncounterWipePlate(727, 4),
      kill_5  = EncounterKillPlate(728, 5),
      wipe_5  = EncounterWipePlate(728, 5),
      kill_6  = EncounterKillPlate(729, 6),
      wipe_6  = EncounterWipePlate(729, 6),
    }
  },
}

local function dbmCallback(event, mod)
  Debug("dbmCallback: %s %s", event, mod.combatInfo.name)
  EncounterAttempt(event, mod.combatInfo.name, mod.combatInfo.eId)
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
  local e = Encounters:GetEncounter(id_ or 0)
  local name = e and e.name or _G.UNKNOWNOBJECT
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
