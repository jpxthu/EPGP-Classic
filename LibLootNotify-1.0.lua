-- A library to allow registration of callbacks to receive
-- notifications on loot events.

local MAJOR_VERSION = "LibLootNotify-1.0"
local MINOR_VERSION = tonumber(("$Revision: 1023 $"):match("%d+")) or 0

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local Debug = LibStub("LibDebug-1.0")

local AceTimer = LibStub("AceTimer-3.0")
local AceHook = LibStub("AceHook-3.0")
local AceComm = LibStub("AceComm-3.0")
AceHook:Embed(lib)
AceComm:Embed(lib)

local deformat = LibStub("LibDeformat-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")

lib.callbacks = lib.callbacks or CallbackHandler:New(lib)
local callbacks = lib.callbacks

lib.frame = lib.frame or CreateFrame("Frame", MAJOR_VERSION .. "_Frame", UIParentBackdropTemplateMixin and "BackdropTemplate");
local frame = lib.frame

frame:UnregisterAllEvents()
frame:SetScript("OnEvent", nil)

-- Some tables we need to cache the contents of the loot slots
local distributionCache = {}
local distributionTimers = {}

-- Sets the timeout before emulating a loot message
local EMULATE_TIMEOUT = 5

-- coin currency ID
local currentCurrencyID = nil

-- Create a handle for a emulation timer
local function GenerateDistributionID(player, itemLink, quantity)
  local itemid, suffixid, uniqueid = tostring(itemLink):match("|Hitem:(%d+):%d*:%d*:%d*:%d*:%d*:(\-*%d*):(\-*%d*)")
  if (suffixid == "") then suffixid = "0"; end
  if (uniqueid == "") then uniqueid = "0"; end
  return format('%s:%s:%s',
          tostring(player),
          tostring(itemid..":"..uniqueid),
          tostring(quantity))
end

local function ParseLootMessage(msg)
  local player = UnitName("player")
  local item, quantity = deformat(msg, LOOT_ITEM_SELF_MULTIPLE)
  if item and quantity then
    return player, item, tonumber(quantity)
  end
  quantity = 1
  item = deformat(msg, LOOT_ITEM_SELF)
  if item then
    return player, item, tonumber(quantity)
  end

  player, item, quantity = deformat(msg, LOOT_ITEM_MULTIPLE)
  if player and item and quantity then
    return player, item, tonumber(quantity)
  end

  quantity = 1
  player, item = deformat(msg, LOOT_ITEM)
  return player, item, tonumber(quantity)
end

function lib.BonusMessageReceiver(prefix, message, distribution, sender)
  local announce = (IsInRaid() and UnitIsGroupLeader("player"))

  local command, rewardType, rewardLink, numCoins, currencyID = strsplit("^", message)
  if rewardType == "item" then
    EPGP:LogBonusLootRoll(sender, numCoins, rewardLink, currencyID)
    if announce then
      EPGP.callbacks:Fire("CoinLootGood", sender, rewardLink, numCoins)
    end
  elseif rewardType == "money" then
    EPGP:LogBonusLootRoll(sender, numCoins, nil, currencyID)
    if announce then
      EPGP.callbacks:Fire("CoinLootBad", sender, numCoins)
    end
  end
end

local function HandleBonusLootResult(rewardType, rewardLink, rewardQuantity)
  local _, numCoins = GetCurrencyInfo(currentCurrencyID or 0)
  lib:SendCommMessage("EPGPBONUS", format("BONUS_LOOT_RESULT^%s^%s^%s^%s",
          tostring(rewardType),
          tostring(rewardLink),
          tostring(numCoins),
          tostring(currentCurrencyID or 0)),
          "RAID", nil, "ALERT")
end

-- Just add items here; the itemLink has a unique id, so this will
-- grow slightly over time but reload will clear it.
local announcedLoot = {}

local function CorpseLootReceiver(prefix, message, distribution, sender)
  announcedLoot[message] = true
  EPGP.callbacks:Fire("CorpseLootReceived", message)
end

local function removeSpecId(itemLink)
  local w, i, link
  i = 0
  link = ''

  for w in gmatch(itemLink .. ':', '([^:]*):') do
    i = i + 1
    if i == 11 then
      w = 0
    end
    link = link .. w .. ':'
  end

  return link:sub(1, -2)
end

local function HandleLootWindow()
  -- Don't send events if we're not in a raid or are in LFR
  local _, _, diffculty = GetInstanceInfo()
  if not UnitInRaid("player") or diffculty == 7 then return end

  local loot = {}
  local loot_all = {}

  for i = 1, GetNumLootItems() do
    local itemLink = GetLootSlotLink(i)
    if itemLink ~= nil then
      itemLink = removeSpecId(itemLink)
      if announcedLoot[itemLink] == nil then
        table.insert(loot, itemLink)
        announcedLoot[itemLink] = true
      end
      table.insert(loot_all, itemLink)
    end
  end
  if #loot > 0 then
    Debug("loot count: %s", #loot)
    EPGP.callbacks:Fire("LootEpics", loot)
  end
  if #loot_all > 0 then
    EPGP.callbacks:Fire("LootWindow", loot_all)
  end
end

local function HandleLootMessage(msg)
  local player, itemLink, quantity = ParseLootMessage(msg)
  if player and itemLink and quantity then
    Debug('Firing LootReceived(%s, %s, %d)', player, itemLink, quantity)

    -- See if we can find a timer for the out of range bug
    local distributionID = GenerateDistributionID(player, itemLink, quantity)
    if distributionTimers[distributionID] then
      -- A timer has been found for this item, stop that timer asap
      Debug('Stopping loot message emulate timer %s', distributionID)
      AceTimer:CancelTimer(distributionTimers[distributionID], true)
      distributionTimers[distributionID] = null
      distributionCache[distributionID] = null
    end

    -- See if we can find a entry in the distributionCache.
    -- This happens when the loot message is sent before the LOOT_SLOT_CLEARED event
    local slotData = distributionCache[distributionID]
    if slotData then
      -- The loot message for this item has been sent before the slot cleared event.
      -- Clear out the distributionCache
      Debug('STOPPING all handling for %s, loot message sent before LOOT_SLOT_CLEARED.', distributionID)
      distributionCache[slotData.slotID] = null
      distributionCache[distributionID] = null
    end

    callbacks:Fire("LootReceived", player, itemLink, quantity)
  end
end

local function EmulateEvent(event, ...)
  for _, frame in pairs({GetFramesRegisteredForEvent(event)}) do
    local func = frame:GetScript('OnEvent')
    pcall(func, frame, event, ...)
  end
end

--[[  BLIZZARD BUGFIX: Looter out of range
  For a long time there has been a bug when people
  that receive masterloot but they're out of range
  of the Master Looter (ML), the ML doesn't receive
  the 'player X receives Item Y.' message. The code
  below tries to fix this problem by hooking the
  GiveMasterLoot() function and remembering to which
  player the ML tried to send the loot. The ML always
  receives the LOOT_SLOT_CLEARED events, so we can
  safely assume that the last player the ML tried to
  send to loot to, is the one who received the item.
  This obviously only works when using master loot, not
  group loot.
]]--

-- Triggers when MasterLoot has been handed out but
-- no loot message has been received within the timeframe
local function OnLootTimer(slotData)
  local candidate = slotData.candidate
  local itemLink = slotData.itemLink
  local quantity = slotData.quantity
  local distributionID = slotData.distributionID

  if not distributionID then return end
  distributionTimers[distributionID] = null
  distributionCache[distributionID] = null

  Debug('Emulating lootmessage for %s', distributionID)
  print(format('No loot message received while %s received %sx%s, player was probably out of range. Emulating loot message locally:',
               candidate,
               itemLink,
               quantity))
  -- Emulate the event so other addons can benefit from it aswell.
  if quantity == 1 then
    EmulateEvent('CHAT_MSG_LOOT', LOOT_ITEM:format(candidate, itemLink), '', '', '', '')
  else
    EmulateEvent('CHAT_MSG_LOOT', LOOT_ITEM_MULTIPLE:format(candidate, itemLink, quantity), '', '', '', '')
  end
end

--- This handler gets called when a loot slot gets cleared.
--  This is where we detect who got the item
local function LOOT_SLOT_CLEARED(event, slotID, ...)
  -- Someone looted a slot, lets see if we have someone registered for it
  local slotData = distributionCache[slotID]
  if slotData then
    -- Ok, we know who got the item but the server might also still send the
    -- 'player X receives Item Y' message. We'll need to wait for a little while
    -- and see if the server still sends us this message. If it doesn't, we should
    -- emulate the message ourselves. Note that this is fairly optimized because it
    -- only starts timers for loot that was handed out using GiveMasterLoot() and
    -- doesn't start timers for any normal loot.

    -- Fetch the name for the timer from the slotData
    local distributionID = slotData.distributionID
    Debug("LibLootNotify: (%s) creating timer %s", event, distributionID)
    -- Schedule a timer for this loot
    distributionTimers[distributionID] = AceTimer:ScheduleTimer(OnLootTimer, EMULATE_TIMEOUT, slotData)
  end

  -- Clear our slot entry since the slot is now empty
  distributionCache[slotID] = nil
end

-- Hook the GiveMasterLoot function so we can intercept the slotID and candidate
local function GiveMasterLootHandler(slotID, candidateID, ...)
  local candidate = tostring(GetMasterLootCandidate(slotID, candidateID))
  local itemLink = tostring(GetLootSlotLink(slotID))
  Debug("LibLootNotify: GiveMasterLoot(%s, %s)", itemLink, candidate)
  local slotData = {
    candidate   = candidate,
    itemLink    = itemLink,
    quantity    = select(3, GetLootSlotInfo(slotID)) or 1,
    slotID      = slotID
  }
  local distributionID = GenerateDistributionID(candidate, itemLink, slotData.quantity)
  slotData.distributionID = distributionID

  -- Sometimes the CHAT_MSG_LOOT event is called before the LOOT_SLOT_CLEARED and sometimes
  -- it's the way around. We're registering two ways of looking up the item in our table.
  -- One way is by slotID and the other is by player:itemlink:quantity. These keys will never
  -- overlap so it's safe to store them in the same table.
  distributionCache[slotID] = slotData
  distributionCache[distributionID] = slotData
end

-- Unhook the function if it's already hooked by older versions of the library
if lib:IsHooked("GiveMasterLoot") then lib:Unhook("GiveMasterLoot") end
lib:Hook("GiveMasterLoot", GiveMasterLootHandler, true)

-- There's no need to wipe the tables on the LOOT_CLOSED event,
-- the LOOT_SLOT_CLEARED and CHAT_MSG_LOOT events will clear the
-- table keys themselves.

--[[###############################################--
      REGISTER EVENTS
--###############################################]]--

frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("LOOT_OPENED")
-- frame:RegisterEvent("BONUS_ROLL_RESULT")
frame:RegisterEvent("SPELL_CONFIRMATION_PROMPT")
lib:RegisterComm("EPGPBONUS", lib.BonusMessageReceiver)
lib:RegisterComm("EPGPCORPSELOOT", CorpseLootReceiver)

frame:SetScript("OnEvent",
  function(self, event, ...)
    if event == "CHAT_MSG_LOOT" then
      HandleLootMessage(...)
    elseif event == "LOOT_OPENED" then
      HandleLootWindow(...)
    elseif event == "LOOT_SLOT_CLEARED" then
      LOOT_SLOT_CLEARED(event, ...)
    elseif event == "BONUS_ROLL_RESULT" then
      HandleBonusLootResult(...)
    elseif event == "SPELL_CONFIRMATION_PROMPT" then
      local spellID, confirmType, text, duration, currencyID = ...;
      if confirmType == CONFIRMATION_PROMPT_BONUS_ROLL then
        currentCurrencyID = currencyID
      end
    end
  end)
frame:Show()

--[[###############################################--
      UNIT TESTS
--###############################################]]--

function lib:DebugTest()
  EmulateEvent('CHAT_MSG_LOOT',
               LOOT_ITEM:format(UnitName('player'),
                                select(2, GetItemInfo(18609))),
               '', '', '', '')
  EmulateEvent('CHAT_MSG_LOOT',
               LOOT_ITEM_SELF:format(select(2, GetItemInfo(19334))),
               '', '', '', '')
  EmulateEvent('CHAT_MSG_LOOT',
               LOOT_ITEM_SELF:format(select(2, GetItemInfo(17077))),
               '', '', '', '')
end

-- Print the content of the distribution caches
function lib:PrintDistributionCaches()
  Debug('distributionCache:')
  for id=1, 20 do
    local data = distributionCache[id]
    if data then Debug(' - %s :: %s', id, data.distributionID) end
  end
  for id, data in pairs(distributionCache) do
    if data then Debug(' - %s :: %s', id, data.distributionID) end
  end
  Debug('distributionTimers:')
  for id, data in pairs(distributionTimers) do
    Debug(' - %s :: %s', id, tostring(data))
  end
end

-- This tests all the possible situations for the loot detection patch.
function lib:LootTest()
  -- Make a little array of itemlinks for testing purposes.
  local items = {18609, 19334, 17077}
  for id, itemID in pairs(items) do
    local item = select(2, GetItemInfo(itemID))
    if not item then return print(format('DEBUG ITEM %d NOT FOUND!', itemID)) end
    items[id] = item
  end

  -- Backup all the functions we use for the looting patch and replace them with the unit test functions
  local _GetMasterLootCandidate = GetMasterLootCandidate
  GetMasterLootCandidate = function() return UnitName('player') end
  local _GetLootSlotLink = GetLootSlotLink
  GetLootSlotLink = function(slotID) return items[slotID] end
  local _GetLootSlotInfo = GetLootSlotInfo
  GetLootSlotInfo = function(slotID) return 1, 1, 1, 1, 1, 1 end
  local ___GiveMasterLoot = _GiveMasterLoot
  _GiveMasterLoot = function() end

  -- Send an item with LOOT_SLOT_CLEARED event AFTER the loot message
  Debug('--- ITEM 1 ---')
  GiveMasterLoot(1, 1)
  HandleLootMessage(LOOT_ITEM_SELF:format(items[1]), '', '', '', '')
  LOOT_SLOT_CLEARED("LOOT_SLOT_CLEARED", 1)

  -- Send an item with LOOT_SLOT_CLEARED event BEFORE the loot message
  Debug('--- ITEM 2 ---')
  GiveMasterLoot(2, 1)
  LOOT_SLOT_CLEARED("LOOT_SLOT_CLEARED", 2)
  HandleLootMessage(LOOT_ITEM_SELF:format(items[2]), '', '', '', '')

  -- Sends an item without sending a loot message, this will trigger the emulated loot message
  Debug('--- ITEM 3 ---')
  GiveMasterLoot(3, 1)
  LOOT_SLOT_CLEARED("LOOT_SLOT_CLEARED", 3)

  Debug('Showing tables, only %s should show up here.', items[3])
  lib:PrintDistributionCaches()

  -- Restore the old functions
  _GiveMasterLoot = __GiveMasterLoot
  GetMasterLootCandidate = _GetMasterLootCandidate
  GetLootSlotLink = _GetLootSlotLink
  GetLootSlotInfo = _GetLootSlotInfo
end

-- /script LibStub("LibLootNotify-1.0"):PrintDistributionCaches()
-- /script LibStub("LibLootNotify-1.0"):LootTest()
-- /script LibStub("LibLootNotify-1.0"):DebugTest()
