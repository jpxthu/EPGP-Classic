local mod = EPGP:NewModule("distribution", "AceEvent-3.0")
local C = LibStub("LibEPGPChat-1.0")
local GUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LIU = LibStub("LibItemUtils-1.0")
local LUI = LibStub("LibEPGPUI-1.0")

local BUTTON_TEXT_PADDING = 15
local BUTTON_HEIGHT = 22

local callbacks = EPGP.callbacks

local RANDOM_ROLL_PATTERN = RANDOM_ROLL_RESULT
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("[%(%)%-]", "%%%1")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%s", "%(%.%+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%d", "%(%%d+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$s", "%(%.%+%)") -- for "deDE"
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$d", "%(%%d+%)") -- for "deDE"

local function UISetEnabled(w, enabled)
  if enabled then
    w:Enable()
    w:SetAlpha(1)
  else
    w:Disable()
    w:SetAlpha(0.5)
  end
end

local disableWhileNoAuthority = {}
local function AuthorityChangedCallbackFunc(callback, authority)
  for i, v in pairs(disableWhileNoAuthority) do
    UISetEnabled(v, authority)
  end
end

local function PrAnnouncement(sender, bid)
  if not sender or sender == "" then return end
  local prAnnounceMedium = mod.db.profile.prAnnounceMedium
  if prAnnounceMedium == "NONE" then return end
  local name = EPGP:GetFullCharacterName(sender)
  local ep, gp = EPGP:GetEPGP(name)
  if not ep or not gp then return end
  local pr = ep / math.max(gp, 1)
  local msg = C:Interp(mod.db.profile.prAnnounceMsgFmt, {ep = ep, gp = gp, pr = pr, bid = bid, char = sender})
  if prAnnounceMedium == "RAID" or prAnnounceMedium == "OFFICER" then
    C:Announce(prAnnounceMedium, msg)
  elseif prAnnounceMedium == "WHISPER" then
    C:Whisper(sender, msg)
  end
end

local function HandleChatMsg(event, msg, sender)
  if not EPGP:IsRLorML() then return end
  local bid = tonumber(msg)
  if not bid then return end
  EPGP:HandleBidResult(sender, bid)
  PrAnnouncement(sender, bid)
end

local function HandleRollMsg(event, msg)
  if not EPGP:IsRLorML() then return end

  local name, roll, low, high = string.match(msg, RANDOM_ROLL_PATTERN)
  if not name or not roll or not low or not high then return end

  roll, low, high = tonumber(roll), tonumber(low), tonumber(high)
  EPGP:HandleRollResult(name, roll, low, high)
end

local function HandleBidStatusUpdate(event, status)
  mod:UnregisterAllEvents()
  if status == 1 then
    local needMedium = mod.db.profile.needMedium
    if needMedium == "RAID" then
      mod:RegisterEvent("CHAT_MSG_RAID", HandleChatMsg)
      mod:RegisterEvent("CHAT_MSG_RAID_LEADER", HandleChatMsg)
    elseif needMedium == "WHISPER" then
      mod:RegisterEvent("CHAT_MSG_WHISPER", HandleChatMsg)
    end
  elseif status == 2 then
    local bidMedium = mod.db.profile.bidMedium
    if bidMedium == "RAID" then
      mod:RegisterEvent("CHAT_MSG_RAID", HandleChatMsg)
      mod:RegisterEvent("CHAT_MSG_RAID_LEADER", HandleChatMsg)
    elseif bidMedium == "WHISPER" then
      mod:RegisterEvent("CHAT_MSG_WHISPER", HandleChatMsg)
    end
  elseif status == 3 then
    mod:RegisterEvent("CHAT_MSG_SYSTEM", HandleRollMsg)
  end
end

local function LootItemsAnnounce(itemLinks)
  if not EPGP:IsRLorML() then return end
  local medium = mod.db.profile.announceMedium
  C:Announce(medium, L["Loot list: "] .. table.concat(itemLinks, " "))
end

local function StartBid(itemLink, method)
  if not EPGP:IsRLorML() then return end
  local medium = mod.db.profile.announceMedium
  if method == 1 then
    local needMedium = mod.db.profile.needMedium
    if needMedium == "RAID" then
      C:Announce(medium, itemLink .. " " .. L["Please send number to raid channel: "] .. mod.db.profile.announceNeedMsg)
    elseif needMedium == "WHISPER" then
      C:Announce(medium, itemLink .. " " .. L["Please whisper number to me: "] .. mod.db.profile.announceNeedMsg)
    end
  elseif method == 2 then
    local bidMedium = mod.db.profile.bidMedium
    if bidMedium == "RAID" then
      C:Announce(medium, itemLink .. " " .. L["Please send bid value to raid channel."])
    elseif bidMedium == "WHISPER" then
      C:Announce(medium, itemLink .. " " .. L["Please whisper bid value to me."])
    end
  elseif method == 3 then
    C:Announce(medium, itemLink .. " " .. L["/roll if you want this item. DO NOT roll more than one time."])
  end
  EPGP:SetBidStatus(method, mod.db.profile.resetWhenAnnounce)
end

mod.dbDefaults = {
  profile = {
    enabled = true,
    announceMedium = "RAID",
    needMedium = "RAID",
    bidMedium = "RAID",
    prAnnounceMedium = "RAID",
    announceNeedMsg = "1 - " .. NEED .. " 2 - " .. GREED,
    prAnnounceMsgFmt = "${char} EP:${ep} GP:${gp} PR:${pr}",
    resetWhenAnnounce = true,
    lootAutoAdd = true,
    threshold = 4,
  }
}

mod.optionsName = L["Distribution"]
mod.optionsDesc = L["Collect bid/roll message to help sorting"]
mod.optionsArgs = {
  help = {
    order = 1,
    type = "description",
    name = L["Collect bid/roll message to help sorting"],
    fontSize = "medium",
  },
  announceMedium = {
    order = 10,
    type = "select",
    name = L["Announce medium"],
    desc = L["Sets the announce medium EPGP will use to announce distribution actions."],
    values = {
      ["RAID"] = CHAT_MSG_RAID,
      ["RAID_WARNING"] = CHAT_MSG_RAID_WARNING,
    },
  },
  needMedium = {
    order = 11,
    type = "select",
    name = L["Need/greed medium"],
    desc = L["Sets the medium EPGP will use to collect need/greed results from members."],
    values = {
      ["RAID"] = CHAT_MSG_RAID,
      ["WHISPER"] = CHAT_MSG_WHISPER_INFORM,
    },
  },
  bidMedium = {
    order = 12,
    type = "select",
    name = L["Bid medium"],
    desc = L["Sets the medium EPGP will use to collect bid results from members."],
    values = {
      ["RAID"] = CHAT_MSG_RAID,
      ["WHISPER"] = CHAT_MSG_WHISPER_INFORM,
    },
  },
  prAnnounceMedium = {
    order = 13,
    type = "select",
    name = L["EP/GP/PR announce medium"],
    desc = L["Announce EP/GP/PR when a member need/greed/bid"],
    values = {
      ["NONE"] = NONE,
      ["RAID"] = CHAT_MSG_RAID,
      ["WHISPER"] = CHAT_MSG_WHISPER_INFORM,
      ["OFFICER"] = CHAT_MSG_OFFICER,
    },
  },
  prAnnounceMsgFmt = {
    order = 14,
    type = "input",
    name = L["DIST_ANNOUNCE_PR_FMT_NAME"],
    desc = L["DIST_ANNOUNCE_PR_FMT_DESC"],
    width = 100 ,
  },
  -- spacer1 = LUI:OptionsSpacer(13, 0.001),
  announceNeedMsg = {
    order = 20,
    type = "input",
    name = L["Announce need message"],
    desc = L["Message announced when you start a need/greed bid."],
    width = 100,
  },
  -- spacer2 = LUI:OptionsSpacer(21, 0.001),
  resetWhenAnnounce = {
    order = 30,
    type = "toggle",
    name = L["Reset when announce a bid"],
    desc = L["Reset result when announce and start a bid/need/roll."],
    width = 30,
  },
  -- spacer3 = LUI:OptionsSpacer(31, 0.001),
  lootAutoAdd = {
    order = 40,
    type = "toggle",
    name = L["Track loot items"],
    desc = L["Add loot items automatically when loot windows opened or corpse loot received."],
  },
  spacer4 = LUI:OptionsSpacer(41, 0.001),
  threshold = {
    order = 50,
    type = "select",
    name = L["Loot tracking threshold"],
    desc = L["Sets loot tracking threshold, to disable the adding on loot below this threshold quality."],
    values = {
      [2] = ITEM_QUALITY2_DESC,
      [3] = ITEM_QUALITY3_DESC,
      [4] = ITEM_QUALITY4_DESC,
      [5] = ITEM_QUALITY5_DESC,
    },
  },
}

local lootItem = {
  links = {},
  linkMap = {},
  count = 0,
  currentPage = 1,
  frame = nil,
  ITEMS_PER_PAGE = 10,
  MAX_COUNT = 200,
  FULL_WARNING_COUNT = 190
}

local function LootItemIconFrameOnEnterFunc(self)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", - 3, self:GetHeight() + 6)
  GameTooltip:SetHyperlink(self:GetParent().itemLink)
end

local function LootItemIconFrameOnLeaveFunc()
  GameTooltip:Hide()
end

local function AddLootControlItems(frame, topItem, index)
  local authority = CanEditOfficerNote()

  local f = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate");
  f:SetPoint("LEFT")
  f:SetPoint("RIGHT")
  f:SetPoint("TOP", topItem, "BOTTOMLEFT")

  local icon = f:CreateTexture(nil, ARTWORK)
  icon:SetWidth(36)
  icon:SetHeight(36)
  icon:SetPoint("LEFT")
  icon:SetPoint("TOP")

  local iconFrame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate");
  iconFrame:ClearAllPoints()
  iconFrame:SetAllPoints(icon)
  iconFrame:SetScript("OnEnter", LootItemIconFrameOnEnterFunc)
  iconFrame:SetScript("OnLeave", LootItemIconFrameOnLeaveFunc)
  iconFrame:EnableMouse(true)

  local name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  name:SetPoint("TOP")
  name:SetPoint("LEFT", icon, "RIGHT")

  local needButton = CreateFrame("Button", nil, f)
  needButton:SetNormalFontObject("GameFontNormalSmall")
  needButton:SetHighlightFontObject("GameFontHighlightSmall")
  needButton:SetDisabledFontObject("GameFontDisableSmall")
  needButton:SetHeight(BUTTON_HEIGHT)
  needButton:SetWidth(BUTTON_HEIGHT)
  needButton:SetNormalTexture("Interface\\CURSOR\\OPENHAND")
  needButton:SetHighlightTexture("Interface\\CURSOR\\openhandglow")
  needButton:SetPushedTexture("Interface\\CURSOR\\OPENHAND")
  needButton:SetPoint("LEFT", icon, "RIGHT")
  needButton:SetPoint("BOTTOM")
  UISetEnabled(needButton, authority)
  table.insert(disableWhileNoAuthority, needButton)

  local bidButton = CreateFrame("Button", nil, f)
  bidButton:SetNormalFontObject("GameFontNormalSmall")
  bidButton:SetHighlightFontObject("GameFontHighlightSmall")
  bidButton:SetDisabledFontObject("GameFontDisableSmall")
  bidButton:SetHeight(BUTTON_HEIGHT)
  bidButton:SetWidth(BUTTON_HEIGHT)
  bidButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
  bidButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")
  bidButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Down")
  bidButton:SetPoint("LEFT", needButton, "RIGHT")
  bidButton:SetPoint("BOTTOM", 0, -2)
  UISetEnabled(bidButton, authority)
  table.insert(disableWhileNoAuthority, bidButton)

  local rollButton = CreateFrame("Button", nil, f)
  rollButton:SetNormalFontObject("GameFontNormalSmall")
  rollButton:SetHighlightFontObject("GameFontHighlightSmall")
  rollButton:SetDisabledFontObject("GameFontDisableSmall")
  rollButton:SetHeight(BUTTON_HEIGHT)
  rollButton:SetWidth(BUTTON_HEIGHT)
  rollButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
  rollButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
  rollButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
  rollButton:SetPoint("LEFT", bidButton, "RIGHT")
  rollButton:SetPoint("BOTTOM", 0, -1)
  UISetEnabled(rollButton, authority)
  table.insert(disableWhileNoAuthority, rollButton)

  local bankButton = CreateFrame("Button", nil, f)
  bankButton:SetNormalFontObject("GameFontNormalSmall")
  bankButton:SetHighlightFontObject("GameFontHighlightSmall")
  bankButton:SetDisabledFontObject("GameFontDisableSmall")
  bankButton:SetHeight(BUTTON_HEIGHT)
  bankButton:SetWidth(BUTTON_HEIGHT)
  bankButton:SetNormalTexture("Interface\\MINIMAP\\Minimap_chest_normal")
  bankButton:SetHighlightTexture("Interface\\MINIMAP\\Minimap_chest_elite")
  bankButton:SetPushedTexture("Interface\\MINIMAP\\Minimap_chest_normal")
  bankButton:SetPoint("LEFT", rollButton, "RIGHT")
  bankButton:SetPoint("BOTTOM", 0, -1)
  UISetEnabled(bankButton, authority)
  table.insert(disableWhileNoAuthority, bankButton)

  local removeButton = CreateFrame("Button", nil, f)
  removeButton:SetNormalFontObject("GameFontNormalSmall")
  removeButton:SetHighlightFontObject("GameFontHighlightSmall")
  removeButton:SetDisabledFontObject("GameFontDisableSmall")
  removeButton:SetHeight(BUTTON_HEIGHT)
  removeButton:SetWidth(BUTTON_HEIGHT)
  removeButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  removeButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
  removeButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
  removeButton:SetPoint("LEFT", bankButton, "RIGHT")
  removeButton:SetPoint("BOTTOM")
  removeButton:Enable()

  f.index = index
  f.icon = icon
  f.iconFrame = iconFrame
  f.name = name
  f.needButton = needButton
  f.bidButton = bidButton
  f.rollButton = rollButton
  f.bankButton = bankButton
  f.removeButton = removeButton

  f:SetHeight(icon:GetHeight())
  f:Hide()

  return f
end

local function SetLootControlItem(frame, itemLink)
  if not itemLink or itemLink == "" then
    frame:Hide()
    return
  end

  local itemIcon = select(10, GetItemInfo(itemLink))
  frame.itemLink = itemLink
  frame.icon:SetTexture(itemIcon)
  frame.name:SetText(itemLink)
  frame:Show()
end

local function LootControlsUpdate()
  local frame = lootItem.frame
  if not frame or not frame.initiated then return end

  local itemsN = lootItem.count
  local pageMax = math.max(math.ceil(itemsN / lootItem.ITEMS_PER_PAGE), 1)
  if itemsN > 0 then
    frame.clearButton:Enable()
  else
    frame.clearButton:Disable()
  end
  if lootItem.currentPage >= pageMax then
    lootItem.currentPage = pageMax
    frame.nextPageButton:Disable()
  else
    frame.nextPageButton:Enable()
  end
  if lootItem.currentPage == 1 then
    frame.lastPageButton:Disable()
  else
    frame.lastPageButton:Enable()
  end

  local baseN = (lootItem.currentPage - 1) * lootItem.ITEMS_PER_PAGE

  local showN = math.min(itemsN - baseN, lootItem.ITEMS_PER_PAGE)
  for i = 1, showN do
    SetLootControlItem(frame.items[i], lootItem.links[i + baseN])
  end
  for i = showN + 1, lootItem.ITEMS_PER_PAGE do
    SetLootControlItem(frame.items[i])
  end
end

local function LootItemsAdd(itemLink)
  if not itemLink or itemLink == "" then return end

  if lootItem.linkMap[itemLink] then return end
  if lootItem.count >= lootItem.MAX_COUNT then
    EPGP:Print(L["Loot list is full (%d). %s will not be added into list."]:format(lootItem.MAX_COUNT, itemLink))
    return
  end

  lootItem.linkMap[itemLink] = true
  table.insert(lootItem.links, itemLink)
  table.insert(EPGP.db.profile.lootItemLinks, itemLink)
  lootItem.count = lootItem.count + 1
  lootItem.currentPage = math.ceil(lootItem.count / lootItem.ITEMS_PER_PAGE)
  LootControlsUpdate()
  if lootItem.count >= lootItem.FULL_WARNING_COUNT then
    EPGP:Print(L["Loot list is almost full (%d/%d)."]:format(lootItem.count, lootItem.MAX_COUNT))
  end
end

local function LootItemsClear()
  table.wipe(lootItem.linkMap)
  table.wipe(lootItem.links)
  table.wipe(EPGP.db.profile.lootItemLinks)
  lootItem.count = 0
  lootItem.currentPage = 1
  LootControlsUpdate()
  EPGP:SetBidStatus(0)
end

local function LootItemsRemove(index)
  if not index or index < 1 or index > lootItem.count then return end
  lootItem.linkMap[lootItem.links[index]] = nil
  table.remove(lootItem.links, index)
  table.remove(EPGP.db.profile.lootItemLinks, index)
  lootItem.count = lootItem.count - 1
  LootControlsUpdate()
end

local function LootItemsResume()
  local vars = EPGP.db.profile
  if not vars.lootItemLinks then
    vars.lootItemLinks = {}
    return
  end
  for i, v in pairs(vars.lootItemLinks) do
    lootItem.linkMap[v] = true
    table.insert(lootItem.links, v)
  end
  lootItem.count = #lootItem.links
end

local function LootItemNeedButtonOnClick(bt)
  local itemLink = bt:GetParent().itemLink
  StartBid(itemLink, 1)
end

local function LootItemBidButtonOnClick(bt)
  local itemLink = bt:GetParent().itemLink
  StartBid(itemLink, 2)
end

local function LootItemRollButtonOnClick(bt)
  local itemLink = bt:GetParent().itemLink
  StartBid(itemLink, 3)
end

local function LootItemRemoveButtonOnClick(bt)
  local index = bt:GetParent().index
  LootItemsRemove(index + (lootItem.currentPage - 1) * lootItem.ITEMS_PER_PAGE)
end

local function LootItemBankButtonOnClick(bt)
  local itemLink = bt:GetParent().itemLink
  EPGP:BankItem(itemLink)
  LootItemRemoveButtonOnClick(bt)
end

local function ItemPassRarityThreshold(itemLink)
  if not itemLink then return false end

  local itemId = LIU:ItemlinkToID(itemLink)
  if not itemId then return false end
  if EPGP.db.profile.customItems[itemId] then return true end

  local itemRarity = select(3, GetItemInfo(itemLink))
  if not itemRarity then return false end
  if itemRarity < mod.db.profile.threshold then return false end

  return true
end

local function CorpseLootReceivedHandler(event, itemLink)
  if not EPGP:IsRLorML() then return end
  if not itemLink or itemLink == "" then return end
  if not ItemPassRarityThreshold(itemLink) then return end
  LootItemsAdd(itemLink)
end

local function LootWindowHandler(event, loots)
  if not EPGP:IsRLorML() then return end
  if not loots then return end
  local added = false
  for i, itemLink in pairs(loots) do
    if ItemPassRarityThreshold(itemLink) then
      LootItemsAdd(itemLink)
      added = true
    end
  end
  if added and mod.db.profile.autoPop then
    EPGP:ShowDistrubutionFrame()
  end
end

function mod:FillFrame(frame)
  lootItem.frame = frame

  local autoPop = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
  autoPop:SetWidth(20)
  autoPop:SetHeight(20)
  autoPop:SetPoint("TOPLEFT")
  autoPop.OnShow =
    function(w)
      w:SetChecked(mod.db.profile.autoPop or false)
    end
  autoPop:SetScript(
    "OnClick",
    function(w)
      mod.db.profile.autoPop = w:GetChecked()
    end)
  frame.autoPop = autoPop

  local autoPopLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  autoPopLabel:SetText(L["Auto popup"])
  autoPopLabel:SetPoint("LEFT", autoPop, "RIGHT", 0, 2)

  local dropDown = GUI:Create("Dropdown")
  dropDown:SetWidth(150)
  dropDown.frame:SetParent(frame)
  dropDown:SetPoint("TOPLEFT", autoPop, "BOTTOMLEFT")
  dropDown.text:SetJustifyH("LEFT")
  dropDown:SetCallback(
    "OnValueChanged",
    function(self, event, ...)
      local itemLink = self.text:GetText()
      if itemLink and itemLink ~= "" then
        frame.addButton:Enable()
      else
        frame.addButton:Disable()
      end
    end)
  dropDown.button:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj) end
    end)
  dropDown.button:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  dropDown.button_cover:HookScript(
    "OnMouseDown",
    function(self)
      if not self.obj.open then EPGP:ItemCacheDropDown_SetList(self.obj) end
    end)
  dropDown.button_cover:HookScript(
    "OnClick",
    function(self)
      if self.obj.open then self.obj.pullout:SetWidth(285) end
    end)
  dropDown:SetCallback(
    "OnEnter",
    function(self)
      local itemLink = self.text:GetText()
      if itemLink then
        local anchor = self.open and self.pullout.frame or self.frame:GetParent()
        GameTooltip:SetOwner(anchor, "ANCHOR_RIGHT", 5)
        GameTooltip:SetHyperlink(itemLink)
      end
    end)
  dropDown:SetCallback("OnLeave", function() GameTooltip:Hide() end)

  local addButton = CreateFrame("Button", "addButton", frame, "UIPanelButtonTemplate")
  addButton:SetNormalFontObject("GameFontNormalSmall")
  addButton:SetHighlightFontObject("GameFontHighlightSmall")
  addButton:SetDisabledFontObject("GameFontDisableSmall")
  addButton:SetHeight(BUTTON_HEIGHT)
  addButton:SetText(_G.ADD)
  addButton:SetWidth(addButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  addButton:SetPoint("LEFT", dropDown.frame, "RIGHT")
  addButton:Disable()
  addButton:SetScript("OnClick", function(self) LootItemsAdd(dropDown.text:GetText()) end)

  local clearButton = CreateFrame("Button", "clearButton", frame, "UIPanelButtonTemplate")
  clearButton:SetNormalFontObject("GameFontNormalSmall")
  clearButton:SetHighlightFontObject("GameFontHighlightSmall")
  clearButton:SetDisabledFontObject("GameFontDisableSmall")
  clearButton:SetHeight(BUTTON_HEIGHT)
  clearButton:SetText(L["Clear"])
  clearButton:SetWidth(clearButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  clearButton:SetPoint("TOP", dropDown.frame, "BOTTOM")
  clearButton:SetPoint("LEFT")
  clearButton:Disable()
  clearButton:SetScript("OnClick", LootItemsClear)

  local resetButton = CreateFrame("Button", "resetButton", frame, "UIPanelButtonTemplate")
  resetButton:SetNormalFontObject("GameFontNormalSmall")
  resetButton:SetHighlightFontObject("GameFontHighlightSmall")
  resetButton:SetDisabledFontObject("GameFontDisableSmall")
  resetButton:SetHeight(BUTTON_HEIGHT)
  resetButton:SetText(_G.RESET)
  resetButton:SetWidth(resetButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  resetButton:SetPoint("LEFT", clearButton, "RIGHT")
  resetButton:Enable()
  resetButton:SetScript("OnClick", function(self) EPGP:SetBidStatus(0) end)

  local announceButton = CreateFrame("Button", "announceButton", frame, "UIPanelButtonTemplate")
  announceButton:SetNormalFontObject("GameFontNormalSmall")
  announceButton:SetHighlightFontObject("GameFontHighlightSmall")
  announceButton:SetDisabledFontObject("GameFontDisableSmall")
  announceButton:SetHeight(BUTTON_HEIGHT)
  announceButton:SetText(L["Announce"])
  announceButton:SetWidth(announceButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  announceButton:SetPoint("LEFT", resetButton, "RIGHT")
  announceButton:Enable()
  announceButton:SetScript(
    "OnClick",
    function(self)
      LootItemsAnnounce(lootItem.links)
    end)

  local lastPageButton = CreateFrame("Button", "lastPageButton", frame, "UIPanelButtonTemplate")
  lastPageButton:SetNormalFontObject("GameFontNormalSmall")
  lastPageButton:SetHighlightFontObject("GameFontHighlightSmall")
  lastPageButton:SetDisabledFontObject("GameFontDisableSmall")
  lastPageButton:SetHeight(BUTTON_HEIGHT)
  lastPageButton:SetText("<")
  lastPageButton:SetWidth(lastPageButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  lastPageButton:SetPoint("LEFT", announceButton, "RIGHT")
  lastPageButton:Disable()
  lastPageButton:SetScript(
    "OnClick",
    function(self)
      lootItem.currentPage = lootItem.currentPage - 1
      LootControlsUpdate()
    end)

  local nextPageButton = CreateFrame("Button", "nextPageButton", frame, "UIPanelButtonTemplate")
  nextPageButton:SetNormalFontObject("GameFontNormalSmall")
  nextPageButton:SetHighlightFontObject("GameFontHighlightSmall")
  nextPageButton:SetDisabledFontObject("GameFontDisableSmall")
  nextPageButton:SetHeight(BUTTON_HEIGHT)
  nextPageButton:SetText(">")
  nextPageButton:SetWidth(nextPageButton:GetTextWidth() + BUTTON_TEXT_PADDING)
  nextPageButton:SetPoint("LEFT", lastPageButton, "RIGHT")
  nextPageButton:Disable()
  nextPageButton:SetScript(
    "OnClick",
    function(self)
      lootItem.currentPage = lootItem.currentPage + 1
      LootControlsUpdate()
    end)

  frame.items = {}

  for i = 1, lootItem.ITEMS_PER_PAGE do
    if i == 1 then
      frame.items[i] = AddLootControlItems(frame, clearButton, i)
    else
      frame.items[i] = AddLootControlItems(frame, frame.items[i - 1], i)
    end
    local item = frame.items[i]
    item.needButton:SetScript("OnClick", LootItemNeedButtonOnClick)
    item.bidButton:SetScript("OnClick", LootItemBidButtonOnClick)
    item.rollButton:SetScript("OnClick", LootItemRollButtonOnClick)
    item.bankButton:SetScript("OnClick", LootItemBankButtonOnClick)
    item.removeButton:SetScript("OnClick", LootItemRemoveButtonOnClick)
  end

  frame.initiated = true
  frame.addButton = addButton
  frame.clearButton = clearButton
  frame.lastPageButton = lastPageButton
  frame.nextPageButton = nextPageButton

  frame:SetWidth(math.max(
    dropDown.frame:GetWidth() + addButton:GetWidth() + 15,
    clearButton:GetWidth() + resetButton:GetWidth() + announceButton:GetWidth() + nextPageButton:GetWidth() * 2))
  frame:SetHeight(
    autoPop:GetHeight() +
    math.max(dropDown.frame:GetHeight(), addButton:GetHeight()) +
    clearButton:GetHeight() +
    frame.items[1]:GetHeight() * lootItem.ITEMS_PER_PAGE)

  LootControlsUpdate()
end

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("distribution", mod.dbDefaults)
end

function mod:OnEnable()
  EPGP.RegisterCallback(self, "AuthorityChanged", AuthorityChangedCallbackFunc)
  EPGP.RegisterCallback(self, "BidStatusUpdate", HandleBidStatusUpdate)
  EPGP.RegisterCallback(self, "CorpseLootReceived", CorpseLootReceivedHandler)
  EPGP.RegisterCallback(self, "LootWindow", LootWindowHandler)
  LootItemsResume()
end

function mod:OnDisable()
  EPGP.UnregisterAllCallbacks(self)
end
