--
-- GetNumRecords(): Returns the number of log records.
--
-- GetLogRecord(i): Returns the ith log record starting 0.
--
-- ExportLog(): Returns a string with the data of the exported log for
-- import into the web application.
--
-- UndoLastAction(): Removes the last entry from the log and undoes
-- its action. The undone action is not logged.
--
-- This module also fires the following messages.
--
-- LogChanged(n): Fired when the log is changed. n is the new size of
-- the log.
--

local mod = EPGP:NewModule("log", "AceComm-3.0", "AceEvent-3.0")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("EPGP")
local LIU = LibStub("LibItemUtils-1.0")
local GS = LibStub("LibGuildStorage-1.2")
local JSON = LibStub("LibJSON-1.0")
local ItemUtils = LibStub("LibItemUtils-1.0")
local deformat = LibStub("LibDeformat-3.0")

local CallbackHandler = LibStub("CallbackHandler-1.0")
if not mod.callbacks then
  mod.callbacks = CallbackHandler:New(mod)
end
local callbacks = mod.callbacks

local function RecordItemLootLog(timestamp, name, itemlink, amount)
  if not mod.db.profile.record_item_log then return end
  if not timestamp or not name or not itemlink then return end

  local item_log = mod.db.profile.item_log
  if not item_log[itemlink] then
    item_log[itemlink] = {}
  end
  table.insert(item_log[itemlink], {timestamp, name, amount})
end

function mod:ItemLog(itemlink)
  if not mod.db.profile.record_item_log then return nil end
  if not itemlink then return nil end
  local log = self.db.profile.item_log[itemlink]
  if not log then return nil end
  if #log == 0 then return nil end
  local str = {}
  local start_i = #log
  local end_i = math.max(1, #log - self.db.profile.item_log_display_number + 1)
  for i = start_i, end_i, -1 do
    local timestamp, name, amount = unpack(log[i])
    local color = _G.RAID_CLASS_COLORS[EPGP:GetClass(name) or "DEATHKNIGHT"].colorStr
    name = EPGP:GetDisplayCharacterName(name)
    name = string.format("\124c%s%s\124r", color, name)
    table.insert(str, string.format("%d GP  %s  %s", amount, name, date("%Y-%m-%d", timestamp)))
    -- table.insert(str, {name, amount, date("%Y-%m-%d", timestamp)})
  end
  return str
end

-- local timestamp_t = {}
local function GetTimestamp(diff)
  local t = time();
  if diff then
    local years  = (diff.year  or 0)
    local months = (diff.month or 0) + years  * 12
    local days   = (diff.day   or 0) + months * 30
    local hours  = (diff.hour  or 0) + days   * 24
    local mins   = (diff.min   or 0) + hours  * 60
    local secs   = (diff.sec   or 0) + mins   * 60
    return t + secs
  end
  return t
  -- timestamp_t.month = tonumber(date("%m"))
  -- timestamp_t.day = tonumber(date("%d"))
  -- timestamp_t.year = tonumber(date("%Y"))
  -- timestamp_t.hour = select(1, GetGameTime())
  -- timestamp_t.min = select(2, GetGameTime())
  -- if diff then
  --   timestamp_t.month = timestamp_t.month + (diff.month or 0)
  --   timestamp_t.day = timestamp_t.day + (diff.day or 0)
  --   timestamp_t.year = timestamp_t.year + (diff.year or 0)
  --   timestamp_t.hour = timestamp_t.hour + (diff.hour or 0)
  --   timestamp_t.min = timestamp_t.min + (diff.min or 0)
  -- end
  -- return time(timestamp_t)
end

local LOG_FORMAT = "LOG:%d\31%s\31%s\31%s\31%d"

local function AppendToLog(kind, event_type, name, reason, amount, mass, undo)
  if not undo then
    -- Clear the redo table
    for k,_ in ipairs(mod.db.profile.redo) do
      mod.db.profile.redo[k] = nil
    end
    local timestamp = GetTimestamp()
    local entry = {timestamp, kind, name, reason, amount}
    table.insert(mod.db.profile.log, entry)
    mod:SendCommMessage("EPGP", string.format(LOG_FORMAT, unpack(entry)),
                        "GUILD", nil, "BULK")
    callbacks:Fire("LogChanged", #mod.db.profile.log)
    if kind == "GP" then
      RecordItemLootLog(timestamp, name, reason, amount)
    end
  end
end

function mod:LogSync(prefix, msg, distribution, sender)
  if prefix == "EPGP" and sender ~= UnitName("player") then
    local timestamp, kind, name, reason, amount = deformat(msg, LOG_FORMAT)
    if timestamp then
      amount = tonumber(amount)
      local entry = {tonumber(timestamp), kind, name, reason, amount}
      table.insert(mod.db.profile.log, entry)
      callbacks:Fire("LogChanged", #self.db.profile.log)
      if kind == "GP" then
        RecordItemLootLog(timestamp, name, reason, amount)
      end
    end
  end
end

local function LogRecordToString(record)
  local timestamp, kind, name, reason, amount = unpack(record)

  if kind == "EP" then
    return string.format(L["%s: %+d EP (%s) to %s"],
                         date("%Y-%m-%d %H:%M", timestamp), amount, reason, name)
  elseif kind == "GP" then
    return string.format(L["%s: %+d GP (%s) to %s"],
                         date("%Y-%m-%d %H:%M", timestamp), amount, reason, name)
  elseif kind == "BI" then
    return string.format(L["%s: %s to %s"],
                         date("%Y-%m-%d %H:%M", timestamp), reason, name)
  else
    assert(false, "Unknown record in the log")
  end
end

function mod:GetNumRecords()
  return #self.db.profile.log
end

function mod:GetLogRecord(i)
  local logsize = #self.db.profile.log
  assert(i >= 0 and i < #self.db.profile.log, "Index "..i.." is out of bounds")

  return LogRecordToString(self.db.profile.log[logsize - i])
end

function mod:CanUndo()
  if not CanEditOfficerNote() or not GS:IsCurrentState() then
    return false
  end
  return #self.db.profile.log ~= 0
end

function mod:UndoLastAction()
  assert(#self.db.profile.log ~= 0)

  local record = table.remove(self.db.profile.log)
  table.insert(self.db.profile.redo, record)

  local timestamp, kind, name, reason, amount = unpack(record)

  local ep, gp, main = EPGP:GetEPGP(name)

  if kind == "EP" then
    EPGP:IncEPBy(name, L["Undo"].." "..reason, -amount, false, true)
  elseif kind == "GP" then
    EPGP:IncGPBy(name, L["Undo"].." "..reason, -amount, false, true)
  elseif kind == "BI" then
    EPGP:BankItem(L["Undo"].." "..reason, true)
  else
    assert(false, "Unknown record in the log")
  end

  callbacks:Fire("LogChanged", #self.db.profile.log)
  return true
end

function mod:CanRedo()
  if not CanEditOfficerNote() or not GS:IsCurrentState() then
    return false
  end

  return #self.db.profile.redo ~= 0
end

function mod:RedoLastUndo()
  assert(#self.db.profile.redo ~= 0)

  local record = table.remove(self.db.profile.redo)
  local timestamp, kind, name, reason, amount = unpack(record)

  local ep, gp, main = EPGP:GetEPGP(name)
  if kind == "EP" then
    EPGP:IncEPBy(name, L["Redo"].." "..reason, amount, false, true)
    table.insert(self.db.profile.log, record)
  elseif kind == "GP" then
    EPGP:IncGPBy(name, L["Redo"].." "..reason, amount, false, true)
    table.insert(self.db.profile.log, record)
  else
    assert(false, "Unknown record in the log")
  end

  callbacks:Fire("LogChanged", #self.db.profile.log)
  return true
end

-- This is kept for historical reasons: see
-- http://code.google.com/p/epgp/issues/detail?id=350.
function mod:Snapshot()
  local t = self.db.profile.snapshot
  if not t then
    t = {}
    self.db.profile.snapshot = t
  end
  t.time = GetTimestamp()
  GS:Snapshot(t)
end

local function swap(t, i, j)
  t[i], t[j] = t[j], t[i]
end

local function reverse(t)
  for i=1,math.floor(#t / 2) do
    swap(t, i, #t - i + 1)
  end
end

function mod:TrimToOneMonth()
  -- The log is sorted in reverse timestamp. We do not want to remove
  -- one item at a time since this will result in O(n^2) time. So we
  -- build it anew.
  local new_log = {}
  local last_timestamp = GetTimestamp({ month = -1 })

  -- Go through the log in reverse order and stop when we reach an
  -- entry older than one month.
  for i=#self.db.profile.log,1,-1 do
    local record = self.db.profile.log[i]
    if record[1] < last_timestamp then
      break
    end
    table.insert(new_log, record)
  end

  -- The new log is in reverse order now so reverse it.
  reverse(new_log)

  self.db.profile.log = new_log

  callbacks:Fire("LogChanged", #self.db.profile.log)
end

local function GetRegion()
  local region = GetCVar("portal")
  if region then
    region = region:lower()
  end
  return region
end

function mod:Export()
  local d = {}
  d.region = GetRegion()
  d.guild = select(1, GetGuildInfo("player"))
  d.realm = GetRealmName()
  d.base_gp = EPGP:GetBaseGP()
  d.min_ep = EPGP:GetMinEP()
  d.decay_p = EPGP:GetDecayPercent()
  d.extras_p = EPGP:GetExtrasPercent()
  d.timestamp = GetTimestamp()

  d.roster = EPGP:ExportRoster()

  d.loot = {}
  for i, record in ipairs(self.db.profile.log) do
    local timestamp, kind, name, reason, amount = unpack(record)
    if kind == "GP" or kind == "BI" then
      local itemString = reason:match("item[%-?%d:]+")
      if itemString then
        table.insert(d.loot, {timestamp, name, itemString, amount})
      end
    end
  end

  return JSON.Serialize(d):gsub("\124", "\124\124")
end

function mod:ExportDetail()
  local base_gp = EPGP:GetBaseGP()

  local l = ""
  l = l .. "#\ttimestamp\t" .. tostring(GetTimestamp()) .. "\n"
  l = l .. "#\tversion\t" .. "v1.0" .. "\n"
  l = l .. "#\taddon\t" .. EPGP.version .. "\n"
  l = l .. "#\tinterface\t" .. tostring(select(4, GetBuildInfo())) .. "\n\n"

  l = l .. "#\tregion\t" .. GetRegion() .. "\n"
  l = l .. "#\trealm\t" .. GetRealmName() .. "\n"
  l = l .. "#\tguild\t" .. select(1, GetGuildInfo("player")) .. "\n"
  l = l .. "#\tbase_gp\t" .. base_gp .. "\n"
  l = l .. "#\tmin_ep\t" .. EPGP:GetMinEP() .. "\n"
  l = l .. "#\tdecay_p\t" .. EPGP:GetDecayPercent() .. "\n"
  l = l .. "#\textras_p\t" .. EPGP:GetExtrasPercent() .. "\n"
  l = l .. "#\toutsiders\t" .. EPGP:GetOutdisers() .. "\n\n"

  l = l .. "#\troster\tname,ep,gp,class\n"
  local roster = EPGP:ExportRosterDetail()
  for i, v in pairs(roster) do
    local name, ep, gp, class = unpack(v)
    l = l .. string.format("%s\t%d\t%d\t%s\n", name, ep, gp, class)
  end

  l = l .. "\n#\tlog\ttimestamp,type,name,reason,value\n"
  for i, record in ipairs(self.db.profile.log) do
    local timestamp, kind, name, reason, amount = unpack(record)
    local str = string.format("%d\t%s\t%s\t%s\t%s",
      timestamp, kind, name, reason, tostring(amount))
    if string.match(reason, "item[%-?%d:]+") then
      str = str .. "\t" .. string.gsub(reason, "|", "||")
    end
    l = l .. str .. "\n"
  end

  return l
end

function mod:Import(jsonStr)
  local success, d = pcall(JSON.Deserialize, jsonStr)
  if not success then
    EPGP:Print(L["The imported data is invalid"])
    return
  end

  if d.region and d.region:lower() ~= GetRegion():lower() then
    EPGP:Print(L["The imported data is invalid"])
    return
  end

  if d.guild ~= select(1, GetGuildInfo("player")) or
     d.realm ~= GetRealmName() then
    EPGP:Print(L["The imported data is invalid"])
    return
  end

  local types = {
    timestamp = "number",
    roster = "table",
    decay_p = "number",
    extras_p = "number",
    min_ep = "number",
    base_gp = "number",
  }
  for k,t in pairs(types) do
    if type(d[k]) ~= t then
      EPGP:Print(L["The imported data is invalid"])
      return
    end
  end

  for _, entry in pairs(d.roster) do
    if type(entry) ~= "table" then
      EPGP:Print(L["The imported data is invalid"])
      return
    else
      local types = {
        [1] = "string",
        [2] = "number",
        [3] = "number",
      }
      for k,t in pairs(types) do
        if type(entry[k]) ~= t then
          EPGP:Print(L["The imported data is invalid"])
          return
        end
      end
    end
  end

  EPGP:Print(L["Importing data snapshot taken at: %s"]:format(
               date("%Y-%m-%d %H:%M", d.timestamp)))
  EPGP:SetGlobalConfiguration(d.decay_p, d.extras_p, d.base_gp, d.min_ep, d.outsiders or 0)
  EPGP:ImportRoster(d.roster, d.base_gp)

  -- Trim the log if necessary.
  local timestamp = d.timestamp
  while true do
    local records = #self.db.profile.log
    if records == 0 then
      break
    end

    if self.db.profile.log[records][1] > timestamp then
      table.remove(self.db.profile.log)
    else
      break
    end
  end
  -- Add the redos back to the log if necessary.
  while #self.db.profile.redo ~= 0 do
    local record = table.remove(self.db.profile.redo)
    if record[1] < timestamp then
      table.insert(self.db.profile.log, record)
    end
  end

  callbacks:Fire("LogChanged", #self.db.profile.log)
end

mod.dbDefaults = {
  profile = {
    enabled = true,
    log = {},
    redo = {},
    item_log = {},
    record_item_log = false,
    item_log_display_number = 5,
  }
}

mod.optionsName = L["Logs"]
mod.optionsDesc = L["Logs"]
mod.optionsArgs = {
  help = {
    order = 1,
    type = "description",
    name = L["Logs"],
    fontSize = "medium",
  },
  item_log_header = {
    order = 20,
    type = "header",
    name = L["LOOT_ITEM_LOG_HEADER"],
  },
  item_log_help = {
    order = 21,
    type = "description",
    name = L["LOOT_RECORD_ITEM_LOG_DESC"],
    fontSize = "medium",
  },
  record_item_log = {
    order = 22,
    type = "toggle",
    name = L["LOOT_RECORD_ITEM_LOG_NAME"],
    desc = L["LOOT_RECORD_ITEM_LOG_DESC"],
  },
  item_log_display_number = {
    order = 23,
    type = "input",
    name = L["LOOT_ITEM_LOG_SHOW_NUMBER_NAME"],
    pattern = "^[1-9]%d*$",
    usage = L["should be a positive integer"],
    get = function()
      return tostring(mod.db.profile.item_log_display_number)
    end,
    set = function(info, v)
      mod.db.profile.item_log_display_number = tonumber(v)
    end,
  },
  clean_item_log = {
    order = 24,
    type = "execute",
    name = L["LOOT_ITEM_LOG_CLEAR_NAME"],
    func = function()
      table.wipe(mod.db.profile.item_log)
      EPGP:Print(L["LOOT_ITEM_LOG_CLEAR_MSG"])
    end,
  },
}

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("log", mod.dbDefaults)
end

function mod:OnEnable()
  EPGP.RegisterCallback(mod, "EPAward", AppendToLog, "EP")
  EPGP.RegisterCallback(mod, "GPAward", AppendToLog, "GP")
  EPGP.RegisterCallback(mod, "BankedItem", AppendToLog, "BI")
  mod:RegisterComm("EPGP", "LogSync")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  -- Upgrade the logs from older dbs
  if EPGP.db.profile.log then
    self.db.profile.log = EPGP.db.profile.log
    EPGP.db.profile.log = nil
  end
  if EPGP.db.profile.redo then
    self.db.profile.redo = EPGP.db.profile.redo
    EPGP.db.profile.redo = nil
  end

  -- This is kept for historical reasons. See:
  -- http://code.google.com/p/epgp/issues/detail?id=350.
  EPGP.db.RegisterCallback(self, "OnDatabaseShutdown", "Snapshot")
end

function mod:PLAYER_ENTERING_WORLD()
    EPGP:GetModule("log"):TrimToOneMonth()
end
