local mod = EPGP:NewModule("whisper", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

local senderMap = {}

local SendChatMessage = _G.SendChatMessage
if ChatThrottleLib then
  SendChatMessage = function(...)
                      ChatThrottleLib:SendChatMessage("NORMAL", "EPGP", ...)
                    end
end

local function ResumeWhisperSenderMap()
  local vars = EPGP.db.profile
  if not vars.whisperSenderMap then
    vars.whisperSenderMap = {}
    return false
  end

  for member, sender in pairs(vars.whisperSenderMap) do
    senderMap[member] = sender
  end

  return true
end

local function SenderMapExpireClear()
  local vars = EPGP.db.profile
  local t = time()
  for n, s in pairs(senderMap) do
    if s.expire and s.expire <= t then
      s = nil
      vars.whisperSenderMap[n] = nil
    end
  end
end

function mod:CHAT_MSG_WHISPER(event_name, msg, sender)
  if not UnitInRaid("player") then return end

  if msg:sub(1, 12):lower() ~= 'epgp standby' then return end

  local member = msg:sub(13):match("([^ ]+)")
  if member then
    if mod.db.profile.forOthers then
      -- http://lua-users.org/wiki/LuaUnicode
      local firstChar, offset = member:match("([%z\1-\127\194-\244][\128-\191]*)()")
      member = firstChar:upper()..member:sub(offset):lower()
    else
      SendChatMessage(L["[EPGP auto reply] "] ..
        L["Standby for others is NOT allowed. Whisper 'epgp standby' instead."],
        "WHISPER", nil, sender)
      return
    end
  else
    member = sender
  end

  member = EPGP:GetFullCharacterName(member)
  member = EPGP:GetMain(member)

  local isProtected = false
  if senderMap[member] and senderMap[member].expire then
    isProtected = true
  end

  senderMap[member] = { name = sender }
  EPGP.db.profile.whisperSenderMap[member] = { name = sender }

  if not EPGP:GetEPGP(member) then
    SendChatMessage(L["[EPGP auto reply] "] ..
      L["%s is not eligible for EP awards"]:format(member), "WHISPER", nil, sender)
  elseif EPGP:IsMemberInAwardList(member) and not isProtected then
    SendChatMessage(L["[EPGP auto reply] "] ..
      L["%s is already in the award list"]:format(member), "WHISPER", nil, sender)
  else
    EPGP:SelectMember(member)
    SendChatMessage(L["[EPGP auto reply] "] ..
      L["%s is added to the award list"]:format(member), "WHISPER", nil, sender)
  end
end

local function AnnounceMedium()
  local medium = mod.db.profile.medium
  if medium ~= "NONE" then
    return medium
  end
end

local function SendNotifiesAndClearExtras(
    event_name, names, reason, amount,
    extras_awarded, extras_reason, extras_amount)
  local medium = AnnounceMedium()
  if medium then
    EPGP:GetModule("announce"):AnnounceTo(
      medium,
      L["If you want to be on the award list but you are not in the raid, you need to whisper me: 'epgp standby' or 'epgp standby <name>' where <name> is the toon that should receive awards"])
  end

  local vars = EPGP.db.profile
  if not extras_awarded then
    wipe(senderMap)
    wipe(vars.whisperSenderMap)
    return
  end

  local time_now = time()
  local time_protect = mod.db.profile.protectTime
  local time_expire = time_now + time_protect

  for member,_ in pairs(extras_awarded) do
    local sender = senderMap[member]
    if sender then
      SendChatMessage(L["[EPGP auto reply] "] ..
                      L["%+d EP (%s) to %s"]:format(
                        extras_amount, extras_reason, member),
                      "WHISPER", nil, sender.name)

      -- Not first time
      if sender.expire then
        SendChatMessage(L["[EPGP auto reply] "] ..
          L["%s is not in the award list now. Whisper me 'epgp standby' to enlist again."]:format(member),
            "WHISPER", nil, sender.name)

      -- First time
      else
        SendChatMessage(L["[EPGP auto reply] "] ..
          L["%s is now removed from the award list. Whisper me 'epgp standby' to enlist again."]:format(member),
            "WHISPER", nil, sender.name)

        if time_protect == 0 then
          senderMap[member] = nil
          vars.whisperSenderMap[member] = nil
          EPGP:DeSelectMember(member)
        else
          sender.expire = time_expire
          vars.whisperSenderMap[member].expire = time_expire
          EPGP:SelectMemberExpire(member, time_expire)
        end
      end
    end
  end

  SenderMapExpireClear()
end

mod.dbDefaults = {
  profile = {
    enabled = false,
    medium = "GUILD",
    forOthers = false,
    protectTime = 300,
  }
}

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("whisper", mod.dbDefaults)
  ResumeWhisperSenderMap()
end

mod.optionsName = L["Whisper"]
mod.optionsDesc = L["Standby whispers in raid"]
mod.optionsArgs = {
  help = {
    order = 1,
    type = "description",
    name = L["Automatic handling of the standby list through whispers when in raid. When this is enabled, the standby list is cleared after each reward."],
    fontSize = "medium",
  },
  medium = {
    order = 2,
    type = "select",
    name = L["Announce medium"],
    desc = L["Sets the announce medium EPGP will use to announce EPGP actions."],
    values = {
      ["GUILD"] = CHAT_MSG_GUILD,
      ["CHANNEL"] = CUSTOM,
      ["NONE"] = NONE,
    },
  },
  forOthersGroup = {
    order = 3,
    type = "group",
    name = "",
    inline = true,
    args = {
      help = {
        order = 1,
        type = "description",
        name = L["Allow adding [name] into standby list by whispering \"epgp standby [name]\" if enabled."],
        fontSize = "medium",
      },
      forOthers = {
        type = "toggle",
        name = L["Allow whisper for others"],
        desc = L["Allow adding [name] into standby list by whispering \"epgp standby [name]\" if enabled."],
      },
    },
  },
  protectGroup = {
    order = 4,
    type = "group",
    name = L["Time protect"],
    inline = true,
    args = {
      help = {
        order = 1,
        type = "description",
        name = L["The standby list will be cleared x seconds after each reward."],
        fontSize = "medium",
      },
      protectTime = {
        name = L["Protect Time (sec)"],
        type = "range",
        min = 0,
        max = 1800,
        step = 1
      },
    },
  }
}

function mod:OnEnable()
  self:RegisterEvent("CHAT_MSG_WHISPER")
  EPGP.RegisterCallback(self, "MassEPAward", SendNotifiesAndClearExtras)
  EPGP.RegisterCallback(self, "StartRecurringAward", SendNotifiesAndClearExtras)
end

function mod:OnDisable()
  EPGP.UnregisterAllCallbacks(self)
end
