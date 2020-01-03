local mod = EPGP:NewModule("optionsCustomItems")

local GP = LibStub("LibGearPoints-1.2")
local GUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LIU = LibStub("LibItemUtils-1.0")
local LN = LibStub("LibLocalConstant-1.0")

local LOCAL_NAME = LN:LocalName()

local BUTTON_TEXT_PADDING = 15
local BUTTON_HEIGHT = 22
local ITEM_FRAME_PADDING = 5
local ITEM_FRAME_HEIGHT = 41 + ITEM_FRAME_PADDING

local CUSTOM_ITEM_DATA = GP:GetCustomItemsDefault()
local MAX_ITEMS_PER_PAGE = 10

local addFrame
local containerFrame
local itemFrames = {}
local itemIndex = {}

function EPGP:SearchG(s)
  for i, v in pairs(_G) do
    if v == s then
      print(i)
    end
  end
end

local columnWidth = {
  rarity      = 70,
  level       = 50,
  equipLocKey = 150,
  scale       = 50,
  scale2      = 50,
  gp          = 50,
  gp2         = 50,
}
local columnWidthTotal = 36
for i, v in pairs(columnWidth) do
  columnWidthTotal = columnWidthTotal + v
end

local function ItemQualityDescColored(r)
  return "|c" ..
         select(4, GetItemQualityColor(r)) ..
         _G["ITEM_QUALITY" .. r .. "_DESC"] ..
         "|r"
end

local RARITY_DEFAULT = 4
local rarityList = {
  [0] = ItemQualityDescColored(0), -- 粗糙 Poor
  [1] = ItemQualityDescColored(1), -- 普通 Common
  [2] = ItemQualityDescColored(2), -- 优秀 Uncommon
  [3] = ItemQualityDescColored(3), -- 精良 Rare
  [4] = ItemQualityDescColored(4), -- 史诗 Epic
  [5] = ItemQualityDescColored(5), -- 传说 Legendary
  [6] = ItemQualityDescColored(6), -- 神器 Artifact
}

local EQUIPLOC_CUSTOM_SCALE_INDEX = 98
local EQUIPLOC_CUSTOM_GP_INDEX = 99
local EQUIPLOC_DATA = {
  [1]  = {INVTYPE_HEAD, "INVTYPE_HEAD"},
  [2]  = {INVTYPE_NECK, "INVTYPE_NECK"},
  [3]  = {INVTYPE_SHOULDER, "INVTYPE_SHOULDER"},
  [4]  = {INVTYPE_CHEST, "INVTYPE_CHEST"},
  [5]  = {INVTYPE_WAIST, "INVTYPE_WAIST"},
  [6]  = {INVTYPE_LEGS, "INVTYPE_LEGS"},
  [7]  = {INVTYPE_FEET, "INVTYPE_FEET"},
  [8]  = {INVTYPE_WRIST, "INVTYPE_WRIST"},
  [9]  = {INVTYPE_HAND, "INVTYPE_HAND"},
  [10] = {INVTYPE_FINGER, "INVTYPE_FINGER"},
  [11] = {INVTYPE_TRINKET, "INVTYPE_TRINKET"},
  [12] = {INVTYPE_CLOAK, "INVTYPE_CLOAK"},
  [13] = {INVTYPE_WEAPON, "INVTYPE_WEAPON"},
  [14] = {INVTYPE_SHIELD, "INVTYPE_SHIELD"},
  [15] = {INVTYPE_2HWEAPON, "INVTYPE_2HWEAPON"},
  [16] = {INVTYPE_WEAPONMAINHAND, "INVTYPE_WEAPONMAINHAND"},
  [17] = {INVTYPE_WEAPONOFFHAND, "INVTYPE_WEAPONOFFHAND"},
  [18] = {INVTYPE_HOLDABLE, "INVTYPE_HOLDABLE"},
  [19] = {INVTYPE_RANGED, "INVTYPE_RANGED"},
  [20] = {LOCAL_NAME.Wand, "INVTYPE_WAND"},
  [21] = {LOCAL_NAME.Thrown, "INVTYPE_THROWN"},
  [22] = {INVTYPE_RELIC, "INVTYPE_RELIC"},
  [EQUIPLOC_CUSTOM_SCALE_INDEX] = {"Custom Scale", "CUSTOM_SCALE"},
  [EQUIPLOC_CUSTOM_GP_INDEX] = {"Custom GP", "CUSTOM_GP"},
}

local EQUIPLOC_NAME = {}
local EQUIPLOC_INDEX = {}
local function GenerateEquipLocData()
  local index = {}
  for i, v in pairs(EQUIPLOC_DATA) do
    table.insert(index, i)
    local equipLocKey = EQUIPLOC_DATA[i][2]
    if equipLocKey then
      EQUIPLOC_INDEX[equipLocKey] = i
    end
  end
  table.sort(index)
  for i = 1, #index do
    EQUIPLOC_NAME[index[i]] = EQUIPLOC_DATA[index[i]][1]
  end
end
GenerateEquipLocData()

local function UpdateItemIndex()
  local customItems = EPGP.db.profile.customItems
  table.wipe(itemIndex)
  for id in pairs(customItems) do
    table.insert(itemIndex, id)
  end
  table.sort(itemIndex)
end

local function UpdateAddFrameIconAndLink()
  addFrame.addButton:Disable()
  local id = addFrame.id
  local _, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(id)
  if itemLink and itemTexture then
    if addFrame.link ~= itemLink then
      addFrame.link = itemLink
      addFrame.selectItemF.text:SetText(itemLink)
    end
    addFrame.iconF:SetTexture(itemTexture)
    addFrame.texture = itemTexture
    if not EPGP.db.profile.customItems[id] then
      addFrame.addButton:Enable()
    end
  else
    LIU:CacheItem(id, UpdateAddFrameIconAndLink)
  end
end

local function UpdateOneItemScaleAndGP(f)
  local item = EPGP.db.profile.customItems[f.id]
  f.ilvlF:SetText(item.ilvl or 0)
  if item.equipLocKey == EQUIPLOC_CUSTOM_SCALE_INDEX then
    local gp1, gp2 =
      GP:CalculateGPFromScale(item.s1, item.s2, nil, item.ilvl, item.rarity)
    item.gp1 = gp1
    item.gp2 = gp2
    f.gp1F:SetText(gp1 or "")
    f.gp2F:SetText(gp2 or "")
  elseif item.equipLocKey == EQUIPLOC_CUSTOM_GP_INDEX then
  else
    local gp1, _, gp2, _, _, _, s1, s2 =
      GP:CalculateGPFromEquipLoc(EQUIPLOC_DATA[item.equipLocKey][2], nil, item.ilvl, item.rarity)
    item.s1 = s1
    item.s2 = s2
    item.gp1 = gp1
    item.gp2 = gp2
    f.s1F:SetText(s1 or "")
    f.s2F:SetText(s2 or "")
    f.gp1F:SetText(gp1 or "")
    f.gp2F:SetText(gp2 or "")
  end
end

local function EquipLocOnValueChangedFunc(self, event, key)
  local f = self:GetUserData("f")
  local item = EPGP.db.profile.customItems[f.id]
  item.equipLocKey = key
  item.equipLoc = EQUIPLOC_DATA[key][2]
  if key == EQUIPLOC_CUSTOM_SCALE_INDEX then
    f.rarityF:SetDisabled(false)
    f.ilvlF:Enable()
    f.s1F:Enable()
    f.s2F:Enable()
    f.gp1F:Disable()
    f.gp2F:Disable()
  elseif key == EQUIPLOC_CUSTOM_GP_INDEX then
    f.rarityF:SetDisabled(true)
    f.ilvlF:Disable()
    f.s1F:Disable()
    f.s2F:Disable()
    f.gp1F:Enable()
    f.gp2F:Enable()
  else
    f.rarityF:SetDisabled(false)
    f.ilvlF:Enable()
    f.s1F:Disable()
    f.s2F:Disable()
    f.gp1F:Disable()
    f.gp2F:Disable()
  end
  UpdateOneItemScaleAndGP(f)
end

local function ValidNumber(str, allowFloat)
  local num = tonumber(str)
  if not num or num < 0 then return nil end
  if allowFloat then
    return num
  else
    return math.floor(num)
  end
end

local function EditBoxNumberOnEditFocusLostFunc(self)
  local f = self:GetParent()
  local varName = self.varName
  local item = EPGP.db.profile.customItems[f.id]
  local text = self:GetText()
  local num = ValidNumber(text, self.allowFloat)
  if self.allowBank and text == "" then
    item[varName] = nil
    UpdateOneItemScaleAndGP(f)
  elseif num then
    item[varName] = num
    self:SetText(num)
    UpdateOneItemScaleAndGP(f)
  else
    self:SetText(item[varName])
  end
  self:HighlightText(0, 0)
end

local function EditBoxNumberOnEnterPressedFunc(self)
  local f = self:GetParent()
  local varName = self.varName
  local item = EPGP.db.profile.customItems[f.id]
  local text = self:GetText()
  local num = ValidNumber(text, self.allowFloat)
  if self.allowBank and text == "" then
    item[varName] = nil
    UpdateOneItemScaleAndGP(f)
    self:ClearFocus()
  elseif num then
    item[varName] = num
    self:SetText(num)
    UpdateOneItemScaleAndGP(f)
    self:ClearFocus()
  end
end

local function EditBoxNumberOnEscapePressedFunc(self)
  EditBoxNumberOnEditFocusLostFunc(self)
  self:ClearFocus()
end

local function ItemIconFrameOnEnterFunc(self)
  local link = self:GetParent().link
  if not link then return end
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", - 3, self:GetHeight() + 6)
  GameTooltip:SetHyperlink(link)
end

local function ItemIconFrameOnLeaveFunc()
  GameTooltip:Hide()
end

local function EditBoxIdOnValueChangedFunc(self)
  if not self:HasFocus() then return end  -- Caused by dropdown
  local f = self:GetParent()
  f.addButton:Disable()
  local num = tonumber(self:GetText())
  if not num then return end    -- Unvalid
  if num <= 0 then return end   -- Not positive
  local id = math.floor(num)
  if id ~= num then return end  -- Not integer
  if num == f.id then f.addButton:Enable(); return end

  f.id = id
  f.link = nil
  f.iconF:SetTexture()
  f.selectItemF.text:SetText()
  UpdateAddFrameIconAndLink()
end

local function UpdateOneItemFrame(i, id)
  local f = itemFrames[i]
  if not id then
    f:Hide()
    return
  end

  local item = EPGP.db.profile.customItems[id]
  f.id = id
  f.link = item.link or id
  f.iconF:SetTexture(item.texture)
  f.linkF:SetText(item.link or id)
  f.rarityF:SetValue(item.rarity or RARITY_DEFAULT)
  f.ilvlF:SetText(item.ilvl or 0)
  
  item.equipLocKey = item.equipLocKey or EQUIPLOC_CUSTOM_SCALE_INDEX
  item.equipLoc = EQUIPLOC_DATA[item.equipLocKey][2]
  f.equipLocF:SetValue(item.equipLocKey)
  EquipLocOnValueChangedFunc(f.equipLocF, "OnValueChanged", item.equipLocKey)
  if item.equipLocKey == EQUIPLOC_CUSTOM_SCALE_INDEX then
    f.s1F:SetText(item.s1 or "")
    f.s2F:SetText(item.s2 or "")
    UpdateOneItemScaleAndGP(f)
  elseif item.equipLocKey == EQUIPLOC_CUSTOM_GP_INDEX then
    f.s1F:SetText(item.s1 or "")
    f.s2F:SetText(item.s2 or "")
    f.gp1F:SetText(item.gp1 or "")
    f.gp2F:SetText(item.gp2 or "")
  else
    UpdateOneItemScaleAndGP(f)
  end
  f:Show()
end

local function UpdateFrame()
  local offset = FauxScrollFrame_GetOffset(OptionsCustomItemsSrollFrame)
  for i = 1, MAX_ITEMS_PER_PAGE do
    UpdateOneItemFrame(i, itemIndex[i + offset])
  end
  FauxScrollFrame_Update(OptionsCustomItemsSrollFrame, math.max(1, #itemIndex), MAX_ITEMS_PER_PAGE, ITEM_FRAME_HEIGHT)
end

local function AddCustomItem(id, link, texture)
  local customItems = EPGP.db.profile.customItems
  if customItems[id] then
    return
  end

  local _, _, itemRarity, itemLevel, _, _, itemSubType, _, itemEquipLoc =
    GetItemInfo(link)
  if itemSubType == LOCAL_NAME.Wand then
    itemEquipLoc = "INVTYPE_WAND"
  end
  local equipLocKey = EQUIPLOC_CUSTOM_SCALE_INDEX
  if itemEquipLoc then
    equipLocKey = EQUIPLOC_INDEX[itemEquipLoc] or EQUIPLOC_CUSTOM_SCALE_INDEX
  end
  customItems[id] = {
    texture = texture,
    ilvl = itemLevel or 0,
    link = link,
    rarity = itemRarity or RARITY_DEFAULT,
    equipLocKey = equipLocKey,
    equipLoc = EQUIPLOC_DATA[equipLocKey][2]
  }
  UpdateItemIndex()
  UpdateFrame()
end

local function ItemRemoveButtonOnClickFunc(self)
  local f = self:GetParent()
  local id = f.id
  local v = CUSTOM_ITEM_DATA[id]
  if not v then
    EPGP.db.profile.customItems[id] = nil
    UpdateItemIndex()
    UpdateFrame()
    return
  end
  local item = EPGP.db.profile.customItems[id]
  item.rarity = v[1]
  item.ilvl = v[2]
  item.equipLocKey = EQUIPLOC_INDEX[v[3]] or EQUIPLOC_CUSTOM_SCALE_INDEX
  item.equipLoc = EQUIPLOC_DATA[item.equipLocKey][2]
  f.equipLocF:SetValue(item.equipLocKey)
  UpdateOneItemScaleAndGP(f)
end

local function CreateAddFrame(parent)
  addFrame = CreateFrame("Frame", nil, parent)
  addFrame:SetPoint("TOPLEFT")
  addFrame:SetPoint("RIGHT")

  local iconF = addFrame:CreateTexture(nil, ARTWORK)
  iconF:SetWidth(36)
  iconF:SetHeight(36)
  iconF:SetPoint("TOPLEFT")
  addFrame.iconF = iconF

  local iconFrame = CreateFrame("Frame", nil, addFrame)
  iconFrame:ClearAllPoints()
  iconFrame:SetAllPoints(iconF)
  iconFrame:SetScript("OnEnter", ItemIconFrameOnEnterFunc)
  iconFrame:SetScript("OnLeave", ItemIconFrameOnLeaveFunc)
  iconFrame:EnableMouse(true)

  local selectText = addFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  selectText:SetPoint("TOP")
  selectText:SetPoint("LEFT", iconF, "RIGHT")
  selectText:SetText(_G["CHOOSE"])

  local selectItemF = GUI:Create("Dropdown")
  selectItemF:SetWidth(150)
  selectItemF.frame:SetParent(addFrame)
  selectItemF:SetPoint("TOP", selectText, "BOTTOM")
  selectItemF:SetPoint("LEFT", iconF, "RIGHT")
  selectItemF.text:SetJustifyH("LEFT")
  selectItemF.button:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj) end
    end)
  selectItemF.button:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  selectItemF.button_cover:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj) end
    end)
  selectItemF.button_cover:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  addFrame.selectItemF = selectItemF

  local idText = addFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  idText:SetPoint("TOP")
  idText:SetPoint("LEFT", selectItemF.frame, "RIGHT")
  idText:SetText("ID")

  local idF = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
  idF:SetFontObject("GameFontHighlightSmall")
  -- idF:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  idF:SetAutoFocus(false)
  idF:SetWidth(50)
  idF:SetPoint("TOP", idText, "BOTTOM")
  idF:SetPoint("LEFT", selectItemF.frame, "RIGHT")
  idF:SetScript("OnTextChanged", EditBoxIdOnValueChangedFunc)

  local addButton = CreateFrame("Button", "AddButton", addFrame, "UIPanelButtonTemplate")
  addButton:SetNormalFontObject("GameFontNormalSmall")
  addButton:SetHighlightFontObject("GameFontHighlightSmall")
  addButton:SetDisabledFontObject("GameFontDisableSmall")
  addButton:SetHeight(BUTTON_HEIGHT)
  addButton:SetText(L["Add"])
  addButton:SetWidth(addButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  addButton:SetPoint("BOTTOM")
  addButton:SetPoint("LEFT", idF, "RIGHT")
  addButton:SetScript(
    "OnClick",
    function(self)
      AddCustomItem(addFrame.id, addFrame.link, addFrame.texture)
      iconF:SetTexture()
      selectItemF.text:SetText()
      idF:SetText("")
      idF:ClearFocus()
      self:Disable()
    end)
  addButton:Disable()
  addFrame.addButton = addButton

  addFrame:SetHeight(math.max(36,
    selectText:GetHeight() + selectItemF.frame:GetHeight()))
  
  selectItemF:SetCallback(
    "OnValueChanged",
    function(self, event, ...)
      local itemLink = self.text:GetText()
      if itemLink and itemLink ~= "" then
        addFrame.id = LIU:ItemlinkToID(itemLink)
        addFrame.link = itemLink
        idF:SetText(addFrame.id)
        UpdateAddFrameIconAndLink()
      else
        addButton:Disable()
      end
    end)
end

local function AddTitle(f, name, width, top, left)
  local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("TOP", top, "BOTTOM", 0, -ITEM_FRAME_PADDING)
  t:SetText(name)
  t:SetWidth(width)
  if left then
    t:SetPoint("LEFT", left, "RIGHT")
  else
    t:SetPoint("LEFT")
  end
  return t
end

local function AddOneItemFrame(parent, top)
  local f = CreateFrame("Frame", nil, parent)
  f:SetPoint("LEFT")
  f:SetPoint("RIGHT")
  if top then
    f:SetPoint("TOP", top, "BOTTOM", 0, -ITEM_FRAME_PADDING)
  else
    f:SetPoint("TOP", 0, -ITEM_FRAME_PADDING)
  end

  local iconF = f:CreateTexture(nil, ARTWORK)
  iconF:SetWidth(36)
  iconF:SetHeight(36)
  iconF:SetPoint("TOPLEFT")
  f.iconF = iconF

  local iconFrame = CreateFrame("Frame", nil, f)
  iconFrame:ClearAllPoints()
  iconFrame:SetAllPoints(iconF)
  iconFrame:SetScript("OnEnter", ItemIconFrameOnEnterFunc)
  iconFrame:SetScript("OnLeave", ItemIconFrameOnLeaveFunc)
  iconFrame:EnableMouse(true)

  local linkF = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  linkF:SetPoint("TOP")
  linkF:SetPoint("LEFT", iconF, "RIGHT")
  linkF:SetText("12345")
  f.linkF = linkF

  local rarityF = GUI:Create("Dropdown")
  rarityF.frame:SetParent(f)
  rarityF:SetWidth(columnWidth.rarity)
  rarityF:SetPoint("TOPLEFT", linkF, "BOTTOMLEFT")
  rarityF:SetList(rarityList)
  rarityF.text:SetJustifyH("LEFT")
  f.rarityF = rarityF

  local ilvlF = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  ilvlF:SetFontObject("GameFontHighlightSmall")
  -- ilvl:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  ilvlF:SetAutoFocus(false)
  ilvlF:SetWidth(columnWidth.level)
  ilvlF:SetPoint("LEFT", rarityF.frame, "RIGHT")
  ilvlF:SetPoint("TOP", linkF, "BOTTOM")
  ilvlF:SetScript("OnEditFocusLost", EditBoxNumberOnEditFocusLostFunc)
  ilvlF:SetScript("OnEnterPressed", EditBoxNumberOnEnterPressedFunc)
  ilvlF:SetScript("OnEscapePressed", EditBoxNumberOnEscapePressedFunc)
  ilvlF.varName = "ilvl"
  f.ilvlF = ilvlF

  local equipLocF = GUI:Create("Dropdown")
  equipLocF.frame:SetParent(f)
  equipLocF:SetWidth(columnWidth.equipLocKey)
  equipLocF:SetPoint("LEFT", ilvlF, "RIGHT")
  equipLocF:SetPoint("TOP", linkF, "BOTTOM")
  equipLocF:SetList(EQUIPLOC_NAME)
  equipLocF:SetCallback("OnValueChanged", EquipLocOnValueChangedFunc)
  equipLocF:SetUserData("f", f)
  equipLocF.text:SetJustifyH("LEFT")
  f.equipLocF = equipLocF

  local s1F = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  s1F:SetFontObject("GameFontHighlightSmall")
  -- s1F:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  s1F:SetAutoFocus(false)
  s1F:SetWidth(columnWidth.scale)
  s1F:SetPoint("LEFT", equipLocF.frame, "RIGHT")
  s1F:SetPoint("TOP", linkF, "BOTTOM")
  s1F:SetScript("OnEditFocusLost", EditBoxNumberOnEditFocusLostFunc)
  s1F:SetScript("OnEnterPressed", EditBoxNumberOnEnterPressedFunc)
  s1F:SetScript("OnEscapePressed", EditBoxNumberOnEscapePressedFunc)
  s1F.varName = "s1"
  s1F.allowBank = true
  s1F.allowFloat = true
  f.s1F = s1F

  local s2F = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  s2F:SetFontObject("GameFontHighlightSmall")
  -- s2F:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  s2F:SetAutoFocus(false)
  s2F:SetWidth(columnWidth.scale)
  s2F:SetPoint("LEFT", s1F, "RIGHT")
  s2F:SetPoint("TOP", linkF, "BOTTOM")
  s2F:SetScript("OnEditFocusLost", EditBoxNumberOnEditFocusLostFunc)
  s2F:SetScript("OnEnterPressed", EditBoxNumberOnEnterPressedFunc)
  s2F:SetScript("OnEscapePressed", EditBoxNumberOnEscapePressedFunc)
  s2F.varName = "s2"
  s2F.allowBank = true
  s2F.allowFloat = true
  f.s2F = s2F

  local gp1F = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  gp1F:SetFontObject("GameFontHighlightSmall")
  -- gp1F:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  gp1F:SetAutoFocus(false)
  gp1F:SetWidth(columnWidth.gp)
  gp1F:SetPoint("LEFT", s2F, "RIGHT")
  gp1F:SetPoint("TOP", linkF, "BOTTOM")
  gp1F:SetScript("OnEditFocusLost", EditBoxNumberOnEditFocusLostFunc)
  gp1F:SetScript("OnEnterPressed", EditBoxNumberOnEnterPressedFunc)
  gp1F:SetScript("OnEscapePressed", EditBoxNumberOnEscapePressedFunc)
  gp1F.varName = "gp1"
  gp1F.allowBank = true
  f.gp1F = gp1F

  local gp2F = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
  gp2F:SetFontObject("GameFontHighlightSmall")
  -- gp2F:SetHeight(EQUIPLOC_CUSTOM_GP_INDEX)
  gp2F:SetAutoFocus(false)
  gp2F:SetWidth(columnWidth.gp)
  gp2F:SetPoint("LEFT", gp1F, "RIGHT")
  gp2F:SetPoint("TOP", linkF, "BOTTOM")
  gp2F:SetScript("OnEditFocusLost", EditBoxNumberOnEditFocusLostFunc)
  gp2F:SetScript("OnEnterPressed", EditBoxNumberOnEnterPressedFunc)
  gp2F:SetScript("OnEscapePressed", EditBoxNumberOnEscapePressedFunc)
  gp2F.varName = "gp2"
  gp2F.allowBank = true
  f.gp2F = gp2F

  local removeButton = CreateFrame("Button", nil, f)
  removeButton:SetNormalFontObject("GameFontNormalSmall")
  removeButton:SetHighlightFontObject("GameFontHighlightSmall")
  removeButton:SetDisabledFontObject("GameFontDisableSmall")
  removeButton:SetHeight(BUTTON_HEIGHT)
  removeButton:SetWidth(BUTTON_HEIGHT)
  removeButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  removeButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
  removeButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
  removeButton:SetPoint("LEFT", gp2F, "RIGHT")
  removeButton:SetPoint("CENTER")
  removeButton:SetScript("OnClick", ItemRemoveButtonOnClickFunc)

  f:SetHeight(math.max(36, linkF:GetHeight() + rarityF.frame:GetHeight()))
  f:Hide()
  
  return f
end

function mod:FillFrame(f)
  CreateAddFrame(f)

  local t = AddTitle(f, L["Icon"], 36, addFrame)
  -- t = AddTitle(f, "Name", columnWidth.name, addFrame, t)
  t = AddTitle(f, _G["RARITY"], columnWidth.rarity, addFrame, t)
  t = AddTitle(f, _G["LEVEL"], columnWidth.level, addFrame, t)
  t = AddTitle(f, _G["TYPE"], columnWidth.equipLocKey, addFrame, t)
  t = AddTitle(f, "Scale 1", columnWidth.scale, addFrame, t)
  t = AddTitle(f, "Scale 2", columnWidth.scale, addFrame, t)
  t = AddTitle(f, "GP 1", columnWidth.gp, addFrame, t)
  t = AddTitle(f, "GP 2", columnWidth.gp, addFrame, t)
  
  containerFrame = CreateFrame("Frame", nil, f)
  containerFrame:SetPoint("TOP", t, "BOTTOM")
  containerFrame:SetPoint("LEFT")
  containerFrame:SetWidth(columnWidthTotal + 27)
  
  for i = 1, MAX_ITEMS_PER_PAGE do
    if i == 1 then
      itemFrames[1] = AddOneItemFrame(containerFrame)
    else
      itemFrames[i] = AddOneItemFrame(containerFrame, itemFrames[i - 1])
    end
  end
  ITEM_FRAME_HEIGHT = itemFrames[1]:GetHeight() + ITEM_FRAME_PADDING
  containerFrame:SetHeight(ITEM_FRAME_HEIGHT * MAX_ITEMS_PER_PAGE)

  local scrollBar = CreateFrame("ScrollFrame", "OptionsCustomItemsSrollFrame", containerFrame, "FauxScrollFrameTemplateLight")
  scrollBar:SetPoint("TOPLEFT")
  scrollBar:SetPoint("BOTTOMRIGHT")
  scrollBar:SetScript(
    "OnVerticalScroll",
    function(self, value)
      FauxScrollFrame_OnVerticalScroll(
        self, value, ITEM_FRAME_HEIGHT, UpdateFrame)
    end)
  UpdateFrame()
  scrollBar:SetScript("OnShow", UpdateFrame)
  
  f:SetWidth(columnWidthTotal)
  f:SetHeight(addFrame:GetHeight() + t:GetHeight() + containerFrame:GetHeight())
end

local function UpdateItemIconLinkOne(id)
  local item = EPGP.db.profile.customItems[id]
  if not item.texture then
    local _, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(id)
    if itemLink then
      item.link = itemLink
      item.texture = itemTexture
    elseif not item.link then
      item.link = id
      return false
    end
  end
  return true
end

local function UpdateItemIconLink()
  local customItems = EPGP.db.profile.customItems
  local lastUnupgradedId = nil
  for id, v in pairs(customItems) do
    if not UpdateItemIconLinkOne(id) then
      lastUnupgradedId = id
    end
  end
  if lastUnupgradedId then
    LIU:CacheItem(lastUnupgradedId, UpdateItemIconLink)
    if containerFrame and containerFrame:IsShown() then
      UpdateFrame()
    end
  end
end

function mod:OnEnable()
  local vars = EPGP.db.profile
  if not vars.customItems then
    vars.customItems = {}
  end
  local ci = vars.customItems
  local faction = UnitFactionGroup("player")
  for i, v in pairs(CUSTOM_ITEM_DATA) do
    if not v[5] or v[5] == faction then
      if not ci[i] then
        local equipLocKey = EQUIPLOC_INDEX[v[3]] or EQUIPLOC_CUSTOM_SCALE_INDEX
        ci[i] = {
          rarity = v[1],
          ilvl = v[2],
          equipLocKey = equipLocKey,
          equipLoc = EQUIPLOC_DATA[equipLocKey][2]
      }
      end
    else
      ci[i] = nil
    end
  end
  UpdateItemIndex()
  UpdateItemIconLink()
end

function mod:OnDisable()
end
