local mod = EPGP:NewModule("sync", "AceComm-3.0", "AceEvent-3.0")

local Debug = LibStub("LibDebug-1.0")
local DLG = LibStub("LibDialog-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LUI = LibStub("LibEPGPUI-1.0")
local JSON = LibStub("LibJSON-1.0")
local Utils = LibStub("LibUtils-1.0")

local EDITBOX_HEIGHT = 24

local guildButton
local raidButton
local targetButton
local statusLabel
local trustEditBox

local trust = {}
local receivedSettings = {}

local function SendCommMsgCallback(sender, cur, total)
  if cur < total then
    statusLabel:SetText(L["Sending: %d / %d"]:format(cur, total))
  else
    statusLabel:SetText(L["Sync finished."])
    guildButton:Enable()
    raidButton:Enable()
    targetButton:Enable()
  end
end

local function BoardcastSettings(distribution, target)
  if not CanEditOfficerNote() then
    EPGP:Print(_G.ERR_GUILD_PERMISSIONS)
    return
  end

  guildButton:Disable()
  raidButton:Disable()
  targetButton:Disable()

  local vars = EPGP.db.profile

  local t = {}
  t.ranks = vars.sync.ranks

  t.points = EPGP:GetModule("points").db.profile

  t.customItems = {}
  local customItems = vars.customItems
  for i, v in pairs(customItems) do
    t.customItems[tostring(i)] = v
  end

  t.useCustomGuildOptions = vars.useCustomGuildOptions
  t.outsiders = vars.outsiders
  t.decay_p = vars.decay_p
  t.extras_p = vars.extras_p
  t.base_gp = vars.base_gp
  t.min_ep = vars.min_ep

  mod:SendCommMessage("EPGP.sync", JSON.Serialize(t), distribution, target, "NORMAL", SendCommMsgCallback)
end

local function MsgReceiver(prefix, msg, distribution, sender)
  if sender == UnitName("player") then return end
  local sender = Ambiguate(sender, "none")
  local success, t = pcall(JSON.Deserialize, msg)
  if success then
    local rankIndex = select(3, GetGuildInfo("player"))
    if not rankIndex then return end
    rankIndex = rankIndex + 1
    if not t.ranks[rankIndex] then return end

    Utils:PrintTable(t)
    receivedSettings[sender] = t

    if trust[sender] then
      mod:AcceptSettings(sender)
    else
      DLG:Spawn("EPGP_SETTINGS_RECEIVED", sender)
    end
  end
end

local function CheckboxGuildRankOnShowFunc(self)
  local vars = EPGP.db.profile.sync.ranks
  local index = self.index
  if vars[index] == nil then vars[index] = false end

  self:SetChecked(vars[index])
end

local function CheckboxGuildRankOnClickFunc(self)
  EPGP.db.profile.sync.ranks[self.index] = self:GetChecked()
end

local function AddGuildRank(f, anchor, index)
  local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
  cb:SetWidth(20)
  cb:SetHeight(20)
  cb:SetPoint("TOP", anchor, "BOTTOM")
  cb:SetPoint("LEFT", 15, 0)
  cb:SetScript("OnShow", CheckboxGuildRankOnShowFunc)
  cb:SetScript("OnClick", CheckboxGuildRankOnClickFunc)
  cb.index = index

  local l = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  l:SetText(GuildControlGetRankName(index))
  l:SetPoint("LEFT", cb, "RIGHT")

  return cb
end

local function UpdateTrustListFromLocalVars()
  local arr = {}
  for i, v in pairs(trust) do
    table.insert(arr, i)
  end
  table.sort(arr)
  local s = Utils:Join(",", arr)
  EPGP.db.profile.sync.trust = s
  if trustEditBox then
    trustEditBox:SetText(s)
  end
end

local function UpdateTrustListFromSavedVars()
  local s = EPGP.db.profile.sync.trust
  local arr = { string.split(",", s) }
  table.sort(arr)
  table.wipe(trust)
  for i = 1, #arr do
    local name = string.trim(arr[i])
    if name and name ~= "" then
      trust[name] = true
    end
  end
  if trustEditBox then
    trustEditBox:SetText(s)
  end
end

local function UpdateTrustListFromEditBox()
  local s = trustEditBox:GetText()
  local arr = { string.split(",", s) }
  table.sort(arr)
  s = Utils:Join(",", arr)
  table.wipe(trust)
  for i = 1, #arr do
    local name = string.trim(arr[i])
    if name and name ~= "" then
      trust[name] = true
    end
  end
  UpdateTrustListFromLocalVars()
end

local function ClearTrustList()
  trustEditBox:SetText("")
  table.wipe(trust)
  EPGP.db.profile.sync.trust = ""
end

function mod:AddTrustList(name)
  if not name or name == "" or trust[name] then return end
  trust[name] = true
  UpdateTrustListFromLocalVars()
  EPGP:Print(L["[%s] has been added into trust list."]:format(name))
end

function mod:AcceptSettings(name)
  local t = receivedSettings[name]
  if not t then return end
  EPGP:Print(L["Accepting settings from [%s]..."]:format(name))

  Utils:CopyTable(t.points, EPGP:GetModule("points").db.profile)
  EPGP:Print(L["[%s] has been updated."]:format(L["Gear Points"]))

  local customItems = EPGP.db.profile.customItems
  table.wipe(customItems)
  for i, v in pairs(t.customItems) do
    local id = tonumber(i)
    customItems[id] = {}
    Utils:CopyTable(v, customItems[id])
  end
  EPGP:GetModule("optionsCustomItems"):Reload()
  EPGP:Print(L["[%s] has been updated."]:format(L["%s %s"]:format(_G.CUSTOM, _G.ITEMS)))

  EPGP.db.profile.useCustomGuildOptions = t.useCustomGuildOptions
  EPGP:SetOutdisers(t.outsiders)
  EPGP:SetDecayPercent(t.decay_p)
  EPGP:SetExtrasPercent(t.extras_p)
  EPGP:SetBaseGP(t.base_gp)
  EPGP:SetMinEP(t.min_ep)
  EPGP:Print(L["[%s] has been updated."]:format(L["Global configuration"]))

  HideUIPanel(EPGPFrame)
  EPGP:Print(L["Sync finished."])
end

function mod:FillFrame(f, parent)
  local rankLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  rankLabel:SetText(L["Sync settings to guild ranks:"])
  rankLabel:SetPoint("TOPLEFT")

  local top = rankLabel
  local rankCbs = {}
  for i = 1, GuildControlGetNumRanks() do
    top = AddGuildRank(f, top, i)
    table.insert(rankCbs, top)
  end

  local syncLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  syncLabel:SetText(L["Sync to:"])
  syncLabel:SetPoint("TOP", top, "BOTTOM", 0, -15)
  syncLabel:SetPoint("LEFT")

  guildButton = LUI:CreateTextButton(nil, f, _G.GUILD)
  guildButton:SetPoint("TOP", syncLabel, "BOTTOM")
  guildButton:SetPoint("LEFT", 15, 0)
  guildButton:SetScript("OnClick", function(self)
    BoardcastSettings("GUILD")
  end)

  raidButton = LUI:CreateTextButton(nil, f, _G.RAID)
  raidButton:SetPoint("LEFT", guildButton, "RIGHT")
  raidButton:SetScript("OnClick", function(self)
    if UnitInRaid("player") then
      BoardcastSettings("RAID")
    else
      statusLabel:SetText(_G.ERR_NOT_IN_RAID)
    end
  end)

  targetButton = LUI:CreateTextButton(nil, f, _G.TARGET)
  targetButton:SetPoint("LEFT", raidButton, "RIGHT")
  targetButton:SetScript("OnClick", function(self)
    local name = GetUnitName("target", true)
    if not name then
      statusLabel:SetText(_G.ERR_GENERIC_NO_TARGET)
    else
      BoardcastSettings("WHISPER", name)
    end
  end)

  statusLabel = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  statusLabel:SetText("")
  statusLabel:SetPoint("TOP", guildButton, "BOTTOM")
  statusLabel:SetPoint("LEFT", 15, 0)

  local trustLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  trustLabel:SetText(L["Trust list (seperate with ',')"])
  trustLabel:SetPoint("TOP", statusLabel, "BOTTOM", 0, -15)
  trustLabel:SetPoint("LEFT")

  trustEditBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  trustEditBox:SetFontObject("GameFontHighlightSmall")
  trustEditBox:SetHeight(EDITBOX_HEIGHT)
  trustEditBox:SetAutoFocus(false)
  trustEditBox:SetPoint("TOP", trustLabel, "BOTTOM")
  trustEditBox:SetPoint("LEFT", 15, 0)
  trustEditBox:SetPoint("RIGHT")

  local acceptTrustButton = LUI:CreateTextButton(nil, f, _G.ACCEPT, true)
  acceptTrustButton:SetPoint("TOP", trustEditBox, "BOTTOM")
  acceptTrustButton:SetPoint("LEFT", 15, 0)
  acceptTrustButton:Disable()
  acceptTrustButton:SetScript("OnClick", function(self)
    UpdateTrustListFromEditBox()
    trustEditBox:ClearFocus()
    self:Disable()
  end)

  trustEditBox:SetScript("OnTextChanged", function(self)
    if trustEditBox:GetText() == EPGP.db.profile.sync.trust then
      acceptTrustButton:Disable()
    else
      acceptTrustButton:Enable()
    end
  end)

  local clearTrustButton = LUI:CreateTextButton(nil, f, L["Clear"])
  clearTrustButton:SetPoint("LEFT", acceptTrustButton, "RIGHT")
  clearTrustButton:SetScript("OnClick", ClearTrustList)

  local trustDescLabel = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  trustDescLabel:SetJustifyH("LEFT")
  trustDescLabel:SetText(L["Settings sent from trusted members will be accepted without asking."])
  trustDescLabel:SetPoint("TOP", acceptTrustButton, "BOTTOM")
  trustDescLabel:SetPoint("LEFT", 15, 0)
  trustDescLabel:SetPoint("RIGHT")

  f:SetWidth(400)
  local height = 70 +
    rankLabel:GetHeight() * 3 +
    rankCbs[1]:GetHeight() * #rankCbs +
    guildButton:GetHeight() * 2 +
    trustEditBox:GetHeight() +
    trustDescLabel:GetHeight()
  f:SetHeight(height)
  f:Hide()

  f.OnShowFunc = function(self)
    for i = 1, #rankCbs do
      CheckboxGuildRankOnShowFunc(rankCbs[i])
    end
    UpdateTrustListFromSavedVars()

    parent.UpdateSize(400, height)
  end
end

function mod:OnInitialize()
end

function mod:OnEnable()
  if not EPGP.db.profile.sync then
    EPGP.db.profile.sync = {}
  end
  if not EPGP.db.profile.sync.ranks then
    EPGP.db.profile.sync.ranks = {}
  end
  if not EPGP.db.profile.sync.trust then
    EPGP.db.profile.sync.trust = ""
  end
  UpdateTrustListFromSavedVars()
  self:RegisterComm("EPGP.sync", MsgReceiver)
end

function mod:OnDisable()
end
