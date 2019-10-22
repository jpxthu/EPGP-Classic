-- A library to compute Gear Points for items as described in
-- http://code.google.com/p/epgp/wiki/GearPoints

local MAJOR_VERSION = "LibGearPoints-1.2"
local MINOR_VERSION = 10200

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local Debug = LibStub("LibDebug-1.0")
local ItemUtils = LibStub("LibItemUtils-1.0")

-- This is the high price equipslot multiplier.
-- Values adjusted to be proportional to the amount of stats provided by each slot in Legion
local EQUIPSLOT_MULTIPLIER_1 = {
  INVTYPE_HEAD = 1,
  INVTYPE_CHEST = 1,
  INVTYPE_ROBE = 1,
  INVTYPE_LEGS = 1,
  INVTYPE_WRIST = 0.56,
  INVTYPE_FINGER = 0.56,
  INVTYPE_CLOAK = 0.56,
  INVTYPE_NECK = 0.56,
  INVTYPE_SHOULDER = 0.75,
  INVTYPE_WAIST = 0.75,
  INVTYPE_FEET = 0.75,
  INVTYPE_HAND = 0.75,
  INVTYPE_TRINKET = 1.25,
  INVTYPE_RELIC = 0.667,

  -- The below are not relevant for Legion items, only for old
  INVTYPE_WEAPON = 1.5,
  INVTYPE_SHIELD = 1.5,
  INVTYPE_2HWEAPON = 2,
  INVTYPE_WEAPONMAINHAND = 1.5,
  INVTYPE_WEAPONOFFHAND = 0.5,
  INVTYPE_HOLDABLE = 0.5,
  INVTYPE_RANGED = 2.0,
  INVTYPE_RANGEDRIGHT = 2.0,
  INVTYPE_THROWN = 0.5,

  -- Hack for Tier 9 25M heroic tokens.
  INVTYPE_CUSTOM_MULTISLOT_TIER = 0.9,
}

-- Note: The second multiplier is not really used in Legion

-- This is the low price equipslot multiplier (off hand weapons, non
-- tanking shields).
local EQUIPSLOT_MULTIPLIER_2 = {
  INVTYPE_WEAPON = 0.5,
  INVTYPE_2HWEAPON = 0.5,
  INVTYPE_SHIELD = 0.5,
  INVTYPE_RANGEDRIGHT = 1.5
}

--Used to display GP values directly on tier tokens; keys are itemIDs,
--values are rarity, ilvl, inventory slot, and an optional boolean
--value indicating heroic/mythic ilvl should be derived from the bonus
--list rather than the raw ilvl (mainly for T17+ tier gear)
local CUSTOM_ITEM_DATA = {
  -- Classic
  [18423] = { 4, 74, "INVTYPE_NECK" }, -- Head of Onyxia
  [18646] = { 4, 75, "INVTYPE_2HWEAPON" }, -- The Eye of Divinity
  [18703] = { 4, 75, "INVTYPE_RANGED" }, -- Ancient Petrified Leaf

  -- Tier 4
  [29753] = { 4, 120, "INVTYPE_CHEST" },
  [29754] = { 4, 120, "INVTYPE_CHEST" },
  [29755] = { 4, 120, "INVTYPE_CHEST" },
  [29756] = { 4, 120, "INVTYPE_HAND" },
  [29757] = { 4, 120, "INVTYPE_HAND" },
  [29758] = { 4, 120, "INVTYPE_HAND" },
  [29759] = { 4, 120, "INVTYPE_HEAD" },
  [29760] = { 4, 120, "INVTYPE_HEAD" },
  [29761] = { 4, 120, "INVTYPE_HEAD" },
  [29762] = { 4, 120, "INVTYPE_SHOULDER" },
  [29763] = { 4, 120, "INVTYPE_SHOULDER" },
  [29764] = { 4, 120, "INVTYPE_SHOULDER" },
  [29765] = { 4, 120, "INVTYPE_LEGS" },
  [29766] = { 4, 120, "INVTYPE_LEGS" },
  [29767] = { 4, 120, "INVTYPE_LEGS" },

  -- Tier 5
  [30236] = { 4, 133, "INVTYPE_CHEST" },
  [30237] = { 4, 133, "INVTYPE_CHEST" },
  [30238] = { 4, 133, "INVTYPE_CHEST" },
  [30239] = { 4, 133, "INVTYPE_HAND" },
  [30240] = { 4, 133, "INVTYPE_HAND" },
  [30241] = { 4, 133, "INVTYPE_HAND" },
  [30242] = { 4, 133, "INVTYPE_HEAD" },
  [30243] = { 4, 133, "INVTYPE_HEAD" },
  [30244] = { 4, 133, "INVTYPE_HEAD" },
  [30245] = { 4, 133, "INVTYPE_LEGS" },
  [30246] = { 4, 133, "INVTYPE_LEGS" },
  [30247] = { 4, 133, "INVTYPE_LEGS" },
  [30248] = { 4, 133, "INVTYPE_SHOULDER" },
  [30249] = { 4, 133, "INVTYPE_SHOULDER" },
  [30250] = { 4, 133, "INVTYPE_SHOULDER" },

  -- Tier 5 - BoE recipes - BoP crafts
  [30282] = { 4, 128, "INVTYPE_BOOTS" },
  [30283] = { 4, 128, "INVTYPE_BOOTS" },
  [30305] = { 4, 128, "INVTYPE_BOOTS" },
  [30306] = { 4, 128, "INVTYPE_BOOTS" },
  [30307] = { 4, 128, "INVTYPE_BOOTS" },
  [30308] = { 4, 128, "INVTYPE_BOOTS" },
  [30323] = { 4, 128, "INVTYPE_BOOTS" },
  [30324] = { 4, 128, "INVTYPE_BOOTS" },

  -- Tier 6
  [31089] = { 4, 146, "INVTYPE_CHEST" },
  [31090] = { 4, 146, "INVTYPE_CHEST" },
  [31091] = { 4, 146, "INVTYPE_CHEST" },
  [31092] = { 4, 146, "INVTYPE_HAND" },
  [31093] = { 4, 146, "INVTYPE_HAND" },
  [31094] = { 4, 146, "INVTYPE_HAND" },
  [31095] = { 4, 146, "INVTYPE_HEAD" },
  [31096] = { 4, 146, "INVTYPE_HEAD" },
  [31097] = { 4, 146, "INVTYPE_HEAD" },
  [31098] = { 4, 146, "INVTYPE_LEGS" },
  [31099] = { 4, 146, "INVTYPE_LEGS" },
  [31100] = { 4, 146, "INVTYPE_LEGS" },
  [31101] = { 4, 146, "INVTYPE_SHOULDER" },
  [31102] = { 4, 146, "INVTYPE_SHOULDER" },
  [31103] = { 4, 146, "INVTYPE_SHOULDER" },
  [34848] = { 4, 154, "INVTYPE_WRIST" },
  [34851] = { 4, 154, "INVTYPE_WRIST" },
  [34852] = { 4, 154, "INVTYPE_WRIST" },
  [34853] = { 4, 154, "INVTYPE_WAIST" },
  [34854] = { 4, 154, "INVTYPE_WAIST" },
  [34855] = { 4, 154, "INVTYPE_WAIST" },
  [34856] = { 4, 154, "INVTYPE_FEET" },
  [34857] = { 4, 154, "INVTYPE_FEET" },
  [34858] = { 4, 154, "INVTYPE_FEET" },

  -- Tier 6 - BoE recipes - BoP crafts
  [32737] = { 4, 141, "INVTYPE_SHOULDER" },
  [32739] = { 4, 141, "INVTYPE_SHOULDER" },
  [32745] = { 4, 141, "INVTYPE_SHOULDER" },
  [32747] = { 4, 141, "INVTYPE_SHOULDER" },
  [32749] = { 4, 141, "INVTYPE_SHOULDER" },
  [32751] = { 4, 141, "INVTYPE_SHOULDER" },
  [32753] = { 4, 141, "INVTYPE_SHOULDER" },
  [32755] = { 4, 141, "INVTYPE_SHOULDER" },

  -- Magtheridon's Head
  [32385] = { 4, 125, "INVTYPE_FINGER" },
  [32386] = { 4, 125, "INVTYPE_FINGER" },

  -- Kael'thas' Sphere
  [32405] = { 4, 138, "INVTYPE_NECK" },

  -- T7
  [40610] = { 4, 200, "INVTYPE_CHEST" },
  [40611] = { 4, 200, "INVTYPE_CHEST" },
  [40612] = { 4, 200, "INVTYPE_CHEST" },
  [40613] = { 4, 200, "INVTYPE_HAND" },
  [40614] = { 4, 200, "INVTYPE_HAND" },
  [40615] = { 4, 200, "INVTYPE_HAND" },
  [40616] = { 4, 200, "INVTYPE_HEAD" },
  [40617] = { 4, 200, "INVTYPE_HEAD" },
  [40618] = { 4, 200, "INVTYPE_HEAD" },
  [40619] = { 4, 200, "INVTYPE_LEGS" },
  [40620] = { 4, 200, "INVTYPE_LEGS" },
  [40621] = { 4, 200, "INVTYPE_LEGS" },
  [40622] = { 4, 200, "INVTYPE_SHOULDER" },
  [40623] = { 4, 200, "INVTYPE_SHOULDER" },
  [40624] = { 4, 200, "INVTYPE_SHOULDER" },

  -- T7 (heroic)
  [40625] = { 4, 213, "INVTYPE_CHEST" },
  [40626] = { 4, 213, "INVTYPE_CHEST" },
  [40627] = { 4, 213, "INVTYPE_CHEST" },
  [40628] = { 4, 213, "INVTYPE_HAND" },
  [40629] = { 4, 213, "INVTYPE_HAND" },
  [40630] = { 4, 213, "INVTYPE_HAND" },
  [40631] = { 4, 213, "INVTYPE_HEAD" },
  [40632] = { 4, 213, "INVTYPE_HEAD" },
  [40633] = { 4, 213, "INVTYPE_HEAD" },
  [40634] = { 4, 213, "INVTYPE_LEGS" },
  [40635] = { 4, 213, "INVTYPE_LEGS" },
  [40636] = { 4, 213, "INVTYPE_LEGS" },
  [40637] = { 4, 213, "INVTYPE_SHOULDER" },
  [40638] = { 4, 213, "INVTYPE_SHOULDER" },
  [40639] = { 4, 213, "INVTYPE_SHOULDER" },

  -- Key to the Focusing Iris
  [44569] = { 4, 213, "INVTYPE_NECK" },
  [44577] = { 4, 226, "INVTYPE_NECK" },

  -- T8
  [45635] = { 4, 219, "INVTYPE_CHEST" },
  [45636] = { 4, 219, "INVTYPE_CHEST" },
  [45637] = { 4, 219, "INVTYPE_CHEST" },
  [45647] = { 4, 219, "INVTYPE_HEAD" },
  [45648] = { 4, 219, "INVTYPE_HEAD" },
  [45649] = { 4, 219, "INVTYPE_HEAD" },
  [45644] = { 4, 219, "INVTYPE_HAND" },
  [45645] = { 4, 219, "INVTYPE_HAND" },
  [45646] = { 4, 219, "INVTYPE_HAND" },
  [45650] = { 4, 219, "INVTYPE_LEGS" },
  [45651] = { 4, 219, "INVTYPE_LEGS" },
  [45652] = { 4, 219, "INVTYPE_LEGS" },
  [45659] = { 4, 219, "INVTYPE_SHOULDER" },
  [45660] = { 4, 219, "INVTYPE_SHOULDER" },
  [45661] = { 4, 219, "INVTYPE_SHOULDER" },

  -- T8 (heroic)
  [45632] = { 4, 226, "INVTYPE_CHEST" },
  [45633] = { 4, 226, "INVTYPE_CHEST" },
  [45634] = { 4, 226, "INVTYPE_CHEST" },
  [45638] = { 4, 226, "INVTYPE_HEAD" },
  [45639] = { 4, 226, "INVTYPE_HEAD" },
  [45640] = { 4, 226, "INVTYPE_HEAD" },
  [45641] = { 4, 226, "INVTYPE_HAND" },
  [45642] = { 4, 226, "INVTYPE_HAND" },
  [45643] = { 4, 226, "INVTYPE_HAND" },
  [45653] = { 4, 226, "INVTYPE_LEGS" },
  [45654] = { 4, 226, "INVTYPE_LEGS" },
  [45655] = { 4, 226, "INVTYPE_LEGS" },
  [45656] = { 4, 226, "INVTYPE_SHOULDER" },
  [45657] = { 4, 226, "INVTYPE_SHOULDER" },
  [45658] = { 4, 226, "INVTYPE_SHOULDER" },

  -- Reply Code Alpha
  [46052] = { 4, 226, "INVTYPE_RING" },
  [46053] = { 4, 239, "INVTYPE_RING" },

  -- T9.245 (10M heroic/25M)
  [47242] = { 4, 245, "INVTYPE_CUSTOM_MULTISLOT_TIER" },

  -- T9.258 (25M heroic)
  [47557] = { 4, 258, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [47558] = { 4, 258, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [47559] = { 4, 258, "INVTYPE_CUSTOM_MULTISLOT_TIER" },

  -- T10.264 (10M heroic/25M)
  [52025] = { 4, 264, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [52026] = { 4, 264, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [52027] = { 4, 264, "INVTYPE_CUSTOM_MULTISLOT_TIER" },

  -- T10.279 (25M heroic)
  [52028] = { 4, 279, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [52029] = { 4, 279, "INVTYPE_CUSTOM_MULTISLOT_TIER" },
  [52030] = { 4, 279, "INVTYPE_CUSTOM_MULTISLOT_TIER" },

 -- T11
  [63683] = { 4, 359, "INVTYPE_HEAD" },
  [63684] = { 4, 359, "INVTYPE_HEAD" },
  [63682] = { 4, 359, "INVTYPE_HEAD" },
  [64315] = { 4, 359, "INVTYPE_SHOULDER" },
  [64316] = { 4, 359, "INVTYPE_SHOULDER" },
  [64314] = { 4, 359, "INVTYPE_SHOULDER" },

 -- T11 Heroic
  [65001] = { 4, 372, "INVTYPE_HEAD" },
  [65000] = { 4, 372, "INVTYPE_HEAD" },
  [65002] = { 4, 372, "INVTYPE_HEAD" },
  [65088] = { 4, 372, "INVTYPE_SHOULDER" },
  [65087] = { 4, 372, "INVTYPE_SHOULDER" },
  [65089] = { 4, 372, "INVTYPE_SHOULDER" },
  [67424] = { 4, 372, "INVTYPE_CHEST" },
  [67425] = { 4, 372, "INVTYPE_CHEST" },
  [67423] = { 4, 372, "INVTYPE_CHEST" },
  [67426] = { 4, 372, "INVTYPE_LEGS" },
  [67427] = { 4, 372, "INVTYPE_LEGS" },
  [67428] = { 4, 372, "INVTYPE_LEGS" },
  [67431] = { 4, 372, "INVTYPE_HAND" },
  [67430] = { 4, 372, "INVTYPE_HAND" },
  [67429] = { 4, 372, "INVTYPE_HAND" },

 -- T12
  [71674] = { 4, 378, "INVTYPE_SHOULDER" },
  [71688] = { 4, 378, "INVTYPE_SHOULDER" },
  [71681] = { 4, 378, "INVTYPE_SHOULDER" },
  [71668] = { 4, 378, "INVTYPE_HEAD" },
  [71682] = { 4, 378, "INVTYPE_HEAD" },
  [71675] = { 4, 378, "INVTYPE_HEAD" },

 -- T12 Heroic
  [71679] = { 4, 391, "INVTYPE_CHEST" },
  [71686] = { 4, 391, "INVTYPE_CHEST" },
  [71672] = { 4, 391, "INVTYPE_CHEST" },
  [71677] = { 4, 391, "INVTYPE_HEAD" },
  [71684] = { 4, 391, "INVTYPE_HEAD" },
  [71670] = { 4, 391, "INVTYPE_HEAD" },
  [71676] = { 4, 391, "INVTYPE_HAND" },
  [71683] = { 4, 391, "INVTYPE_HAND" },
  [71669] = { 4, 391, "INVTYPE_HAND" },
  [71678] = { 4, 391, "INVTYPE_LEGS" },
  [71685] = { 4, 391, "INVTYPE_LEGS" },
  [71671] = { 4, 391, "INVTYPE_LEGS" },
  [71680] = { 4, 391, "INVTYPE_SHOULDER" },
  [71687] = { 4, 391, "INVTYPE_SHOULDER" },
  [71673] = { 4, 391, "INVTYPE_SHOULDER" },

 -- T12 misc
  [71617] = { 4, 391, "INVTYPE_TRINKET" }, -- crystallized firestone

 -- Other junk that drops; hard to really set a price for, so guilds
 -- will just have to decide on their own.
 -- 69815 -- seething cinder
 -- 71141 -- eternal ember
 -- 69237 -- living ember
 -- 71998 -- essence of destruction

 -- T13 normal
  [78184] = { 4, 397, "INVTYPE_CHEST" },
  [78179] = { 4, 397, "INVTYPE_CHEST" },
  [78174] = { 4, 397, "INVTYPE_CHEST" },
  [78182] = { 4, 397, "INVTYPE_HEAD" },
  [78177] = { 4, 397, "INVTYPE_HEAD" },
  [78172] = { 4, 397, "INVTYPE_HEAD" },
  [78183] = { 4, 397, "INVTYPE_HAND" },
  [78178] = { 4, 397, "INVTYPE_HAND" },
  [78173] = { 4, 397, "INVTYPE_HAND" },
  [78181] = { 4, 397, "INVTYPE_LEGS" },
  [78176] = { 4, 397, "INVTYPE_LEGS" },
  [78171] = { 4, 397, "INVTYPE_LEGS" },
  [78180] = { 4, 397, "INVTYPE_SHOULDER" },
  [78175] = { 4, 397, "INVTYPE_SHOULDER" },
  [78170] = { 4, 397, "INVTYPE_SHOULDER" },

 -- T13 heroic
  [78847] = { 4, 410, "INVTYPE_CHEST" },
  [78848] = { 4, 410, "INVTYPE_CHEST" },
  [78849] = { 4, 410, "INVTYPE_CHEST" },
  [78850] = { 4, 410, "INVTYPE_HEAD" },
  [78851] = { 4, 410, "INVTYPE_HEAD" },
  [78852] = { 4, 410, "INVTYPE_HEAD" },
  [78853] = { 4, 410, "INVTYPE_HAND" },
  [78854] = { 4, 410, "INVTYPE_HAND" },
  [78855] = { 4, 410, "INVTYPE_HAND" },
  [78856] = { 4, 410, "INVTYPE_LEGS" },
  [78857] = { 4, 410, "INVTYPE_LEGS" },
  [78858] = { 4, 410, "INVTYPE_LEGS" },
  [78859] = { 4, 410, "INVTYPE_SHOULDER" },
  [78860] = { 4, 410, "INVTYPE_SHOULDER" },
  [78861] = { 4, 410, "INVTYPE_SHOULDER" },

 -- T14 normal
  [89248] = { 4, 496, "INVTYPE_SHOULDER" },
  [89247] = { 4, 496, "INVTYPE_SHOULDER" },
  [89246] = { 4, 496, "INVTYPE_SHOULDER" },

  [89245] = { 4, 496, "INVTYPE_LEGS" },
  [89244] = { 4, 496, "INVTYPE_LEGS" },
  [89243] = { 4, 496, "INVTYPE_LEGS" },

  [89234] = { 4, 496, "INVTYPE_HEAD" },
  [89236] = { 4, 496, "INVTYPE_HEAD" },
  [89235] = { 4, 496, "INVTYPE_HEAD" },

  [89242] = { 4, 496, "INVTYPE_HAND" },
  [89241] = { 4, 496, "INVTYPE_HAND" },
  [89240] = { 4, 496, "INVTYPE_HAND" },

  [89239] = { 4, 496, "INVTYPE_CHEST" },
  [89238] = { 4, 496, "INVTYPE_CHEST" },
  [89237] = { 4, 496, "INVTYPE_CHEST" },

 -- T14 heroic
  [89261] = { 4, 509, "INVTYPE_SHOULDER" },
  [89263] = { 4, 509, "INVTYPE_SHOULDER" },
  [89262] = { 4, 509, "INVTYPE_SHOULDER" },

  [89252] = { 4, 509, "INVTYPE_LEGS" },
  [89254] = { 4, 509, "INVTYPE_LEGS" },
  [89253] = { 4, 509, "INVTYPE_LEGS" },

  [89258] = { 4, 509, "INVTYPE_HEAD" },
  [89260] = { 4, 509, "INVTYPE_HEAD" },
  [89259] = { 4, 509, "INVTYPE_HEAD" },

  [89255] = { 4, 509, "INVTYPE_HAND" },
  [89257] = { 4, 509, "INVTYPE_HAND" },
  [89256] = { 4, 509, "INVTYPE_HAND" },

  [89249] = { 4, 509, "INVTYPE_CHEST" },
  [89251] = { 4, 509, "INVTYPE_CHEST" },
  [89250] = { 4, 509, "INVTYPE_CHEST" },

  -- T15 normal
  [95573] = { 4, 522, "INVTYPE_SHOULDER" },
  [95583] = { 4, 522, "INVTYPE_SHOULDER" },
  [95578] = { 4, 522, "INVTYPE_SHOULDER" },

  [95572] = { 4, 522, "INVTYPE_LEGS" },
  [95581] = { 4, 522, "INVTYPE_LEGS" },
  [95576] = { 4, 522, "INVTYPE_LEGS" },

  [95571] = { 4, 522, "INVTYPE_HEAD" },
  [95582] = { 4, 522, "INVTYPE_HEAD" },
  [95577] = { 4, 522, "INVTYPE_HEAD" },

  [95570] = { 4, 522, "INVTYPE_HAND" },
  [95580] = { 4, 522, "INVTYPE_HAND" },
  [95575] = { 4, 522, "INVTYPE_HAND" },

  [95569] = { 4, 522, "INVTYPE_CHEST" },
  [95579] = { 4, 522, "INVTYPE_CHEST" },
  [95574] = { 4, 522, "INVTYPE_CHEST" },

  -- T15 heroic
  [96699] = { 4, 535, "INVTYPE_SHOULDER" },
  [96700] = { 4, 535, "INVTYPE_SHOULDER" },
  [96701] = { 4, 535, "INVTYPE_SHOULDER" },

  [96631] = { 4, 535, "INVTYPE_LEGS" },
  [96632] = { 4, 535, "INVTYPE_LEGS" },
  [96633] = { 4, 535, "INVTYPE_LEGS" },

  [96625] = { 4, 535, "INVTYPE_HEAD" },
  [96623] = { 4, 535, "INVTYPE_HEAD" },
  [96624] = { 4, 535, "INVTYPE_HEAD" },

  [96599] = { 4, 535, "INVTYPE_HAND" },
  [96600] = { 4, 535, "INVTYPE_HAND" },
  [96601] = { 4, 535, "INVTYPE_HAND" },

  [96567] = { 4, 535, "INVTYPE_CHEST" },
  [96568] = { 4, 535, "INVTYPE_CHEST" },
  [96566] = { 4, 535, "INVTYPE_CHEST" },

  -- T16 Normal (post-6.0)
  [99754] = { 4, 540, "INVTYPE_SHOULDER" },
  [99755] = { 4, 540, "INVTYPE_SHOULDER" },
  [99756] = { 4, 540, "INVTYPE_SHOULDER" },

  [99751] = { 4, 540, "INVTYPE_LEGS" },
  [99752] = { 4, 540, "INVTYPE_LEGS" },
  [99753] = { 4, 540, "INVTYPE_LEGS" },

  [99748] = { 4, 540, "INVTYPE_HEAD" },
  [99749] = { 4, 540, "INVTYPE_HEAD" },
  [99750] = { 4, 540, "INVTYPE_HEAD" },

  [99745] = { 4, 540, "INVTYPE_HAND" },
  [99746] = { 4, 540, "INVTYPE_HAND" },
  [99747] = { 4, 540, "INVTYPE_HAND" },

  [99742] = { 4, 540, "INVTYPE_CHEST" },
  [99743] = { 4, 540, "INVTYPE_CHEST" },
  [99744] = { 4, 540, "INVTYPE_CHEST" },

  -- T16 Normal Essences (post-6.0)
  [105863] = { 4, 540, "INVTYPE_HEAD" },
  [105865] = { 4, 540, "INVTYPE_HEAD" },
  [105864] = { 4, 540, "INVTYPE_HEAD" },

  -- T16 Heroic (Normal pre-6.0)
  [99685] = { 4, 553, "INVTYPE_SHOULDER" },
  [99695] = { 4, 553, "INVTYPE_SHOULDER" },
  [99690] = { 4, 553, "INVTYPE_SHOULDER" },

  [99684] = { 4, 553, "INVTYPE_LEGS" },
  [99693] = { 4, 553, "INVTYPE_LEGS" },
  [99688] = { 4, 553, "INVTYPE_LEGS" },

  [99683] = { 4, 553, "INVTYPE_HEAD" },
  [99694] = { 4, 553, "INVTYPE_HEAD" },
  [99689] = { 4, 553, "INVTYPE_HEAD" },

  [99682] = { 4, 553, "INVTYPE_HAND" },
  [99692] = { 4, 553, "INVTYPE_HAND" },
  [99687] = { 4, 553, "INVTYPE_HAND" },

  [99696] = { 4, 553, "INVTYPE_CHEST" },
  [99691] = { 4, 553, "INVTYPE_CHEST" },
  [99686] = { 4, 553, "INVTYPE_CHEST" },

  -- T16 Heroic Essences (Normal pre-6.0)
  [105857] = { 4, 553, "INVTYPE_HEAD" },
  [105859] = { 4, 553, "INVTYPE_HEAD" },
  [105858] = { 4, 553, "INVTYPE_HEAD" },

  -- T16 Mythic (Heroic pre-6.0)
  [99717] = { 4, 566, "INVTYPE_SHOULDER" },
  [99719] = { 4, 566, "INVTYPE_SHOULDER" },
  [99718] = { 4, 566, "INVTYPE_SHOULDER" },

  [99726] = { 4, 566, "INVTYPE_LEGS" },
  [99713] = { 4, 566, "INVTYPE_LEGS" },
  [99712] = { 4, 566, "INVTYPE_LEGS" },

  [99723] = { 4, 566, "INVTYPE_HEAD" },
  [99725] = { 4, 566, "INVTYPE_HEAD" },
  [99724] = { 4, 566, "INVTYPE_HEAD" },

  [99720] = { 4, 566, "INVTYPE_HAND" },
  [99722] = { 4, 566, "INVTYPE_HAND" },
  [99721] = { 4, 566, "INVTYPE_HAND" },

  [99714] = { 4, 566, "INVTYPE_CHEST" },
  [99716] = { 4, 566, "INVTYPE_CHEST" },
  [99715] = { 4, 566, "INVTYPE_CHEST" },

  -- T16 Mythic Essences (Heroic pre-6.0)
  [105868] = { 4, 566, "INVTYPE_HEAD" },
  [105867] = { 4, 566, "INVTYPE_HEAD" },
  [105866] = { 4, 566, "INVTYPE_HEAD" },

  -- T17
  -- Item IDs are identical across difficulties, so specify nil for item level
  -- and specify the tier number instead: the raid difficulty and tier number
  -- will be used to get the item level.
  [119309] = { 4, 670, "INVTYPE_SHOULDER", true },
  [119322] = { 4, 670, "INVTYPE_SHOULDER", true },
  [119314] = { 4, 670, "INVTYPE_SHOULDER", true },

  [119307] = { 4, 670, "INVTYPE_LEGS", true },
  [119320] = { 4, 670, "INVTYPE_LEGS", true },
  [119313] = { 4, 670, "INVTYPE_LEGS", true },

  [119308] = { 4, 670, "INVTYPE_HEAD", true },
  [119321] = { 4, 670, "INVTYPE_HEAD", true },
  [119312] = { 4, 670, "INVTYPE_HEAD", true },

  [119306] = { 4, 670, "INVTYPE_HAND", true },
  [119319] = { 4, 670, "INVTYPE_HAND", true },
  [119311] = { 4, 670, "INVTYPE_HAND", true },

  [119305] = { 4, 670, "INVTYPE_CHEST", true },
  [119318] = { 4, 670, "INVTYPE_CHEST", true },
  [119315] = { 4, 670, "INVTYPE_CHEST", true },

  -- T17 essences
  [119310] = { 4, 670, "INVTYPE_HEAD", true },
  [120277] = { 4, 670, "INVTYPE_HEAD", true },
  [119323] = { 4, 670, "INVTYPE_HEAD", true },
  [120279] = { 4, 670, "INVTYPE_HEAD", true },
  [119316] = { 4, 670, "INVTYPE_HEAD", true },
  [120278] = { 4, 670, "INVTYPE_HEAD", true },
  
  -- T18
  [127957] = { 4, 695, "INVTYPE_SHOULDER", true },
  [127967] = { 4, 695, "INVTYPE_SHOULDER", true },
  [127961] = { 4, 695, "INVTYPE_SHOULDER", true },

  [127955] = { 4, 695, "INVTYPE_LEGS", true },
  [127965] = { 4, 695, "INVTYPE_LEGS", true },
  [127960] = { 4, 695, "INVTYPE_LEGS", true },

  [127956] = { 4, 695, "INVTYPE_HEAD", true },
  [127966] = { 4, 695, "INVTYPE_HEAD", true },
  [127959] = { 4, 695, "INVTYPE_HEAD", true },

  [127954] = { 4, 695, "INVTYPE_HAND", true },
  [127964] = { 4, 695, "INVTYPE_HAND", true },
  [127958] = { 4, 695, "INVTYPE_HAND", true },

  [127953] = { 4, 695, "INVTYPE_CHEST", true },
  [127963] = { 4, 695, "INVTYPE_CHEST", true },
  [127962] = { 4, 695, "INVTYPE_CHEST", true },

  -- T18 trinket tokens (note: slightly higher ilvl)
  [127969] = { 4, 705, "INVTYPE_TRINKET", true },
  [127970] = { 4, 705, "INVTYPE_TRINKET", true },
  [127968] = { 4, 705, "INVTYPE_TRINKET", true },

  -- T19 tokens
  [143566] = { 4, 875, "INVTYPE_SHOULDER", true }, -- Conq
  [143570] = { 4, 875, "INVTYPE_SHOULDER", true }, -- Vanq
  [143576] = { 4, 875, "INVTYPE_SHOULDER", true }, -- Prot

  [143564] = { 4, 875, "INVTYPE_LEGS", true },
  [143569] = { 4, 875, "INVTYPE_LEGS", true },
  [143574] = { 4, 875, "INVTYPE_LEGS", true },

  [143565] = { 4, 875, "INVTYPE_HEAD", true },
  [143568] = { 4, 875, "INVTYPE_HEAD", true },
  [143575] = { 4, 875, "INVTYPE_HEAD", true },

  [143563] = { 4, 875, "INVTYPE_HAND", true },
  [143567] = { 4, 875, "INVTYPE_HAND", true },
  [143573] = { 4, 875, "INVTYPE_HAND", true },

  [143562] = { 4, 875, "INVTYPE_CHEST", true },
  [143571] = { 4, 875, "INVTYPE_CHEST", true },
  [143572] = { 4, 875, "INVTYPE_CHEST", true },

  [143577] = { 4, 875, "INVTYPE_CLOAK", true },
  [143578] = { 4, 875, "INVTYPE_CLOAK", true },
  [143579] = { 4, 875, "INVTYPE_CLOAK", true },

  -- T20 tokens
  [147329] = { 4, 900, "INVTYPE_SHOULDER", true }, -- Conq
  [147328] = { 4, 900, "INVTYPE_SHOULDER", true }, -- Vanq
  [147330] = { 4, 900, "INVTYPE_SHOULDER", true }, -- Prot

  [147326] = { 4, 900, "INVTYPE_LEGS", true },
  [147325] = { 4, 900, "INVTYPE_LEGS", true },
  [147327] = { 4, 900, "INVTYPE_LEGS", true },

  [147323] = { 4, 900, "INVTYPE_HEAD", true },
  [147322] = { 4, 900, "INVTYPE_HEAD", true },
  [147324] = { 4, 900, "INVTYPE_HEAD", true },

  [147320] = { 4, 900, "INVTYPE_HAND", true },
  [147319] = { 4, 900, "INVTYPE_HAND", true },
  [147321] = { 4, 900, "INVTYPE_HAND", true },

  [147317] = { 4, 900, "INVTYPE_CHEST", true },
  [147316] = { 4, 900, "INVTYPE_CHEST", true },
  [147318] = { 4, 900, "INVTYPE_CHEST", true },

  [147332] = { 4, 900, "INVTYPE_CLOAK", true },
  [147331] = { 4, 900, "INVTYPE_CLOAK", true },
  [147333] = { 4, 900, "INVTYPE_CLOAK", true },

  -- T21 tokens
  [152515] = { 4, 930, "INVTYPE_CLOAK", true },
  [152516] = { 4, 930, "INVTYPE_CLOAK", true },
  [152517] = { 4, 930, "INVTYPE_CLOAK", true },

  [152518] = { 4, 930, "INVTYPE_CHEST", true },
  [152519] = { 4, 930, "INVTYPE_CHEST", true },
  [152520] = { 4, 930, "INVTYPE_CHEST", true },

  [152521] = { 4, 930, "INVTYPE_HAND", true },
  [152522] = { 4, 930, "INVTYPE_HAND", true },
  [152523] = { 4, 930, "INVTYPE_HAND", true },

  [152524] = { 4, 930, "INVTYPE_HEAD", true },
  [152525] = { 4, 930, "INVTYPE_HEAD", true },
  [152526] = { 4, 930, "INVTYPE_HEAD", true },

  [152527] = { 4, 930, "INVTYPE_LEGS", true },
  [152528] = { 4, 930, "INVTYPE_LEGS", true },
  [152529] = { 4, 930, "INVTYPE_LEGS", true },

  [152530] = { 4, 930, "INVTYPE_SHOULDER", true },
  [152531] = { 4, 930, "INVTYPE_SHOULDER", true },
  [152532] = { 4, 930, "INVTYPE_SHOULDER", true },
}

-- Used to add extra GP if the item contains bonus stats
-- generally considered chargeable. Sockets are very
-- valuable in early BFA.
local ITEM_BONUS_GP = {
  [40]  = 50,  -- avoidance
  [41]  = 50,  -- leech
  [42]  = 50,  -- speed
  [43]  = 0,  -- indestructible, no material value
  [523] = 300, -- extra socket
  [563] = 300, -- extra socket
  [564] = 300, -- extra socket
  [565] = 300, -- extra socket
  [572] = 300, -- extra socket
  [1808] = 300, -- extra socket
}

-- The default quality threshold:
-- 0 - Poor
-- 1 - Uncommon
-- 2 - Common
-- 3 - Rare
-- 4 - Epic
-- 5 - Legendary
-- 6 - Artifact
local quality_threshold = 4

local recent_items_queue = {}
local recent_items_map = {}

local relicSubClass
local function GetRelicSubClassString()
	if not relicSubClass then		-- If not cached obtain 
		local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(140819)		-- ID of some relic
		relicSubClass = itemSubClass
	end

	return relicSubClass
end


-- Given a list of item bonuses, return the ilvl delta it represents
-- (15 for Heroic, 30 for Mythic)
local function GetItemBonusLevelDelta(itemBonuses)
  for _, value in pairs(itemBonuses) do
    -- Item modifiers for heroic are 566 and 570; mythic are 567 and 569
    if value == 566 or value == 570 then return 15 end
    if value == 567 or value == 569 then return 30 end
  end
  return 0
end

local function UpdateRecentLoot(itemLink)
  if recent_items_map[itemLink] then return end

  -- Debug("Adding %s to recent items", itemLink)
  table.insert(recent_items_queue, 1, itemLink)
  recent_items_map[itemLink] = true
  if #recent_items_queue > 15 then
    local itemLink = table.remove(recent_items_queue)
    -- Debug("Removing %s from recent items", itemLink)
    recent_items_map[itemLink] = nil
  end
end

function lib:GetNumRecentItems()
  return #recent_items_queue
end

function lib:GetRecentItemLink(i)
  return recent_items_queue[i]
end

--- Return the currently set quality threshold.
function lib:GetQualityThreshold()
  return quality_threshold
end

--- Set the minimum quality threshold.
-- @param itemQuality Lowest allowed item quality.
function lib:SetQualityThreshold(itemQuality)
  itemQuality = itemQuality and tonumber(itemQuality)
  if not itemQuality or itemQuality > 6 or itemQuality < 0 then
    return error("Usage: SetQualityThreshold(itemQuality): 'itemQuality' - number [0,6].", 3)
  end

  quality_threshold = itemQuality
end

function lib:GetValue(item)
  if not item then return end

  local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(item)
  if not itemLink then return end

  -- Get the item ID to check against known token IDs
  local itemID = itemLink:match("item:(%d+)")
  if not itemID then return end
  itemID = tonumber(itemID)

  -- For now, just use the actual ilvl, not the upgraded cost
  -- level = ItemUtils:GetItemIlevel(item, level)

  -- Check if item is relevant.  Item is automatically relevant if it
  -- is in CUSTOM_ITEM_DATA (as of 6.0, can no longer rely on ilvl alone
  -- for these).
  -- if level < 339 and not CUSTOM_ITEM_DATA[itemID] then
  --   Debug("%s is not relevant.", itemLink)
  --   return nil, nil, level, rarity, equipLoc
  -- end

  -- Get the bonuses for the item to check against known bonuses
  local itemBonuses = ItemUtils:BonusIDs(itemLink)

  -- Check to see if there is custom data for this item ID
  if CUSTOM_ITEM_DATA[itemID] then
    rarity, level, equipLoc, useItemBonuses = unpack(CUSTOM_ITEM_DATA[itemID])
    if useItemBonuses then
      level = level + GetItemBonusLevelDelta(itemBonuses)
    end

    if not level then
      return error("GetValue(item): could not determine item level from CUSTOM_ITEM_DATA.", 3)
    end
  end

  -- Is the item above our minimum threshold?
  if not rarity or rarity < quality_threshold then
    Debug("%s is below rarity threshold.", itemLink)
    return nil, nil, level, rarity, equipLoc
  end

  -- Check if it is a Relic
  if equipLoc == "" and itemSubClass == GetRelicSubClassString() then
    equipLoc = "INVTYPE_RELIC"
  end

  -- Does the item have bonus sockets or tertiary stats?  If so,
  -- set extra GP to apply later.  We don't care about warforged
  -- here as that uses the increased item level instead.
  local extra_gp = 0
  for _, value in pairs(itemBonuses) do
    extra_gp = extra_gp + (ITEM_BONUS_GP[value] or 0)
  end

  UpdateRecentLoot(itemLink)

  local slot_multiplier1 = EQUIPSLOT_MULTIPLIER_1[equipLoc]
  local slot_multiplier2 = EQUIPSLOT_MULTIPLIER_2[equipLoc]

  if not slot_multiplier1 then
    return nil, nil, level, rarity, equipLoc
  end
  -- 0.06973 is our coefficient so that ilvl 359 chests cost exactly
  -- 1000gp.  In 4.2 and higher, we renormalize to make ilvl 378
  -- chests cost 1000.  Repeat ad infinitum!
  local standard_ilvl
  local ilvl_denominator = 26 -- how much ilevel difference from standard affects cost, higher values mean less effect
  local version = select(4, GetBuildInfo())
  local level_cap = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
  if version < 20200 then
    standard_ilvl = 66
    ilvl_denominator = 10
  elseif version < 40200 then
    standard_ilvl = 359
  elseif version < 40300 then
    standard_ilvl = 378
  elseif version < 50200 then
    standard_ilvl = 496
  elseif version < 50400 then
    standard_ilvl = 522
  elseif version < 60000 or level_cap == 90 then
    standard_ilvl = 553
  elseif version < 60200 then
    standard_ilvl = 680
    ilvl_denominator = 30
  elseif version < 70000 then
    standard_ilvl = 710 -- HFC HC
    ilvl_denominator = 30
  elseif version < 70200 then
    standard_ilvl = 890 -- The Nighthold HC
    ilvl_denominator = 30
  elseif version < 70300 then
    standard_ilvl = 915 -- Tomb of Sargeras HC
    ilvl_denominator = 30
  elseif version < 80000 then
    standard_ilvl = 945 -- Antorus, the Burning Throne HC
    ilvl_denominator = 30
  else
    standard_ilvl = 370 -- Uldir
    ilvl_denominator = 32
  end
  local multiplier = 1000 * 2 ^ (-standard_ilvl / ilvl_denominator)
  local gp_base = multiplier * 2 ^ (level/ilvl_denominator)
  local high = math.floor(0.5 + gp_base * slot_multiplier1) + extra_gp
  local low = slot_multiplier2 and math.floor(0.5 + gp_base * slot_multiplier2) + extra_gp or nil
  Debug("%s:%d, %d, %d, %s, %s", itemLink, high, low or 0, level, rarity, equipLoc)
  Debug("%d, %d, %d",multiplier,gp_base,slot_multiplier1)
  return high, low, level, rarity, equipLoc
end
