local mod = EPGP:NewModule("points")
local GP = LibStub("LibGearPoints-1.3")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LN = LibStub("LibLocalConstant-1.0")
local LOor = LibStub("LibEpgpOorProfile-1.0")
local Utils = LibStub("LibUtils-1.0")

local LOCAL_NAME = LN:LocalName()

local DISPLAY_NAME = {}
DISPLAY_NAME.OneHWeapon  = L["%s %s"]:format(_G.INVTYPE_WEAPON, _G.WEAPON)
DISPLAY_NAME.TwoHWeapon  = L["%s %s"]:format(_G.INVTYPE_2HWEAPON, _G.WEAPON)
DISPLAY_NAME.MainHWeapon = L["%s %s"]:format(_G.INVTYPE_WEAPONMAINHAND, _G.WEAPON)
DISPLAY_NAME.OffHWeapon  = L["%s %s"]:format(_G.INVTYPE_WEAPONOFFHAND, _G.WEAPON)

local profileDefault = {
  enabled = true,

  baseGP = 1000,
  standardIlvl = 66,
  ilvlDenominator = 10,
  legendaryScale = 3,

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
  weaponComment1 = DISPLAY_NAME.MainHWeapon,
  weaponScale2 = 0.5,
  weaponComment2 = DISPLAY_NAME.OffHWeapon .. " / " .. L["%s %s"]:format(_G.TANK, DISPLAY_NAME.MainHWeapon),
  weaponScale3 = 0.25,
  weaponComment3 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

  shieldScale1 = 1.5,
  shieldComment1 = L["%s %s"]:format(_G.TANK, _G.SHIELDSLOT),
  shieldScale2 = 0.5,
  shieldComment2 = L["%s %s"]:format(L["Non-tank"], _G.SHIELDSLOT),

  weapon2HScale1 = 2,
  weapon2HComment1 = DISPLAY_NAME.TwoHWeapon,
  weapon2HScale2 = 0.5,
  weapon2HComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.TwoHWeapon),

  weaponMainHScale1 = 1.5,
  weaponMainHComment1 = DISPLAY_NAME.MainHWeapon,
  weaponMainHScale2 = 0.25,
  weaponMainHComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

  weaponOffHScale1 = 0.5,
  weaponOffHComment1 = DISPLAY_NAME.OffHWeapon,
  weaponOffHScale2 = 0.25,
  weaponOffHComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

  holdableScale1 = 0.5,
  holdableComment1 = _G.INVTYPE_HOLDABLE,

  rangedScale1 = 2,
  rangedComment1 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, _G.INVTYPE_RANGED),
  rangedScale2 = 0.5,
  rangedComment2 = L["%s %s"]:format(L["Non-hunter"], _G.INVTYPE_RANGED),

  wandScale1 = 0.5,
  wandComment1 = LOCAL_NAME.Wand,

  thrownScale1 = 0.5,
  thrownComment1 = LOCAL_NAME.Thrown,

  relicScale1 = 0.667,
  relicComment1 = _G.INVTYPE_RELIC,

  -- bagScale1 = 0,
  -- bagComment1 = _G.INVTYPE_BAG,
}

mod.dbDefaults = {
  profile = profileDefault
}

local function HelpPlate(desc, order)
  help = {
    order = order or 1,
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

local function RecommendParamsString()
  local s = ""
  local standardIlvl, _, _, ilvlDenominator = GP:GetRecommendIlvlParams()

  if standardIlvl then
    s = s .. string.format("standard_ilvl = %d  ", standardIlvl)
  end

  if standardIlvl then
    s = s .. string.format("ilvl_denominator = %d", ilvlDenominator)
  end

  if s ~= "" then
    s = L["Recommend value in current tier:"] .. "\n" .. s
  end

  return s
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
      legendaryScale = {
        order = 5,
        type = "range",
        name = L["Legendary Scale"],
        min = 1,
        max = 10,
        step = 0.01,
      },
      recommend = HelpPlate(RecommendParamsString(), 6)
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
    name = DISPLAY_NAME.OneHWeapon, -- one-handed weapon
    args = {
      help = HelpPlate(DISPLAY_NAME.OneHWeapon),
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
    name = DISPLAY_NAME.TwoHWeapon,
    args = {
      help = HelpPlate(DISPLAY_NAME.TwoHWeapon),
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
    name = DISPLAY_NAME.MainHWeapon,
    args = {
      help = HelpPlate(DISPLAY_NAME.MainHWeapon),
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
    name = DISPLAY_NAME.OffHWeapon,
    args = {
      help = HelpPlate(DISPLAY_NAME.OffHWeapon),
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
          LOCAL_NAME.Bow,
          LOCAL_NAME.Gun,
          LOCAL_NAME.Crossbow)),
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
    name = LOCAL_NAME.Wand,
    args = {
      help = HelpPlate(LOCAL_NAME.Wand),
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
    name = LOCAL_NAME.Thrown,
    args = {
      help = HelpPlate(LOCAL_NAME.Thrown),
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
          LOCAL_NAME.Idol,   -- 神像
          LOCAL_NAME.Libram, -- 圣契
          LOCAL_NAME.Totem)),-- 图腾
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

function mod:CheckGuildConfig(guild, realm)
  if (guild == "Order Of Rhonin" or guild == "EPGP test") and realm == "艾隆纳亚" then
    Utils:CopyTable(LOor:GetPointsProfile(L, DISPLAY_NAME, LOCAL_NAME), mod.db.profile)
  end
end

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("points", mod.dbDefaults)
end
