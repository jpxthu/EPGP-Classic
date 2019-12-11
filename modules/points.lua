local mod = EPGP:NewModule("points")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LB = LibStub("LibBabble-Inventory-3.0"):GetLookupTable();

local localName = {}
localName.Bow      = LB["Bow"]
localName.Gun      = LB["Gun"]
localName.Crossbow = LB["Crossbow"]
localName.Thrown   = LB["Thrown"]
localName.Wand     = LB["Wand"]
localName.Idol     = LB["Idol"]
localName.Libram   = LB["Libram"]
localName.Totem    = LB["Totem"]
localName.OneHWeapon  = L["%s %s"]:format(_G.INVTYPE_WEAPON, _G.WEAPON)
localName.TwoHWeapon  = L["%s %s"]:format(_G.INVTYPE_2HWEAPON, _G.WEAPON)
localName.MainHWeapon = L["%s %s"]:format(_G.INVTYPE_WEAPONMAINHAND, _G.WEAPON)
localName.OffHWeapon  = L["%s %s"]:format(_G.INVTYPE_WEAPONOFFHAND, _G.WEAPON)

local switchSlot = {
  ["INVTYPE_HEAD"]            = "head",
  ["INVTYPE_NECK"]            = "neck",
  ["INVTYPE_SHOULDER"]        = "shoulder",
  -- ["INVTYPE_BODY"]            = "body",
  ["INVTYPE_CHEST"]           = "chest",
  ["INVTYPE_ROBE"]            = "chest",
  ["INVTYPE_WAIST"]           = "waist",
  ["INVTYPE_LEGS"]            = "legs",
  ["INVTYPE_FEET"]            = "feet",
  ["INVTYPE_WRIST"]           = "wrist",
  ["INVTYPE_HAND"]            = "hand",
  ["INVTYPE_FINGER"]          = "finger",
  ["INVTYPE_TRINKET"]         = "trinket",
  ["INVTYPE_CLOAK"]           = "cloak",
  ["INVTYPE_WEAPON"]          = "weapon",
  ["INVTYPE_SHIELD"]          = "shield",
  ["INVTYPE_2HWEAPON"]        = "weapon2H",
  ["INVTYPE_WEAPONMAINHAND"]  = "weaponMainH",
  ["INVTYPE_WEAPONOFFHAND"]   = "weaponOffH",
  ["INVTYPE_HOLDABLE"]        = "holdable",
  ["INVTYPE_RANGED"]          = "ranged", -- bow only
  -- ["INVTYPE_RANGEDRIGHT"]     = "ranged", -- gun, cross-bow, wand
  ["INVTYPE_THROWN"]          = "ranged",
  ["INVTYPE_RELIC"]           = "relic",
  -- ["INVTYPE_BAG"]             = "bag",
}

local profileDefault = {
  enabled = true,

  baseGP = 1000,
  standardIlvl = 66,
  ilvlDenominator = 10,

  headScale1 = 1,
  headComment1 = _G.INVTYPE_HEAD,

  neckScale1 = 0.56,
  neckComment1 = _G.INVTYPE_NECK,

  shoulderScale1 = 0.75,
  shoulderComment1 = _G.INVTYPE_SHOULDER,

  -- bodyScale1 = 0,
  -- bodyComment1 = _G.INVTYPE_BODY,

  chestScale1 = 1,
  chestComment1 = _G.INVTYPE_CHEST,

  waistScale1 = 0.75,
  waistComment1 = _G.INVTYPE_WAIST,

  legsScale1 = 1,
  legsComment1 = _G.INVTYPE_LEGS,

  feetScale1 = 0.75,
  feetComment1 = _G.INVTYPE_FEET,

  wristScale1 = 0.56,
  wristComment1 = _G.INVTYPE_WRIST,

  handScale1 = 0.75,
  handComment1 = _G.INVTYPE_HAND,

  fingerScale1 = 0.56,
  fingerComment1 = _G.INVTYPE_FINGER,

  trinketScale1 = 1.25,
  trinketComment1 = _G.INVTYPE_TRINKET,

  cloakScale1 = 0.56,
  cloakComment1 = _G.INVTYPE_CLOAK,

  weaponScale1 = 1.5,
  weaponComment1 = localName.MainHWeapon,
  weaponScale2 = 0.5,
  weaponComment2 = localName.OffHWeapon .. " / " .. L["%s %s"]:format(L["Tank"], localName.MainHWeapon),
  weaponScale3 = 0.25,
  weaponComment3 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  shieldScale1 = 1.5,
  shieldComment1 = L["%s %s"]:format(L["Tank"], _G.SHIELDSLOT),
  shieldScale2 = 0.5,
  shieldComment2 = L["%s %s"]:format(L["Non-tank"], _G.SHIELDSLOT),

  weapon2HScale1 = 2,
  weapon2HComment1 = localName.TwoHWeapon,
  weapon2HScale2 = 0.5,
  weapon2HComment2 = L["%s %s"]:format(LB["Hunter"], localName.TwoHWeapon),

  weaponMainHScale1 = 1.5,
  weaponMainHComment1 = localName.MainHWeapon,
  weaponMainHScale2 = 0.25,
  weaponMainHComment2 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  weaponOffHScale1 = 0.5,
  weaponOffHComment1 = localName.OffHWeapon,
  weaponOffHScale2 = 0.25,
  weaponOffHComment2 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  holdableScale1 = 0.5,
  holdableComment1 = _G.INVTYPE_HOLDABLE,

  rangedScale1 = 2,
  rangedComment1 = L["%s %s"]:format(LB["Hunter"], _G.INVTYPE_RANGED),
  rangedScale2 = 0.5,
  rangedComment2 = L["%s %s"]:format(L["Non-hunter"], _G.INVTYPE_RANGED),

  wandScale1 = 0.5,
  wandComment1 = localName.Wand,

  thrownScale1 = 0.5,
  thrownComment1 = localName.Thrown,

  relicScale1 = 0.667,
  relicComment1 = _G.INVTYPE_RELIC,

  -- bagScale1 = 0,
  -- bagComment1 = _G.INVTYPE_BAG,
}

mod.dbDefaults = {
  profile = profileDefault
}

local switchRanged = {}
local function SwitchRangedInit()
  switchRanged[localName.Bow]      = "ranged"
  switchRanged[localName.Gun]      = "ranged"
  switchRanged[localName.Crossbow] = "ranged"
  switchRanged[localName.Wand]     = "wand"
  -- switchRanged["LE_ITEM_WEAPON_THROWN"]   = "thrown"
end

local initialized = false

local function LocalNameSetOne(slot, id)
  local v = select(7, GetItemInfo(id))
  if v then
    slot = v
    return true
  end
  return false
end

local function LocalNameInit()
  if initialized then return true end
  if not(LocalNameSetOne(localName.Bow,      17069)) then return false end -- 弓
  if not(LocalNameSetOne(localName.Gun,      17072)) then return false end -- 枪
  if not(LocalNameSetOne(localName.Crossbow, 19361)) then return false end -- 弩
  if not(LocalNameSetOne(localName.Thrown,   13173)) then return false end -- 投掷
  if not(LocalNameSetOne(localName.Wand,     17077)) then return false end -- 魔杖
  if not(LocalNameSetOne(localName.Idol,     23198)) then return false end -- 神像
  if not(LocalNameSetOne(localName.Libram,   23201)) then return false end -- 圣契
  if not(LocalNameSetOne(localName.Totem,    23200)) then return false end -- 图腾
  initialized = true
  SwitchRangedInit()
  return true
end

function mod:GetScale(slot, subClass)
  if not LocalNameInit() or not self.db then
    return nil, nil, nil, nil, nil, nil, nil, nil, nil
  end
  local name = switchSlot[slot] or switchRanged[subClass]
  if name then
    return self.db.profile[name .. "Scale1"], self.db.profile[name .. "Comment1"],
           self.db.profile[name .. "Scale2"], self.db.profile[name .. "Comment2"],
           self.db.profile[name .. "Scale3"], self.db.profile[name .. "Comment3"],
           self.db.profile.baseGP,
           self.db.profile.standardIlvl,
           self.db.profile.ilvlDenominator
  else
    return nil, nil, nil, nil, nil, nil,
           self.db.profile.baseGP,
           self.db.profile.standardIlvl,
           self.db.profile.ilvlDenominator
  end
end

local function HelpPlate(desc)
  help = {
    order = 1,
    type = "description",
    name = desc,
    fontSize = "medium",
  }
  return help
end

local function ScalePlate(index)
  scalePlate = {
    name = L["Multiplier %d"]:format(index),
    type = "range",
    min = 0,
    max = 5,
    step = 0.01,
    order = index * 2,
  }
  return scalePlate
end

local function CommentPlate(index)
  local s = L["Comment %d"]:format(index)
  commentPlate = {
    name = s,
    desc = s,
    type = "input",
    order = index * 2 + 1,
  }
  return commentPlate
end

mod.optionsName = L["Gear Points"]
mod.optionsDesc = L["Gear Points"]
mod.optionsArgs = {
  help = HelpPlate(L["Set gear points (GP multiplier). Each slot could set up to 3 points. Each points has a custom comment."]),
  headerEquation = {
    order = 10,
    type = "header",
    name = L["Equation"],
  },
  equation = {
    order = 11,
    type = "group",
    inline = true,
    name = "",
    args = {
      equationHelp = HelpPlate("GP = base_gp * 2 ^ [(level - standard_ilvl) / ilvl_denominator] * slot_scale"),
      baseGP = {
        order = 2,
        type = "range",
        name = "base_gp",
        min = 1,
        max = 10000,
        step = 0.01,
      },
      standardIlvl = {
        order = 3,
        type = "range",
        name = "standard_ilvl",
        min = 0,
        max = 1000,
        step = 0.01,
      },
      ilvlDenominator = {
        order = 4,
        type = "range",
        name = "ilvl_denominator",
        min = 1,
        max = 100,
        step = 0.01,
      },
    },
  },

  headerSlots = {
    order = 20,
    type = "header",
    name = L["Slots"],
  },
  head = {
    order = 21,
    type = "group",
    name = _G.INVTYPE_HEAD,
    args = {
      help = HelpPlate(_G.INVTYPE_HEAD),
      headScale1 = ScalePlate(1),
      headComment1 = CommentPlate(1),
      headScale2 = ScalePlate(2),
      headComment2 = CommentPlate(2),
      headScale3 = ScalePlate(3),
      headComment3 = CommentPlate(3),
    },
  },
  neck = {
    order = 22,
    type = "group",
    name = _G.INVTYPE_NECK,
    args = {
      help = HelpPlate(_G.INVTYPE_NECK),
      neckScale1 = ScalePlate(1),
      neckComment1 = CommentPlate(1),
      neckScale2 = ScalePlate(2),
      neckComment2 = CommentPlate(2),
      neckScale3 = ScalePlate(3),
      neckComment3 = CommentPlate(3),
    },
  },
  shoulder = {
    order = 23,
    type = "group",
    name = _G.INVTYPE_SHOULDER,
    args = {
      help = HelpPlate(_G.INVTYPE_SHOULDER),
      shoulderScale1 = ScalePlate(1),
      shoulderComment1 = CommentPlate(1),
      shoulderScale2 = ScalePlate(2),
      shoulderComment2 = CommentPlate(2),
      shoulderScale3 = ScalePlate(3),
      shoulderComment3 = CommentPlate(3),
    },
  },
  -- body = {
  --   order = 24,
  --   type = "group",
  --   name = _G.INVTYPE_BODY, -- Shirt
  --   args = {
  --     help = HelpPlate(_G.INVTYPE_BODY),
  --     bodyScale1 = ScalePlate(1),
  --     bodyComment1 = CommentPlate(1),
  --     bodyScale2 = ScalePlate(2),
  --     bodyComment2 = CommentPlate(2),
  --     bodyScale3 = ScalePlate(3),
  --     bodyComment3 = CommentPlate(3),
  --   },
  -- },
  chest = {
    order = 25,
    type = "group",
    name = _G.INVTYPE_CHEST, -- also _G.INVTYPE_ROBE
    args = {
      help = HelpPlate(_G.INVTYPE_CHEST),
      chestScale1 = ScalePlate(1),
      chestComment1 = CommentPlate(1),
      chestScale2 = ScalePlate(2),
      chestComment2 = CommentPlate(2),
      chestScale3 = ScalePlate(3),
      chestComment3 = CommentPlate(3),
    },
  },
  waist = {
    order = 26,
    type = "group",
    name = _G.INVTYPE_WAIST,
    args = {
      help = HelpPlate(_G.INVTYPE_WAIST),
      waistScale1 = ScalePlate(1),
      waistComment1 = CommentPlate(1),
      waistScale2 = ScalePlate(2),
      waistComment2 = CommentPlate(2),
      waistScale3 = ScalePlate(3),
      waistComment3 = CommentPlate(3),
    },
  },
  legs = {
    order = 27,
    type = "group",
    name = _G.INVTYPE_LEGS,
    args = {
      help = HelpPlate(_G.INVTYPE_LEGS),
      legsScale1 = ScalePlate(1),
      legsComment1 = CommentPlate(1),
      legsScale2 = ScalePlate(2),
      legsComment2 = CommentPlate(2),
      legsScale3 = ScalePlate(3),
      legsComment3 = CommentPlate(3),
    },
  },
  feet = {
    order = 28,
    type = "group",
    name = _G.INVTYPE_FEET,
    args = {
      help = HelpPlate(_G.INVTYPE_FEET),
      feetScale1 = ScalePlate(1),
      feetComment1 = CommentPlate(1),
      feetScale2 = ScalePlate(2),
      feetComment2 = CommentPlate(2),
      feetScale3 = ScalePlate(3),
      feetComment3 = CommentPlate(3),
    },
  },
  wrist = {
    order = 29,
    type = "group",
    name = _G.INVTYPE_WRIST,
    args = {
      help = HelpPlate(_G.INVTYPE_WRIST),
      wristScale1 = ScalePlate(1),
      wristComment1 = CommentPlate(1),
      wristScale2 = ScalePlate(2),
      wristComment2 = CommentPlate(2),
      wristScale3 = ScalePlate(3),
      wristComment3 = CommentPlate(3),
    },
  },
  hand = {
    order = 30,
    type = "group",
    name = _G.INVTYPE_HAND,
    args = {
      help = HelpPlate(_G.INVTYPE_HAND),
      handScale1 = ScalePlate(1),
      handComment1 = CommentPlate(1),
      handScale2 = ScalePlate(2),
      handComment2 = CommentPlate(2),
      handScale3 = ScalePlate(3),
      handComment3 = CommentPlate(3),
    },
  },
  finger = {
    order = 31,
    type = "group",
    name = _G.INVTYPE_FINGER,
    args = {
      help = HelpPlate(_G.INVTYPE_FINGER),
      fingerScale1 = ScalePlate(1),
      fingerComment1 = CommentPlate(1),
      fingerScale2 = ScalePlate(2),
      fingerComment2 = CommentPlate(2),
      fingerScale3 = ScalePlate(3),
      fingerComment3 = CommentPlate(3),
    },
  },
  trinket = {
    order = 32,
    type = "group",
    name = _G.INVTYPE_TRINKET,
    args = {
      help = HelpPlate(_G.INVTYPE_TRINKET),
      trinketScale1 = ScalePlate(1),
      trinketComment1 = CommentPlate(1),
      trinketScale2 = ScalePlate(2),
      trinketComment2 = CommentPlate(2),
      trinketScale3 = ScalePlate(3),
      trinketComment3 = CommentPlate(3),
    },
  },
  cloak = {
    order = 33,
    type = "group",
    name = _G.INVTYPE_CLOAK,
    args = {
      help = HelpPlate(_G.INVTYPE_CLOAK),
      cloakScale1 = ScalePlate(1),
      cloakComment1 = CommentPlate(1),
      cloakScale2 = ScalePlate(2),
      cloakComment2 = CommentPlate(2),
      cloakScale3 = ScalePlate(3),
      cloakComment3 = CommentPlate(3),
    },
  },
  shield = {
    order = 34,
    type = "group",
    name = _G.SHIELDSLOT,
    args = {
      help = HelpPlate(_G.SHIELDSLOT),
      shieldScale1 = ScalePlate(1),
      shieldComment1 = CommentPlate(1),
      shieldScale2 = ScalePlate(2),
      shieldComment2 = CommentPlate(2),
      shieldScale3 = ScalePlate(3),
      shieldComment3 = CommentPlate(3),
    },
  },
  weapon = {
    order = 35,
    type = "group",
    name = localName.OneHWeapon, -- one-handed weapon
    args = {
      help = HelpPlate(localName.OneHWeapon),
      weaponScale1 = ScalePlate(1),
      weaponComment1 = CommentPlate(1),
      weaponScale2 = ScalePlate(2),
      weaponComment2 = CommentPlate(2),
      weaponScale3 = ScalePlate(3),
      weaponComment3 = CommentPlate(3),
    },
  },
  weapon2H = {
    order = 36,
    type = "group",
    name = localName.TwoHWeapon,
    args = {
      help = HelpPlate(localName.TwoHWeapon),
      weapon2HScale1 = ScalePlate(1),
      weapon2HComment1 = CommentPlate(1),
      weapon2HScale2 = ScalePlate(2),
      weapon2HComment2 = CommentPlate(2),
      weapon2HScale3 = ScalePlate(3),
      weapon2HComment3 = CommentPlate(3),
    },
  },
  weaponMainH = {
    order = 37,
    type = "group",
    name = localName.MainHWeapon,
    args = {
      help = HelpPlate(localName.MainHWeapon),
      weaponMainHScale1 = ScalePlate(1),
      weaponMainHComment1 = CommentPlate(1),
      weaponMainHScale2 = ScalePlate(2),
      weaponMainHComment2 = CommentPlate(2),
      weaponMainHScale3 = ScalePlate(3),
      weaponMainHComment3 = CommentPlate(3),
    },
  },
  weaponOffH = {
    order = 38,
    type = "group",
    name = localName.OffHWeapon,
    args = {
      help = HelpPlate(localName.OffHWeapon),
      weaponOffHScale1 = ScalePlate(1),
      weaponOffHComment1 = CommentPlate(1),
      weaponOffHScale2 = ScalePlate(2),
      weaponOffHComment2 = CommentPlate(2),
      weaponOffHScale3 = ScalePlate(3),
      weaponOffHComment3 = CommentPlate(3),
    },
  },
  holdable = {
    order = 39,
    type = "group",
    name = _G.INVTYPE_HOLDABLE, -- Held in Off-Hand
    args = {
      help = HelpPlate(_G.INVTYPE_HOLDABLE),
      holdableScale1 = ScalePlate(1),
      holdableComment1 = CommentPlate(1),
      holdableScale2 = ScalePlate(2),
      holdableComment2 = CommentPlate(2),
      holdableScale3 = ScalePlate(3),
      holdableComment3 = CommentPlate(3),
    },
  },
  ranged = {
    order = 40,
    type = "group",
    name = _G.INVTYPE_RANGED,
    args = {
      help = HelpPlate(L["%s, %s, %s"]:format(
          localName.Bow,
          localName.Gun,
          localName.Crossbow)),
      rangedScale1 = ScalePlate(1),
      rangedComment1 = CommentPlate(1),
      rangedScale2 = ScalePlate(2),
      rangedComment2 = CommentPlate(2),
      rangedScale3 = ScalePlate(3),
      rangedComment3 = CommentPlate(3),
    },
  },
  wand = {
    order = 41,
    type = "group",
    name = localName.Wand,
    args = {
      help = HelpPlate(localName.Wand),
      wandScale1 = ScalePlate(1),
      wandComment1 = CommentPlate(1),
      wandScale2 = ScalePlate(2),
      wandComment2 = CommentPlate(2),
      wandScale3 = ScalePlate(3),
      wandComment3 = CommentPlate(3),
    },
  },
  thrown = {
    order = 42,
    type = "group",
    name = localName.Thrown,
    args = {
      help = HelpPlate(localName.Thrown),
      thrownScale1 = ScalePlate(1),
      thrownComment1 = CommentPlate(1),
      thrownScale2 = ScalePlate(2),
      thrownComment2 = CommentPlate(2),
      thrownScale3 = ScalePlate(3),
      thrownComment3 = CommentPlate(3),
    },
  },
  relic = {
    order = 43,
    type = "group",
    name = _G.INVTYPE_RELIC,
    args = {
      help = HelpPlate(L["%s, %s, %s"]:format(
          localName.Idol,   -- 神像
          localName.Libram, -- 圣契
          localName.Totem)),-- 图腾
      relicScale1 = ScalePlate(1),
      relicComment1 = CommentPlate(1),
      relicScale2 = ScalePlate(2),
      relicComment2 = CommentPlate(2),
      relicScale3 = ScalePlate(3),
      relicComment3 = CommentPlate(3),
    },
  },
  -- bag = {
  --   order = 100,
  --   type = "group",
  --   name = _G.INVTYPE_BAG,
  --   args = {
  --     help = HelpPlate(_G.INVTYPE_BAG),
  --     bagScale1 = ScalePlate(1),
  --     bagComment1 = CommentPlate(1),
  --     bagScale2 = ScalePlate(2),
  --     bagComment2 = CommentPlate(2),
  --     bagScale3 = ScalePlate(3),
  --     bagComment3 = CommentPlate(3),
  --   },
  -- },
  -- Not available in WOW Classic v1.13
  -- customMultislotTier = {
  --   type = "group",
  --   name = _G.INVTYPE_CUSTOM_MULTISLOT_TIER,
  --   args = {
  --     help = HelpPlate(_G.INVTYPE_CUSTOM_MULTISLOT_TIER),
  --     customMultislotTierScale1 = ScalePlate(1),
  --     customMultislotTierComment1 = CommentPlate(1),
  --     customMultislotTierScale2 = ScalePlate(2),
  --     customMultislotTierComment2 = CommentPlate(2),
  --     customMultislotTierScale3 = ScalePlate(3),
  --     customMultislotTierComment3 = CommentPlate(3),
  --   },
  -- },
}

local profileOOR = {
  enabled = true,

  baseGP = 80,
  standardIlvl = 66,
  ilvlDenominator = 10,

  headScale1 = 1,
  headComment1 = _G.INVTYPE_HEAD,

  neckScale1 = 1,
  neckComment1 = _G.INVTYPE_NECK,

  shoulderScale1 = 1,
  shoulderComment1 = _G.INVTYPE_SHOULDER,

  -- bodyScale1 = 0,
  -- bodyComment1 = _G.INVTYPE_BODY,

  chestScale1 = 1,
  chestComment1 = _G.INVTYPE_CHEST,

  waistScale1 = 1,
  waistComment1 = _G.INVTYPE_WAIST,

  legsScale1 = 1,
  legsComment1 = _G.INVTYPE_LEGS,

  feetScale1 = 1,
  feetComment1 = _G.INVTYPE_FEET,

  wristScale1 = 1,
  wristComment1 = _G.INVTYPE_WRIST,

  handScale1 = 1,
  handComment1 = _G.INVTYPE_HAND,

  fingerScale1 = 1,
  fingerComment1 = _G.INVTYPE_FINGER,

  trinketScale1 = 1.5,
  trinketComment1 = _G.INVTYPE_TRINKET,

  cloakScale1 = 1,
  cloakComment1 = _G.INVTYPE_CLOAK,

  weaponScale1 = 1.5,
  weaponComment1 = localName.MainHWeapon,
  weaponScale2 = 0.5,
  weaponComment2 = localName.OffHWeapon,
  weaponScale3 = 0.15,
  weaponComment3 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  shieldScale1 = 0.5,
  shieldComment1 = _G.SHIELDSLOT,

  weapon2HScale1 = 2,
  weapon2HComment1 = localName.TwoHWeapon,
  weapon2HScale2 = 0.3,
  weapon2HComment2 = L["%s %s"]:format(LB["Hunter"], localName.TwoHWeapon),

  weaponMainHScale1 = 1.5,
  weaponMainHComment1 = localName.MainHWeapon,
  weaponMainHScale2 = 0.15,
  weaponMainHComment2 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  weaponOffHScale1 = 0.5,
  weaponOffHComment1 = localName.OffHWeapon,
  weaponOffHScale2 = 0.15,
  weaponOffHComment2 = L["%s %s"]:format(LB["Hunter"], localName.OneHWeapon),

  holdableScale1 = 0.5,
  holdableComment1 = _G.INVTYPE_HOLDABLE,

  rangedScale1 = 2,
  rangedComment1 = L["%s %s"]:format(LB["Hunter"], _G.INVTYPE_RANGED),
  rangedScale2 = 0.3,
  rangedComment2 = L["%s %s"]:format(L["Non-hunter"], _G.INVTYPE_RANGED),

  wandScale1 = 0.3,
  wandComment1 = localName.Wand,

  thrownScale1 = 0.3,
  thrownComment1 = localName.Thrown,

  relicScale1 = 0.3,
  relicComment1 = _G.INVTYPE_RELIC,

  -- bagScale1 = 0,
  -- bagComment1 = _G.INVTYPE_BAG,
}

function mod:CheckGuildConfig(guild, realm)
  if guild == "Order Of Rhonin" and realm == "艾隆纳亚" then
    mod.db.profile = profileOOR
  end
end

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("points", mod.dbDefaults)
end