local MAJOR_VERSION = "LibEpgpOorProfile-1.0"
local MINOR_VERSION = 10000

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

function lib:GetBossKillEp()
  local ep = {}
  ep[663]  = 0  -- MC 1
  ep[664]  = 1  -- MC 2
  ep[665]  = 0  -- MC 3
  ep[666]  = 1  -- MC 4
  ep[667]  = 0  -- MC 5
  ep[668]  = 1  -- MC 6
  ep[669]  = 0  -- MC 7
  ep[670]  = 1  -- MC 8
  ep[671]  = 1  -- MC 9
  ep[672]  = 2  -- MC 拉格纳罗斯

  ep[1084] = 1  -- 奥妮克希亚

  ep[610]  = 1  -- BWL 1
  ep[611]  = 1  -- BWL 2
  ep[612]  = 1  -- BWL 3
  ep[613]  = 1  -- BWL 4
  ep[614]  = 1  -- BWL 5
  ep[615]  = 1  -- BWL 6
  ep[616]  = 1  -- BWL 7
  ep[617]  = 2  -- BWL 奈法利安

  ep[709]  = 1  -- AQ40 预言者斯克拉姆
  ep[710]  = 1  -- AQ40 安其拉三宝
  ep[711]  = 1  -- AQ40 沙尔图拉
  ep[712]  = 1  -- AQ40 顽强的范克瑞斯
  ep[713]  = 2  -- AQ40 维希度斯
  ep[714]  = 1  -- AQ40 哈霍兰公主
  ep[715]  = 2  -- AQ40 双子皇帝
  ep[716]  = 2  -- AQ40 奥罗
  ep[717]  = 4  -- AQ40 克苏恩

  ep[1107]  = 3  -- NAXX 阿努布雷坎
  ep[1110]  = 3  -- NAXX 黑女巫法琳娜
  ep[1116]  = 6  -- NAXX 迈克斯纳
  ep[1117]  = 3  -- NAXX 瘟疫使者诺斯
  ep[1112]  = 3  -- NAXX 肮脏的希尔盖
  ep[1115]  = 6  -- NAXX 洛欧塞布
  ep[1113]  = 3  -- NAXX 教官拉苏维奥斯
  ep[1109]  = 3  -- NAXX 收割者戈提克
  ep[1121]  = 6  -- NAXX 四骑士
  ep[1118]  = 3  -- NAXX 帕奇维克
  ep[1111]  = 3  -- NAXX 格罗布鲁斯
  ep[1108]  = 3  -- NAXX 格拉斯
  ep[1120]  = 6  -- NAXX 塔迪乌斯
  ep[1119]  = 9  -- NAXX 萨菲隆
  ep[1114]  = 12 -- NAXX 克尔苏加德

  return ep
end

function lib:GetCustomItemsProfile()
  local CUSTOM_ITEM_DATA = {
    -- -- Classic P2
    -- [17204] = { 5, 80, "INVTYPE_2HWEAPON" }, -- 萨弗拉斯之眼
    -- [18422] = { 4, 74, "INVTYPE_NECK", "Horde" }, -- Head of Onyxia
    -- [18423] = { 4, 74, "INVTYPE_NECK", "Alliance" }, -- Head of Onyxia
    -- [18563] = { 5, 80, "INVTYPE_WEAPON" }, -- Legendary Sward
    -- [18564] = { 5, 80, "INVTYPE_WEAPON" }, -- Legendary Sward
    -- [18646] = { 4, 75, "INVTYPE_2HWEAPON" }, -- The Eye of Divinity
    -- [18703] = { 4, 75, "INVTYPE_RANGED" }, -- Ancient Petrified Leaf

    -- -- Classic P3
    -- [19003] = { 4, 83, "CUSTOM_GP", "Alliance", 5 }, -- [奈法利安的头颅]
    -- [19336] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [奥术能量宝石]
    -- [19337] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [黑龙之书]
    -- [19339] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [思维加速宝石]
    -- [19340] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [变形符文]
    -- [19341] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [生命宝石]
    -- [19342] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [毒性图腾]
    -- [19343] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [盲目光芒卷轴]
    -- [19345] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [庇护者]
    -- [19369] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [疾速进化手套]
    -- [19335] = { 4, 73, "CUSTOM_GP", nil, 5 }, -- [碎脊者]
    -- [19372] = { 4, 74, "CUSTOM_GP", nil, 1 }, -- [无尽怒气头盔]
    -- [19371] = { 4, 74, "CUSTOM_GP", nil, 1 }, -- [龙魂坠饰]
    -- [19373] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [黑龙肩铠]
    -- [19399] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [黑灰长袍]
    -- [19396] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [紧绷的龙皮腰带]
    -- [19365] = { 4, 75, "CUSTOM_GP", nil, 5 }, -- [黑龙之爪]
    -- [19353] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [龙爪巨斧]
    -- [19405] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [玛法里奥的祝福]
    -- [19430] = { 4, 75, "CUSTOM_GP", nil, 5 }, -- [纯净思想斗篷]
    -- [19433] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [灰烬护腿]
    -- [19357] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [悲哀使者]
    -- [19355] = { 4, 75, "CUSTOM_GP", nil, 5 }, -- [暗影之翼]
    -- [19357] = { 4, 75, "CUSTOM_GP", nil, 5 }, -- [源力之环]
    -- [19389] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [紧绷的龙皮护肩]
    -- [19390] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [紧绷的龙皮手套]
    -- [19388] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [安格莉丝塔之握]
    -- [19392] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [堕落十字军腰带]
    -- [19391] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [闪光之鞋]
    -- [19380] = { 4, 83, "CUSTOM_GP", nil, 5 }, -- [塞拉赞恩之链]
    -- [19376] = { 4, 83, "CUSTOM_GP", nil, 5 }, -- [阿基迪罗斯的清算之戒]
    -- [19439] = { 4, 71, "CUSTOM_GP", nil, 0 }, -- [交织暗影外衣]
    -- [19354] = { 4, 71, "CUSTOM_GP", nil, 1 }, -- [巨龙复仇者]

    -- -- Classic P5
    -- [20928] = { 4, 81, "INVTYPE_SHOULDER" }, -- T2.5 shoulder, feet
    -- [20932] = { 4, 81, "INVTYPE_SHOULDER" }, -- T2.5 shoulder, feet
    -- [20930] = { 4, 81, "INVTYPE_HEAD" },     -- T2.5 head
    -- [20926] = { 4, 81, "INVTYPE_HEAD" },     -- T2.5 head
    -- [20927] = { 4, 81, "INVTYPE_LEGS" },     -- T2.5 legs
    -- [20931] = { 4, 81, "INVTYPE_LEGS" },     -- T2.5 legs
    -- [20929] = { 4, 81, "INVTYPE_CHEST" },    -- T2.5 chest
    -- [20933] = { 4, 81, "INVTYPE_CHEST" },    -- T2.5 chest
    -- [21232] = { 4, 79, "INVTYPE_WEAPON" },   -- 其拉帝王武器
    -- [21237] = { 4, 79, "INVTYPE_2HWEAPON" }, -- 其拉帝王徽记

    -- -- TAQ 预言者斯克拉姆
    -- [21699] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [障碍护肩]
    -- [21708] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [甲虫鳞片护腕]
    -- [21698] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [浸没护腿]
    -- [21705] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [堕落先知长靴]
    -- [21706] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [坚定意志长靴]
    -- [21703] = { 4, 73, "CUSTOM_GP", nil, 1 }, -- [棘枝战锤]
    -- [21128] = { 4, 75, "CUSTOM_GP", nil, 1 }, -- [其拉预言者法杖]

    -- -- TAQ 安其拉三宝
    -- [21681] = { 4, 78, "CUSTOM_GP", nil, 1 }, -- [吞噬者之戒]
    -- [21685] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [石化甲虫]
    -- [21684] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [沙漠狂暴衬肩]

    -- -- TAQ 沙尔图拉
    -- [21671] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [作战卫士长袍]
    -- [21668] = { 4, 76, "CUSTOM_GP", nil, 1 }, -- [缀鳞其拉狂暴护腿]

    -- -- TAQ 顽强的范克瑞斯
    -- [21647] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [沙漠掠夺者塑像]
    -- [21639] = { 4, 77, "CUSTOM_GP", nil, 1 }, -- [冷酷者肩铠]

    -- -- TAQ 维希度斯
    -- [21624] = { 4, 78, "CUSTOM_GP", nil, 1 }, -- [卡利姆多护手]
    -- [21623] = { 4, 78, "CUSTOM_GP", nil, 1 }, -- [正义勇士护手]
    -- [21622] = { 4, 84, "INVTYPE_WEAPONMAINHAND" }, -- [锋利的异种虫腿]
    -- -- [21625] = { 4, 78, "CUSTOM_GP", nil, 1 }, -- [甲虫胸针]

    -- -- TAQ 哈霍兰公主
    -- [21619] = { 4, 78, "CUSTOM_GP", nil, 1 }, -- [救世者手套]

    -- -- TAQ 双子皇帝
    -- [21599] = { 4, 81, "CUSTOM_GP", nil, 1 }, -- [维克洛尔的毁灭手套]
    -- [21607] = { 4, 81, "CUSTOM_GP", nil, 1 }, -- [堕落帝王的拥抱]
    -- [21606] = { 4, 81, "CUSTOM_GP", nil, 1 }, -- [堕落帝王腰带]

    -- -- TAQ 奥罗
    -- [23558] = { 4, 81, "CUSTOM_GP", nil, 1 }, -- [穴居虫之壳]

    -- -- TAQ 克苏恩
    -- [21134] = { 4, 84, "CUSTOM_SCALE", nil, 2.0 }, -- [疯狂黑暗之刃]
    -- [21579] = { 4, 88, "CUSTOM_GP", nil, 1 }, -- [克苏恩的触须]
    -- [21221] = { 4, 88, "INVTYPE_NECK" },      -- [克苏恩之眼]

    -- -- TAQ 小怪
    -- [21888] = { 4, 71, "CUSTOM_GP", nil, 1 }, -- [不朽手套]
    -- [21837] = { 4, 77, "INVTYPE_WEAPONOFFHAND" }, -- [阿努比萨斯战锤]
    -- [21891] = { 4, 81, "CUSTOM_GP", nil, 1 }, -- [坠落星辰碎片]

    -- -- NAXX T3
    -- [22349] = { 4, 86, "INVTYPE_CHEST" },
    -- [22350] = { 4, 86, "INVTYPE_CHEST" },
    -- [22351] = { 4, 86, "INVTYPE_CHEST" },
    -- [22352] = { 4, 86, "INVTYPE_LEGS" },
    -- [22359] = { 4, 86, "INVTYPE_LEGS" },
    -- [22366] = { 4, 86, "INVTYPE_LEGS" },
    -- [22353] = { 4, 86, "INVTYPE_HEAD" },
    -- [22360] = { 4, 86, "INVTYPE_HEAD" },
    -- [22367] = { 4, 86, "INVTYPE_HEAD" },
    -- [22354] = { 4, 86, "INVTYPE_SHOULDER" },
    -- [22361] = { 4, 86, "INVTYPE_SHOULDER" },
    -- [22368] = { 4, 86, "INVTYPE_SHOULDER" },
    -- [22355] = { 4, 86, "INVTYPE_WRIST" },
    -- [22362] = { 4, 86, "INVTYPE_WRIST" },
    -- [22369] = { 4, 86, "INVTYPE_WRIST" },
    -- [22356] = { 4, 86, "INVTYPE_WAIST" },
    -- [22363] = { 4, 86, "INVTYPE_WAIST" },
    -- [22370] = { 4, 86, "INVTYPE_WAIST" },
    -- [22357] = { 4, 86, "INVTYPE_HAND" },
    -- [22364] = { 4, 86, "INVTYPE_HAND" },
    -- [22371] = { 4, 86, "INVTYPE_HAND" },
    -- [22358] = { 4, 86, "INVTYPE_FEET" },
    -- [22365] = { 4, 86, "INVTYPE_FEET" },
    -- [22372] = { 4, 86, "INVTYPE_FEET" },
    -- [23061] = { 4, 86, "INVTYPE_FINGER" },  -- [信仰之戒]
    -- [23062] = { 4, 86, "INVTYPE_FINGER" },  -- [霜火之戒]
    -- [23063] = { 4, 86, "INVTYPE_FINGER" },  -- [瘟疫之心指环]
    -- [23060] = { 4, 86, "INVTYPE_FINGER" },  -- [骨镰之戒]
    -- [23064] = { 4, 86, "INVTYPE_FINGER" },  -- [梦游者之戒]
    -- [23067] = { 4, 86, "INVTYPE_FINGER" },  -- [地穴追猎者指环]
    -- [23065] = { 4, 86, "INVTYPE_FINGER" },  -- [碎地者之戒]
    -- [23066] = { 4, 86, "INVTYPE_FINGER" },  -- [救赎之戒]
    -- [23059] = { 4, 86, "INVTYPE_FINGER" },  -- [无畏之戒]
    -- [22726] = { 5, 90, "CUSTOM_GP", nil, 20 }, -- [埃提耶什的碎片]
    -- -- NAXX 小怪
    -- [23664] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [元素愤怒肩铠]
    -- [23667] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [大十字军的肩甲]
    -- [23069] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [死灵骑士的外衣]
    -- [23663] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [元素愤怒束带]
    -- [23666] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [大十字军的腰带]
    -- [23665] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [元素愤怒护腿]
    -- [23668] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [大十字军的护腿]
    -- [23238] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [冥河圆盾]
    -- -- NAXX 阿努布雷坎
    -- [22937] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [蛛魔宝石]
    -- -- NAXX 黑女巫法琳娜
    -- [22943] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [仇恨石坠]
    -- -- NAXX 迈克斯纳
    -- [22947] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [遗忘之名]
    -- -- NAXX 洛欧塞布
    -- [23037] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [灵魂热情之戒]
    -- [23042] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [洛欧塞布之影]
    -- -- NAXX 教官拉苏维奥斯
    -- [23017] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [日蚀之幕]
    -- -- NAXX 收割者戈提克
    -- [23023] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [萨迪斯的项圈]
    -- [23073] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [偏移之靴]
    -- -- NAXX 四骑士
    -- [22809] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [赎罪十字军之槌]
    -- [22691] = { 4, 89, "INVTYPE_2HWEAPON" },  -- [堕落的灰烬使者]
    -- -- NAXX 格拉斯
    -- [22994] = { 4, 83, "CUSTOM_GP", nil, 1 }, -- [被消化的力量之手]
    -- -- NAXX 塔迪乌斯
    -- [23001] = { 4, 85, "CUSTOM_GP", nil, 1 }, -- [衰落之眼]
    -- -- NAXX 萨菲隆
    -- [23549] = { 4, 90, "CUSTOM_GP", nil, 20 }, -- [天灾的坚韧]
    -- [23548] = { 4, 90, "CUSTOM_GP", nil, 20 }, -- [天灾的威严]
    -- [23545] = { 4, 90, "CUSTOM_GP", nil, 20 }, -- [天灾的力量]
    -- [23547] = { 4, 90, "CUSTOM_GP", nil, 20 }, -- [天灾的活力]
    -- -- NAXX 克尔苏加德
    -- [22520] = { 4, 90, "INVTYPE_TRINKET" }, -- [克尔苏加德的护符匣]
  }
  return CUSTOM_ITEM_DATA
end

function lib:GetPointsProfile(L, DISPLAY_NAME, LOCAL_NAME)
  local profile = {
    enabled = true,

    baseGP = 80,
    standardIlvl = 120,
    ilvlDenominator = 13,
    legendaryScale = 3,

    headScale1 = 1,
    headComment1 = _G.INVTYPE_HEAD,

    neckScale1 = 0.6,
    neckComment1 = _G.INVTYPE_NECK,

    shoulderScale1 = 0.8,
    shoulderComment1 = _G.INVTYPE_SHOULDER,

    -- bodyScale1 = 0,
    -- bodyComment1 = _G.INVTYPE_BODY,

    chestScale1 = 1,
    chestComment1 = _G.INVTYPE_CHEST,

    waistScale1 = 0.8,
    waistComment1 = _G.INVTYPE_WAIST,

    legsScale1 = 1,
    legsComment1 = _G.INVTYPE_LEGS,

    feetScale1 = 0.8,
    feetComment1 = _G.INVTYPE_FEET,

    wristScale1 = 0.6,
    wristComment1 = _G.INVTYPE_WRIST,

    handScale1 = 0.8,
    handComment1 = _G.INVTYPE_HAND,

    fingerScale1 = 0.6,
    fingerComment1 = _G.INVTYPE_FINGER,

    trinketScale1 = 1.5,
    trinketComment1 = _G.INVTYPE_TRINKET,

    cloakScale1 = 0.6,
    cloakComment1 = _G.INVTYPE_CLOAK,

    weaponScale1 = 2.0,
    weaponComment1 = DISPLAY_NAME.MainHWeapon,
    weaponScale2 = 0.5,
    weaponComment2 = DISPLAY_NAME.OffHWeapon,
    weaponScale3 = 0.15,
    weaponComment3 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

    shieldScale1 = 0.5,
    shieldComment1 = _G.SHIELDSLOT,

    weapon2HScale1 = 2.5,
    weapon2HComment1 = DISPLAY_NAME.TwoHWeapon,
    weapon2HScale2 = 0.3,
    weapon2HComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.TwoHWeapon),

    weaponMainHScale1 = 2.0,
    weaponMainHComment1 = DISPLAY_NAME.MainHWeapon,
    weaponMainHScale2 = 0.15,
    weaponMainHComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

    weaponOffHScale1 = 0.5,
    weaponOffHComment1 = DISPLAY_NAME.OffHWeapon,
    weaponOffHScale2 = 0.15,
    weaponOffHComment2 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, DISPLAY_NAME.OneHWeapon),

    holdableScale1 = 0.5,
    holdableComment1 = _G.INVTYPE_HOLDABLE,

    rangedScale1 = 2.5,
    rangedComment1 = L["%s %s"]:format(_G.LOCALIZED_CLASS_NAMES_MALE.HUNTER, _G.INVTYPE_RANGED),
    rangedScale2 = 0.3,
    rangedComment2 = L["%s %s"]:format(L["Non-hunter"], _G.INVTYPE_RANGED),

    wandScale1 = 0.3,
    wandComment1 = LOCAL_NAME.Wand,

    thrownScale1 = 0.3,
    thrownComment1 = LOCAL_NAME.Thrown,

    relicScale1 = 0.3,
    relicComment1 = _G.INVTYPE_RELIC,

    -- bagScale1 = 0,
    -- bagComment1 = _G.INVTYPE_BAG,
  }
  return profile
end
