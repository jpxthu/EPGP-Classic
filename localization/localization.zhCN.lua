local L = LibStub("AceLocale-3.0"):NewLocale("EPGP", "zhCN")
if not L then return end

--@localization(locale="zhCN", format="lua_additive_table", same-key-is-true=true)@

--@debug@

L["%+d EP (%s) to %s"] = "%+d EP (%s) 给 %s"
L["%+d GP (%s) to %s"] = "%+d GP (%s) 给 %s"
L["'%s' - expected 'on' or 'off', or no argument to toggle."] = "'%s' - 选择“on”，“off”或者“default”，否则将无法触发"
L["'%s' - expected 'on', 'off' or 'default', or no argument to toggle."] = "'%s' - 选择“on”，“off”或者“default”，否则将无法触发"
L["'%s' - expected 'RRGGBB' or 'r g b'."] = "'%s' - 期望参数 'RRGGBB' 或 'r g b'."
L["'%s' - expected 'RRGGBBAA' or 'r g b a'."] = "'%s' - 需要 “RRGGBBAA” 或 “r g b a”."
L["'%s' - Invalid Keybinding."] = "'%s' - 无效按键绑定"
L["'%s' - values must all be either in the range 0..1 or 0..255."] = "'%s' - 必须选择0-1 或 0-255之间的值"
L["'%s' - values must all be either in the range 0-1 or 0-255."] = "'%s' - 必须选择0-1 或 0-255之间的值"
L["%s %s"] = "%s%s"
L["'%s' '%s' - expected 'on' or 'off', or no argument to toggle."] = "'%s' '%s' - 期望值为 'on' 或 'off'. 没有参数则在 'on' 与 'off' 之间切换."
L["'%s' '%s' - expected 'on', 'off' or 'default', or no argument to toggle."] = "'%s' '%s' - 期望参数 'on', 'off' 或 'default', 没有参数则在状态间切换."
L["%s is added to the award list"] = "%s 被添加进奖励名单中"
L["%s is already in the award list"] = "%s 已经在奖励名单中"
L["%s is dead. Award EP?"] = "%s 被击杀。奖励 EP？"
L["%s is not eligible for EP awards"] = "%s 无资格获得 EP 奖励"
L["%s is not in the award list now. Whisper me 'epgp standby' to enlist again."] = "%s 已经不在计分名单中，密语 \"epgp standby\" 以重新加入。"
L["%s is now removed from the award list. Whisper me 'epgp standby' to enlist again."] = "%s 已被移出计分名单，密语 \"epgp standby\" 以重新加入。"
L["%s to %s"] = "%s 给 %s"
L["%s, %s, %s"] = "%s、%s、%s"
L["%s, %s, %s, %s"] = "%s、%s、%s、%s"
L["%s: %+d EP (%s) to %s"] = "%s: %+d EP (%s) 给 %s"
L["%s: %+d GP (%s) to %s"] = "%s: %+d GP (%s) 给 %s"
L["%s: %s to %s"] = "%s: %s 由 %s"
L["/roll if you want this item. DO NOT roll more than one time."] = "需求请 roll 点（/roll）。请不要重复 roll 点。"
L["[%s] has been added into trust list."] = "[%s] 已被加入信任名单。"
L["[%s] has been updated."] = "[%s] 已更新。"
L["[%s] is comming!"] = "[%s] 即将到来！"
L["[EPGP auto reply] "] = "[EPGP 自动回复] "
L["A member is awarded EP"] = "一名会员被奖励 EP"
L["A member is credited GP"] = "一名会员被记入 GP"
L["A new tier is here!"] = "新的级别出现！"
L["A new tier is here!  You should probably reset or rescale GP (Interface -> Options -> AddOns -> EPGP)!"] = "新的级别出现！你可能需要重置或重新调整 GP （界面-> 选项-> 插件-> EPGP）！"
L["Accepting settings from [%s]..."] = "正在接收来自 [%s] 的设置……"
L["Add loot items automatically when loot windows opened or corpse loot received."] = "打开拾取窗口或收到掉落信息后，自动添加掉落物品。"
L["Adjust all main toons' GP?"] = "调整所有大号的 GP？"
L["Allow adding [name] into standby list by whispering \"epgp standby [name]\" if enabled."] = "允许密语 \"epgp standby [角色名]\" 将其他角色加入替补名单"
L["Allow whisper for others"] = "允许替他人替补"
L["ALLOW_NEGATIVE_EP_DESC"] = "允许公会成员的 EP 是负整数。测试功能，可能有 bug！"
L["ALLOW_NEGATIVE_EP_NAME"] = "允许负数 EP（测试功能）"
L["Alts"] = "小号"
L["An item was disenchanted or deposited into the guild bank"] = "一件物品已被分解或已存入公会银行"
L["Announce"] = "通告"
L["Announce EP/GP/PR when a member need/greed/bid"] = "成员需求/贪婪/竞标时通告 EP/GP/PR"
L["Announce epic loot from corpses"] = "通报尸体内的史诗掉落"
L["Announce medium"] = "通告媒介"
L["Announce need message"] = "需求通告信息"
L["Announce when someone in your raid derps a bonus roll"] = "当团队内有人用幸运币但未获得装备时通报"
L["Announce when someone in your raid wins something good with bonus roll"] = "当团队内有人通过幸运币获得物品时通报"
L["Announce when:"] = "何时通告："
L["Announcement of EPGP actions"] = "EPGP 操作通告"
L["Announces EPGP actions to the specified medium."] = "通告 EPGP 操作至指定媒介。"
L["Auto popup"] = "自动弹出"
L["Automatic boss tracking"] = "自动追踪首领"
L["Automatic boss tracking by means of a popup to mass award EP to the raid and standby when a boss is killed."] = "自动追踪首领，在击杀首领后弹窗群体奖励 EP 给团队成员及待命人员。"
L["Automatic handling of the standby list through whispers when in raid. When this is enabled, the standby list is cleared after each reward."] = "团队活动中通过密语自动处理待命名单。如启用，每次奖励后待命名单将被清空。"
L["Automatic loot tracking"] = "自动追踪拾取"
L["Automatic loot tracking by means of a popup to assign GP to the toon that received loot. This option only has effect if you are in a raid and you are either the Raid Leader or the Master Looter."] = "自动追踪拾取，借助弹窗为获得战利品的角色指定 GP。仅当你是团长或团队物品分配者时生效。"
L["Award EP"] = "奖励 EP"
L["Awards for wipes on bosses. Requires DBM, DXE, or BigWigs"] = "对首领战灭团进行奖励。需要 DBM、DXE 或 BigWigs 插件。"
L["Base GP should be a positive number (>= 0)"] = "Base GP 应为正数（>= 0）"
L["Bid medium"] = "竞标媒介"
L["Blackwing Lair"] = "黑翼之巢"
L["Bonus roll for %s (%s left): got %s (ilvl %d)"] = "%s 额外拾取（%s 剩余）：获得 %s（装等 %d）"
L["Bonus roll for %s (%s left): got gold"] = "%s 额外拾取（%s 剩余）：获得金币"
L["BOSS_AUTO_REWARD_DESC"] = "BOSS 击杀或灭团后向自动奖励 EP。需要 DBM。如果输入框留空，BOSS 击杀或灭团后会弹出原来的奖励窗口。"
L["BOSS_AUTO_REWARD_NAME"] = "自动奖励 EP"
L["BOSS_AUTO_REWARD_START"] = "开始 BOSS 击杀/灭团自动奖励"
L["BOSS_AUTO_REWARD_STOP"] = "停止 BOSS 击杀/灭团自动奖励"
L["BOSS_KILL_AUTO_AWARD_0_EP_DESC"] = "[%s] 的击杀自动奖励 EP 为 0，跳过。"
L["BOSS_WIPE_AUTO_AWARD_0_EP_DESC"] = "[%s] 的灭团自动奖励 EP 为 0，跳过。"
L["Clear"] = "清除"
L["Collect bid/roll message to help sorting"] = "收集竞标和 roll 点信息并排序"
L["COMBATLOG_ENABLE_FAIL"] = "开启战斗日志失败，请手动尝试（/combatlog）。"
L["COMBATLOG_ENABLE_REMIND_MSG"] = [=[EPGP 提醒
是否启用战斗日志？（/combatlog）]=]
L["COMBATLOG_IS_LOGGING"] = "战斗日志已启用（/combatlog）。"
L["COMBATLOG_REMIND_ENABLE_DESC"] = [=[当满足以下条件时提醒启用战斗日志：
1. 加入一个团队
2. 进入游戏并且在一个团队中
这是一个测试功能。]=]
L["COMBATLOG_REMIND_ENABLE_NAME"] = "提醒启用战斗日志（测试）"
L["Comment %d"] = "备注 %d"
L["Credit GP"] = "记入 GP"
L["Credit GP to %s"] = "给 %s 增加 GP"
L["Custom announce channel name"] = "自定义通告频道名称"
L["Custom items list has been reseted."] = "自定义物品列表已被重置。"
L["Decay"] = "衰减"
L["Decay BASE_GP should be 0 or 1"] = "衰减 BASE_GP 应为 0 或 1"
L["Decay EP and GP by %d%%?"] = "衰减 %d%% 的 EP 和 GP ?"
L["Decay of EP/GP by %d%%"] = "EP 和 GP 衰减 %d%%"
L["Decay Percent should be a number between 0 and 100"] = "Decay（衰减）百分比应介于 0 至 100 之间"
L["DECAY_BASE_GP_DESC"] = [=[衰减时计算 BASE_GP。
如果选中（默认，衰减更快）：decay_gp = (gp + BASE_GP) * DECAY_P / 100
如果不选中：decay_gp = gp * DECAY_P / 100]=]
L["DECAY_BASE_GP_TEXT"] = "衰减 BASE_GP"
L["DECAY_P_DESC"] = "衰减百分比"
L["default"] = "默认"
L["DIST_ANNOUNCE_PR_FMT_DESC"] = [=[默认值：
${char} EP:${ep} GP:${gp} PR:${pr}

可选变量：
${bid}]=]
L["DIST_ANNOUNCE_PR_FMT_NAME"] = "EP/GP/PR 通告文字格式"
L["Distribution"] = "分配"
L["Do you want to resume recurring award (%s) %d EP/%s?"] = "你想重新开始周期性奖励 (%s) %d EP/%s 吗？"
L["EP Reason"] = "EP 理由"
L["EP/GP are reset"] = "EP/GP 已被重置"
L["EP/GP/PR announce medium"] = "EP/GP/PR 通告媒介"
L["EPGP decay"] = "EPGP 衰减"
L["EPGP is an in game, relational loot distribution system"] = "EPGP 是一个游戏内置的关联式战利品分配系统"
L["EPGP is using Officer Notes for data storage. Do you really want to edit the Officer Note by hand?"] = "EPGP 使用官员备注存储数据。你确定要手动修改官员备注吗？"
L["EPGP reset"] = "EPGP 重置"
L["Equation"] = "公式"
L["expected number"] = "期望参数：数字"
L["Export"] = "导出"
L["Export Detail"] = "导出明细"
L["EXPORT_DETAIL_DESC"] = "可以导入至支持的 EPGP 系统中："
L["Extras Percent should be a number between 0 and 100"] = "Extras 百分比应介于 0 至 100 之间"
L["EXTRAS_P_DESC"] = "替补成员 EP 奖励的百分比"
L["Gear Points"] = "装备分数"
L["Global configuration"] = "全局设置"
L["GP (not EP) is reset"] = "GP（不是 EP）被重置了"
L["GP (not ep) reset"] = "重置 GP（非 EP）"
L["GP is rescaled for the new tier"] = "新等级来临，GP 已被重新调整"
L["GP on tooltips"] = "在鼠标提示中显示 GP"
L["GP Reason"] = "GP 原因"
L["GP rescale for new tier"] = "为了新等级重新调整 GP"
L["Guild info has been updated."] = "公会信息已更新。"
L["Guild or Raid are awarded EP"] = "公会或团队被奖励 EP"
L["Hint: You can open these options by typing /epgp config"] = "提示：你可通过键入 /epgp config 来显示这些选项"
L["Icon"] = "图标"
L["Idle"] = "待命"
L["If you want to be on the award list but you are not in the raid, you need to whisper me: 'epgp standby' or 'epgp standby <name>' where <name> is the toon that should receive awards"] = "如果你想进入奖励名单却不在团队中，那么你必须向我密语：“epgp standby”或“epgp standby <角色名>”。此<角色名>应为接受奖励的角色。"
L["Ignoring EP change for unknown member %s"] = "忽略对未知会员 [%s] 进行的 EP 改动"
L["Ignoring GP change for unknown member %s"] = "忽略对未知会员 [%s] 进行的 GP 改动"
L["Import"] = "导入"
L["Importing data snapshot taken at: %s"] = "导入%s截取的数据快照"
L["invalid input"] = "无效输入"
L["Invalid officer note [%s] for %s (ignored)"] = "人物 %s 包含无效的官员备注 [%s] (已被忽略)"
L["kill"] = "击杀"
L["Legendary Scale"] = "传说装备系数"
L["List errors"] = "列出错误"
L["Lists errors during officer note parsing to the default chat frame. Examples are members with an invalid officer note."] = "在默认聊天框架中列出解析官员备注时发生的错误。例如具有无效官员备注的会员。"
L["Logs"] = "记录"
L["Loot list is almost full (%d/%d)."] = "战利品列表快满了（%d/%d）。"
L["Loot list is full (%d). %s will not be added into list."] = "战利品列表满了（%d）。%s 不会被加入列表。"
L["Loot list: "] = "战利品列表："
L["Loot tracking threshold"] = "战利品拾取追踪等级阀值"
L["LOOT_ITEM_LOG_CLEAR_MSG"] = "拾取记录已清空。"
L["LOOT_ITEM_LOG_CLEAR_NAME"] = "清空拾取记录"
L["LOOT_ITEM_LOG_HEADER"] = "拾取记录"
L["LOOT_ITEM_LOG_SHOW_NUMBER_NAME"] = "最大记录数量"
L["LOOT_RECORD_ITEM_LOG_DESC"] = "保存拾取记录，在物品的鼠标提示中显示。"
L["LOOT_RECORD_ITEM_LOG_NAME"] = "保存拾取记录"
L["Main"] = "大号"
L["Make sure you are the only person changing EP and GP. If you have multiple people changing EP and GP at the same time, for example one awarding EP and another crediting GP, you *are* going to have data loss."] = "确保你是唯一一个正在变更 EP 和 GP 的人。如果有多人同时变更 EP 和 GP，比如一个人正在发放 EP 时另一个人记录 GP，你*必定*会丢失数据。"
L["Mass Adjust GP"] = "批量调整 GP"
L["Mass EP Award"] = "群体EP奖励"
L["MASS_ADJUST_GP_DESC"] = "为公会所有人调整 GP。增加或减少每个人的 GP。如果你曾经使用 CEPGP，可能需要调整 GP。"
L["Message announced when you start a need/greed bid."] = "开始一项需求/贪婪竞标时通告的信息。"
L["Min EP should be a positive number (>= 0)"] = "Min EP 应为正数（>= 0）"
L["Multiplier %d"] = "系数 %d"
L["must be equal to or higher than %s"] = "必须高于或等于 %s"
L["must be equal to or lower than %s"] = "必须小于等于 %s"
L["Naxxramas"] = "纳克萨玛斯"
L["Need/greed medium"] = "需求/贪婪媒介"
L["NEW_VERSION_INTRO_1_5_0"] = [=[新功能：
1. BOSS 击杀/灭团自动奖励。在 %s -> %s -> EPGP -> %s 中开启和设置。
2. 拾取记录。在 %s -> %s -> EPGP -> %s 中开启和设置。]=]
L["Next award in "] = "距离下次奖励"
L["Non-hunter"] = "非猎人"
L["Non-tank"] = "非坦克"
L["off"] = "关闭"
L["on"] = "打开"
L["Only display GP values for items at or above this quality."] = "仅为达到或超过此品质的物品显示 GP 值。"
L["Open the configuration options"] = "设置选项"
L["Open the debug window"] = "开启调试窗口"
L["Outsiders should be 0 or 1"] = "会外成员支持必须为 0（关闭）或者 1（开启）"
L["OUTSIDERS_DESC"] = [=[1. 假设团队成员 A 不在公会内。
2. 在公会内选择或创建一个小号 B，不限职业、名字、等级。
3. 设定 B 的公开公会备注为：“ext:A-realm”。“realm”是 A 的服务器名。
4. EPGP 会记录在 B 或 B 大号的官员备注内。]=]
L["Paste import data here"] = "粘贴导入数据至此"
L["Personal Action Log"] = "个人操作日志"
L["Please send bid value to raid channel."] = "请将竞标值发至团队频道。"
L["Please send number to raid channel: "] = "请发送数字至团队频道："
L["Please whisper bid value to me."] = "请密语我竞标值。"
L["Please whisper number to me: "] = "请密语我数字："
L["Protect Time (sec)"] = "保护时间（秒）"
L["Provide a proposed GP value of armor on tooltips. Quest items or tokens that can be traded for armor will also have a proposed GP value."] = "在物品信息提示中提供装备的 GP 建议值。任务物品或可用于交换装备的代币也将有一个 GP 建议值。"
L["Quality threshold"] = "品质阀值"
L["Recommend value before next tier:"] = "下版本建议值："
L["Recommend value in current tier:"] = "当前版本建议值："
L["Recurring"] = "周期奖励"
L["Recurring awards resume"] = "周期性奖励重新开始"
L["Recurring awards start"] = "周期性奖励开始"
L["Recurring awards stop"] = "周期性奖励结束"
L["Redo"] = "重做"
L["Re-scale all main toons' GP to current tier?"] = "重新调整所有大号 GP 到当前级别"
L["Rescale GP"] = "重新调整 GP"
L["Rescale GP of all members of the guild. This will reduce all main toons' GP by a tier worth of value. Use with care!"] = "重新调整所有公会成员 GP。这样做会使所有主号的 GP 下降一个等级。请小心使用！"
L["Reset all main toons' EP and GP to 0?"] = "重置所有主角色的 EP 及 GP 为 0 吗？"
L["Reset all main toons' GP to 0?"] = "重设所有人 GP 为 0 吗？"
L["Reset EPGP"] = "重置 EPGP 分值"
L["Reset GP"] = "重置 GP 分值"
L["Reset only GP"] = "只重设 GP 分值"
L["Reset result when announce and start a bid/need/roll."] = "开始竞标时重置结果。"
L["Reset when announce a bid"] = "开始一项竞标时重置结果"
L["Resets EP and GP of all members of the guild. This will set all main toons' EP and GP to 0. Use with care!"] = "重置全体公会成员的 EP 及 GP，此操作将重置所有主角色的 EP 及 GP 为零。慎重使用！"
L["Resets GP (not EP!) of all members of the guild. This will set all main toons' GP to 0. Use with care!"] = "重设所有工会成员的 GP（不是 EP）。这样做将会使所有主号的 GP 清零。请小心使用！"
L["Resume recurring award (%s) %d EP/%s"] = "重新开始周期性奖励 (%s) %d EP/%s"
L["Select all"] = "全选"
L["Sending: %d / %d"] = "发送中：%d / %d"
L["Set gear points (GP multiplier). Each slot could set up to 3 points. Each points has a custom comment."] = "设定装备分数（GP 系数）；每个部位都可以设定最多三个系数和备注。"
L["Sets loot tracking threshold, to disable the adding on loot below this threshold quality."] = "品质低于设定值的物品不会被加入战利品列表。"
L["Sets loot tracking threshold, to disable the popup on loot below this threshold quality."] = "设置拾取追踪品质阀值，拾取低于设定品质阀值的物品时禁用弹出框。"
L["Sets the announce medium EPGP will use to announce distribution actions."] = "设定 EPGP 用来发布分配信息（需求/贪婪、竞标、roll 点）的频道。"
L["Sets the announce medium EPGP will use to announce EPGP actions."] = "设置用来通告 EPGP 操作的 EPGP 通告媒介。"
L["Sets the custom announce channel name used to announce EPGP actions."] = "设置用来通告EPGP操作的自定义通告频道名称."
L["Sets the medium EPGP will use to collect bid results from members."] = "设定 EPGP 收集团队成员竞标信息的渠道。"
L["Sets the medium EPGP will use to collect need/greed results from members."] = "设定 EPGP 收集团队成员需求/贪婪信息的渠道。"
L["Settings sent from trusted members will be accepted without asking."] = "来自信任成员的设置会被自动同步，不需要经过询问。"
L["SETTINGS_RECEIVED_POPUP_TEXT"] = "收到来自 [%s] 的设置，是否覆盖本地设置？点击 [%s] 将 [%s] 加入信任列表，以后将不再询问。"
L["should be a none-zero integer"] = "应为非零整数"
L["Should be a non-negative integer"] = "应为非负整数"
L["should be a positive integer"] = "应为正整数"
L["Show everyone"] = "显示所有人"
L["Show item level"] = "显示物品等级"
L["Slots"] = "部位"
L["Some english word"] = "一些英语"
L["Some english word that doesn't exist"] = "一些不存在的英语"
L["Standby"] = "待命"
L["Standby for others is NOT allowed. Whisper 'epgp standby' instead."] = "不允许代替他人申请替补，请密语 \"epgp standby\"。"
L["Standby whispers in raid"] = "发送密语的待命人员"
L["Start recurring award (%s) %d EP/%s"] = "开始周期性奖励 (%s) %d EP/%s"
L["Stop recurring award"] = "停止周期性奖励"
L["string1"] = true
L["Sync finished."] = "同步完成。"
L["Sync settings to guild ranks:"] = "向以下公会级别同步设置："
L["Sync to:"] = "同步给："
L["Temple of Ahn'Qiraj"] = "安其拉神殿"
L["The imported data is invalid"] = "导入数据无效"
L["The standby list will be cleared x seconds after each reward."] = "替补名单会在每次群体 EP 奖励一段时间后清空（间隔时间为设定值）。"
L["Time protect"] = "时间保护"
L["To export the current standings, copy the text below and post it to: %s"] = "如要导出当前积分表，复制以下文本并发布至 %s"
L["To restore to an earlier version of the standings, copy and paste the text from: %s"] = "如要还原到一个较早版本的积分表，需从 %s 复制并粘贴文本"
L["Tooltip"] = "鼠标提示"
L["Track loot items"] = "追踪战利品掉落"
L["Trust"] = "信任"
L["Trust list (seperate with ',')"] = "信任名单（以半角逗号“,”分割）"
L["Undo"] = "撤销"
L["unknown argument"] = "未知参数"
L["unknown selection"] = "未知选择"
L["Use custom global configuration"] = "使用自定义全局设置"
L["Using %s for boss kill tracking"] = "使用 %s 以追踪首领击杀。"
L["Value"] = "数值"
L["Web & WeChat Mini Program"] = "网站/微信小程序"
L["When a new tier comes, you may like to increase [standard_ilvl]. That can avoid large gear points. If you do that, a GP rescaling is recommended. Everyone's GP will be changed."] = "新版本更新后，应当提高 [standard_ilvl] 以避免装备 GP 数值过大。如果你提高了 [standard_ilvl]，建议重新调整 GP；每个人的 GP 都会被重设。"
L["WHETHER_TO_START_BOSS_AUTO_REWARD"] = "EPGP：是否开始 BOSS 击杀/团灭自动奖励？"
L["Whisper"] = "密语"
L["wipe"] = "团灭"
L["Wipe awards"] = "灭团奖励"
L["Wiped on %s. Award EP?"] = "在 %s 的战斗中灭团。奖励 EP？"
L["Write into Guild Info"] = "写入公会信息"
L["You can now check your epgp standings and loot on the web: http://www.epgpweb.com"] = "现在你可访问如下网站查阅自己的 epgp 积分和已获得战利品：http://www.epgpweb.com"
L["You may need to deselect \"Show only members\" on EPGP web after uploading."] = "上传后，你可能需要勾掉“Show only members”选项。"
L["You should probably: increase standard_ilvl, reset or rescale GP."] = "你可能需要：提高 standard_ilvl，重置或重新调整 GP。"

--@end-debug@
