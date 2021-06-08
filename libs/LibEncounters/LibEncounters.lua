local MAJOR, MINOR = "LibEncounters", 2
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
local L = LibStub("AceLocale-3.0"):GetLocale("LibEncounters")

if not lib then return end

lib.encounters = lib.encounters or {}
lib.instances = lib.instances or {}

function lib:GetEncounter(id)
  id = tonumber(id)
  assert(id, "Usage: GetEncounter(id)")
  if lib.encounters[id] ~= nil then
    return lib.encounters[id]
  end
  return nil
end

function lib:GetInstance(id)
  id = tonumber(id)
  assert(id, "Usage: GetInstance(id)")
  if lib.instances[id] ~= nil then
    return lib.instances[id]
  end
  return nil
end

--   [] =	{ name = L[""], instance = },
lib.encounters = {
  -- Black Temple
  [601] =	{ name = L["High Warlord Naj'entus"], instance = 564},
  [602] =	{ name = L["Supremus"], instance = 564},
  [603] =	{ name = L["Shade of Akama"], instance = 564},
  [604] =	{ name = L["Teron Gorefiend"], instance = 564},
  [605] =	{ name = L["Gurtogg Bloodboil"], instance = 564},
  [606] =	{ name = L["Reliquary of Souls"], instance = 564},
  [607] =	{ name = L["Mother Shahraz"], instance = 564},
  [608] =	{ name = L["The Illidari Council"], instance = 564},
  [609] =	{ name = L["Illidan Stormrage"], instance = 564},

  -- Blackwing Lair
  [610] = { name = L["Razorgore the Untamed"], instance = 469},
  [611] = { name = L["Vaelastrasz the Corrupt"], instance = 469},
  [612] = { name = L["Broodlord Lashlayer"], instance = 469},
  [613] = { name = L["Firemaw"], instance = 469},
  [614] = { name = L["Ebonroc"], instance = 469},
  [615] = { name = L["Flamegor"], instance = 469},
  [616] = { name = L["Chromaggus"], instance = 469},
  [617] = { name = L["Nefarian"], instance = 469},

  -- The Battle for Mount Hyjal
  [618] =	{ name = L["Rage Winterchill"], instance = 534},
  [619] =	{ name = L["Anetheron"], instance = 534},
  [620] =	{ name = L["Kaz'rogal"], instance = 534},
  [621] =	{ name = L["Azgalor"], instance = 534},
  [622] =	{ name = L["Archimonde"], instance = 534},

  -- Coilfang: Serpentshrine Cavern
  [623] =	{ name = L["Hydross the Unstable"], instance = 548},
  [624] =	{ name = L["The Lurker Below"], instance = 548},
  [625] =	{ name = L["Leotheras the Blind"], instance = 548},
  [626] =	{ name = L["Fathom-Lord Karathress"], instance = 548},
  [627] =	{ name = L["Morogrim Tidewalker"], instance = 548},
  [628] =	{ name = L["Lady Vashj"], instance = 548},

  -- Gruul's Lair
  [649] =	{ name = L["High King Maulgar"], instance = 565},
  [650] =	{ name = L["Gruul the Dragonkiller"], instance = 565},

  -- Magtheridon's Lair
  [651] =	{ name = L["Magtheridon"], instance = 544},

  -- Karazhan
  [652] =	{ name = L["Attumen the Huntsman"], instance = 532},
  [653]	=	{ name = L["Moroes"], instance = 532},
  [654]	=	{ name = L["Maiden of Virtue"], instance = 532},
  [655]	=	{ name = L["Opera Hall"], instance = 532},
  [656]	=	{ name = L["The Curator"], instance = 532},
  [657]	=	{ name = L["Terestian Illhoof"], instance = 532},
  [658]	=	{ name = L["Shade of Aran"], instance = 532},
  [659]	=	{ name = L["Netherspite"], instance = 532},
  [660]	=	{ name = L["Chess Event"], instance = 532},
  [661]	=	{ name = L["Prince Malchezaar"], instance = 532},
  [662]	=	{ name = L["Nightbane"], instance = 532},

  -- Molten Core
  [663] = { name = L["Lucifron"], instance = 409},
  [664] = { name = L["Magmadar"], instance = 409},
  [665] = { name = L["Gehennas"], instance = 409},
  [666] = { name = L["Garr"], instance = 409},
  [667] = { name = L["Shazzrah"], instance = 409},
  [668] = { name = L["Baron Geddon"], instance = 409},
  [669] = { name = L["Sulfuron Harbinger"], instance = 409},
  [670] = { name = L["Golemagg the Incinerator"], instance = 409},
  [671] = { name = L["Majordomo Executus"], instance = 409},
  [672] = { name = L["Ragnaros"], instance = 409},

  -- Ahn'Qiraj Temple
  [709] = { name = L["The Prophet Skeram"], instance = 531},
  [710] = { name = L["Silithid Royalty"], instance = 531},
  [711] = { name = L["Battleguard Sartura"], instance = 531},
  [712] = { name = L["Fankriss the Unyielding"], instance = 531},
  [713] = { name = L["Viscidus"], instance = 531},
  [714] = { name = L["Princess Huhuran"], instance = 531},
  [715] = { name = L["Twin Emperors"], instance = 531},
  [716] = { name = L["Ouro"], instance = 531},
  [717] = { name = L["C'thun"], instance = 531},

  -- Ruins of Ahn'Qiraj
  [718] = { name = L["Kurinnaxx"], instance = 509},
  [719] = { name = L["General Rajaxx"], instance = 509},
  [720] = { name = L["Moam"], instance = 509},
  [721] = { name = L["Buru the Gorger"], instance = 509},
  [722] = { name = L["Ayamiss the Hunter"], instance = 509},
  [723] = { name = L["Ossirian the Unscarred"], instance = 509},

  -- The Sunwell
  [724] = { name = L["Kalecgos"], instance = 580},
  [725] = { name = L["Brutallus"], instance = 580},
  [726] = { name = L["Felmyst"], instance = 580},
  [727] = { name = L["Eredar Twins"], instance = 580},
  [728] = { name = L["M'uru"], instance = 580},
  [729] = { name = L["Kil'jaeden"], instance = 580},

  -- Tempest Keep
  [730] = { name = L["Al'ar"], instance = 550},
  [731] = { name = L["Void Reaver"], instance = 550},
  [732] = { name = L["High Astromancer Solarian"], instance = 550},
  [733] = { name = L["Kael'thas Sunstrider"], instance = 550},

  -- Zul'Gurub
  [784] = { name = L["High Priest Venoxis"], instance = 309},
  [785] = { name = L["High Priestess Jeklik"], instance = 309},
  [786] = { name = L["High Priestess Mar'li"], instance = 309},
  [787] = { name = L["Bloodlord Mandokir"], instance = 309},
  [788] = { name = L["Edge of Madness"], instance = 309},
  [789] = { name = L["High Priest Thekal"], instance = 309},
  [790] = { name = L["Gahz'ranka"], instance = 309},
  [791] = { name = L["High Priestess Arlokk"], instance = 309},
  [792] = { name = L["Jin'do the Hexxer"], instance = 309},
  [793] = { name = L["Hakkar"], instance = 309},

  -- Onyxia's Lair
  [1084] = { name = L["Onyxia"], instance = 249},

  -- Naxxramas
  [1107] = { name = L["Anub'Rekhan"], instance = 533},
  [1108] = { name = L["Gluth"], instance = 533},
  [1109] = { name = L["Gothik the Harvester"], instance = 533},
  [1110] = { name = L["Grand Widow Faerlina"], instance = 533},
  [1111] = { name = L["Grobbulus"], instance = 533},
  [1112] = { name = L["Heigan the Unclean"], instance = 533},
  [1113] = { name = L["Instructor Razuvious"], instance = 533},
  [1114] = { name = L["Kel'Thuzad"], instance = 533},
  [1115] = { name = L["Loatheb"], instance = 533},
  [1116] = { name = L["Maexxna"], instance = 533},
  [1117] = { name = L["Noth the Plaguebringer"], instance = 533},
  [1118] = { name = L["Patchwerk"], instance = 533},
  [1119] = { name = L["Sapphiron"], instance = 533},
  [1120] = { name = L["Thaddius"], instance = 533},
  [1121] = { name = L["The Four Horsemen"], instance = 533}
}

lib.instances = {
  [249] = { name = L["Onyxia's Lair"] },
  [309] = { name = L["Zul'Gurub"] },
  [409] = { name = L["Molton Core"] },
  [469] = { name = L["Blackwing Lair"] },
  [509] = { name = L["Ruins of Ahn'Qiraj"] },
  [531] = { name = L["Ahn'Qiraj Temple"] },
  [532] = { name = L["Karazhan"] },
  [533] = { name = L["Naxxramas"] },
  [534] = { name = L["The Battle for Mount Hyjal"] },
  [564] = { name = L["Black Temple"] },
  [544] = { name = L["Magtheridon's Lair"] },
  [548] = { name = L["Coilfang: Serpentshrine Cavern"] },
  [550] = { name = L["Tempest Keep"] },
  [565] = { name = L["Gruul's Lair"] },
  [580] = { name = L["The Sunwell"] }
}
