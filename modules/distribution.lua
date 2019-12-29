local mod = EPGP:NewModule("distribution", "AceEvent-3.0")
local C = LibStub("LibEPGPChat-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

local callbacks = EPGP.callbacks

local RANDOM_ROLL_PATTERN = RANDOM_ROLL_RESULT
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("[%(%)%-]", "%%%1")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%s", "%(%.%+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%d", "%(%%d+%)")
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$s", "%(%.%+%)") -- for "deDE"
RANDOM_ROLL_PATTERN = RANDOM_ROLL_PATTERN:gsub("%%%d%$d", "%(%%d+%)") -- for "deDE"

function mod:CHAT_MSG_RAID(event, msg, sender)
  if not EPGP:IsRLorML() then return end
  local bid = tonumber(msg)
  if not bid then return end
  EPGP:HandleBidResult(sender, bid)
end
  
function mod:CHAT_MSG_RAID_LEADER(event, msg, sender)
  self:CHAT_MSG_RAID(event, msg, sender)
end

function mod:CHAT_MSG_WHISPER(event, msg, sender)
  self:CHAT_MSG_RAID(event, msg, sender)
end

function mod:CHAT_MSG_SYSTEM(event, msg)
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
      mod:RegisterEvent("CHAT_MSG_RAID")
      mod:RegisterEvent("CHAT_MSG_RAID_LEADER")
    elseif needMedium == "WHISPER" then
      mod:RegisterEvent("CHAT_MSG_WHISPER")
    end
  elseif status == 2 then
    local bidMedium = self.db.profile.bidMedium
    if bidMedium == "RAID" then
      mod:RegisterEvent("CHAT_MSG_RAID")
      mod:RegisterEvent("CHAT_MSG_RAID_LEADER")
    elseif bidMedium == "WHISPER" then
      mod:RegisterEvent("CHAT_MSG_WHISPER")
    end
  elseif status == 3 then
    mod:RegisterEvent("CHAT_MSG_SYSTEM")
  end
end

function mod:LootItemsAnnounce(itemLinks)
  if not EPGP:IsRLorML() then return end
  local medium = self.db.profile.announceMedium
  C:Announce(medium, L["Loot list: "] .. table.concat(itemLinks, " "))
end

function mod:StartBid(itemLink, method)
  if not EPGP:IsRLorML() then return end
  local medium = self.db.profile.announceMedium
  if method == 1 then
    local needMedium = self.db.profile.needMedium
    if needMedium == "RAID" then
      C:Announce(medium, itemLink .. " " .. L["Please send number to raid channel: "] .. self.db.profile.announceNeedMsg)
    elseif needMedium == "WHISPER" then
      C:Announce(medium, itemLink .. " " .. L["Please whisper number to me: "] .. self.db.profile.announceNeedMsg)
    end
  elseif method == 2 then
    local bidMedium = self.db.profile.bidMedium
    if bidMedium == "RAID" then
      C:Announce(medium, itemLink .. " " .. L["Please send bid value to raid channel."])
    elseif bidMedium == "WHISPER" then
      C:Announce(medium, itemLink .. " " .. L["Please whisper bid value to me."])
    end
  elseif method == 3 then
    C:Announce(medium, itemLink .. " " .. L["/roll if you want this item. DO NOT roll more than one time."])
  end
  EPGP:SetBidStatus(method, self.db.profile.resetWhenAnnounce)
end

mod.dbDefaults = {
  profile = {
    enabled = true,
    announceMedium = "RAID",
    needMedium = "RAID",
    bidMedium = "RAID",
    announceNeedMsg = "1 - " .. NEED .. " 2 - " .. GREED,
    resetWhenAnnounce = true,
    lootAutoAdd = true,
    threshold = 4,
  }
}

local function Spacer(o, height)
  return {
    type = "description",
    order = o,
    name = " ",
    fontSize = "small",
  }
end

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
  spacer1 = Spacer(13, 0.001),
  announceNeedMsg = {
    order = 20,
    type = "input",
    name = L["Announce need message"],
    desc = L["Message announced when you start a need/greed bid."],
    width = 100,
  },
  spacer2 = Spacer(21, 0.001),
  resetWhenAnnounce = {
    order = 30,
    type = "toggle",
    name = L["Reset when announce a bid"],
    desc = L["Reset result when announce and start a bid/need/roll."],
    width = 30,
  },
  spacer3 = Spacer(31, 0.001),
  lootAutoAdd = {
    order = 40,
    type = "toggle",
    name = L["Track loot items"],
    desc = L["Add loot items automatically when loot windows opened or corpse loot received."],
  },
  spacer4 = Spacer(41, 0.001),
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

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("distribution", mod.dbDefaults)
end

function mod:OnEnable()
  EPGP.RegisterCallback(self, "BidStatusUpdate", HandleBidStatusUpdate)
end

function mod:OnDisable()
  EPGP.UnregisterAllCallbacks(self)
end
