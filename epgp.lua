-- This is the core addon. It implements all functions dealing with
-- administering and configuring EPGP. It implements the following
-- functions:
--
-- StandingsSort(order): Sorts the standings list using the specified
-- sort order. Valid values are: NAME, EP, GP, PR. If order is nil it
-- returns the current value.
--
-- StandingsShowEveryone(val): Sets listing everyone or not in the
-- standings when in raid. If val is nil it returns the current
-- value.
--
-- GetNumMembers(): Returns the number of members in the standings.
--
-- GetMember(i): Returns the ith member in the standings based on the
-- current sort.
--
-- GetMain(name): Returns the main character for this member.
--
-- GetNumAlts(name): Returns the number of alts for this member.
--
-- GetAlt(name, i): Returns the ith alt for this member.
--
-- SelectMember(name): Select the member for award. Returns true if
-- the member was added, false otherwise.
--
-- DeSelectMember(name): Deselect member for award. Returns true if
-- the member was added, false otherwise.
--
-- GetNumMembersInAwardList(): Returns the number of members in the
-- award list.
--
-- IsMemberInAwardList(name): Returns true if member is in the award
-- list. When in a raid, this returns true for members in the raid and
-- members selected. When not in raid this returns true for everyone
-- if noone is selected or true if at least one member is selected and
-- the member is selected as well.
--
-- IsMemberInExtrasList(name): Returns true if member is in the award
-- list as an extra. When in a raid, this returns true if the member
-- is not in raid but is selected. When not in raid, this returns
-- false.
--
-- IsAnyMemberInExtrasList(name): Returns true if there is any member
-- in the award list as an extra.
--
-- ResetEPGP(): Resets all EP and GP to 0.
--
-- DecayEPGP(): Decays all EP and GP by the configured decay percent
-- (GetDecayPercent()).
--
-- CanIncEPBy(reason, amount): Return true reason and amount are
-- reasonable values for IncEPBy and the caller can change EPGP.
--
-- IncEPBy(name, reason, amount): Increases the EP of member <name> by
-- <amount>. Returns the member's main character name.
--
-- CanIncGPBy(reason, amount): Return true if reason and amount are
-- reasonable values for IncGPBy and the caller can change EPGP.
--
-- IncGPBy(name, reason, amount): Increases the GP of member <name> by
-- <amount>. Returns the member's main character name.
--
-- IncMassEPBy(reason, amount): Increases the EP of all members
-- in the award list. See description of IsMemberInAwardList.
--
-- RecurringEP(val): Sets recurring EP to true/false. If val is nil it
-- returns the current value.
--
-- RecurringEPPeriodMinutes(val): Sets the recurring EP period in
-- minutes. If val is nil it returns the current value.
--
-- GetDecayPercent(): Returns the decay percent configured in guild info.
--
-- CanDecayEPGP(): Returns true if the caller can decay EPGP.
--
-- GetBaseGP(): Returns the base GP configured in guild info.
--
-- GetMinEP(): Returns the min EP configured in guild info.
--
-- GetEPGP(name): Returns <ep, gp, main> for <name>. <main> will be
-- nil if this is the main toon, otherwise it will be the name of the
-- main toon since this is an alt. If <name> is an invalid name it
-- returns nil.
--
-- GetClass(name): Returns the class of member <name>. It returns nil
-- if the class is unknown.
--
-- ReportErrors(outputFunc): Calls function for each error during
-- initialization, one line at a time.
--
-- The library also fires the following messages, which you can
-- register for through RegisterCallback and unregister through
-- UnregisterCallback. You can also unregister all messages through
-- UnregisterAllCallbacks.
--
-- StandingsChanged: Fired when the standings have changed.
--
-- EPAward(name, reason, amount, mass): Fired when an EP award is
-- made.  mass is set to true if this is a mass award or decay.
--
-- MassEPAward(names, reason, amount,
--             extras_names, extras_reason, extras_amount): Fired
-- when a mass EP award is made.
--
-- GPAward(name, reason, amount, mass): Fired when a GP award is
-- made. mass is set to true if this is a mass award or decay.
--
-- BankedItem(name, reason, amount, mass): Fired when an item is
-- disenchanted or deposited directly to the Guild Bank. Name is
-- always the content of GUILD_BANK, amount is 0 and mass always nil.
--
-- StartRecurringAward(reason, amount, mins): Fired when recurring
-- awards are started.
--
-- StopRecurringAward(): Fired when recurring awards are stopped.
--
-- RecurringAwardUpdate(reason, amount, remainingSecs): Fired
-- periodically between awards with the remaining seconds to award in
-- seconds.
--
-- EPGPReset(): Fired when EPGP are reset.
--
-- Decay(percent): Fired when a decay happens.
--
-- DecayPercentChanged(v): Fired when decay percent changes. v is the
-- new value.
--
-- BaseGPChanged(v): Fired when base gp changes. v is the new value.
--
-- MinEPChanged(v): Fired when min ep changes. v is the new value.
--
-- ExtrasPercentChanged(v): Fired when extras percent changes.  v is
-- the new value.
--

local Debug = LibStub("LibDebug-1.0")
Debug:EnableDebugging()
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local DLG = LibStub("LibDialog-1.0")
local GPLib = LibStub("LibGearPoints-1.2")

EPGP = LibStub("AceAddon-3.0"):NewAddon(
  "EPGP", "AceEvent-3.0", "AceConsole-3.0")
local EPGP = EPGP
EPGP:SetDefaultModuleState(false)
local modulePrototype = {
  IsDisabled = function (self, i) return not self:IsEnabled() end,
  SetEnabled = function (self, i, v)
                 if v then
                   Debug("Enabling module: %s", self:GetName())
                   self:Enable()
                 else
                   Debug("Disabling module: %s", self:GetName())
                   self:Disable()
                 end
                 self.db.profile.enabled = v
               end,
  GetDBVar = function (self, i) return self.db.profile[i[#i]] end,
  SetDBVar = function (self, i, v) self.db.profile[i[#i]] = v end,
}
EPGP:SetDefaultModulePrototype(modulePrototype)

function EPGP:CurrentTier()
	local tier = math.floor(select(4, GetBuildInfo()) / 100)

	return tier
end

local version = GetAddOnMetadata('EPGP', 'Version')
if not version or #version == 0 then
  version = "(development)"
end
EPGP.version = version
EPGP.current_tier = EPGP:CurrentTier()

local CallbackHandler = LibStub("CallbackHandler-1.0")
if not EPGP.callbacks then
  EPGP.callbacks = CallbackHandler:New(EPGP)
end
local callbacks = EPGP.callbacks

local ep_data = {}
local gp_data = {}
local main_data = {}
local alt_data = {}
local ignored = {}
local standings = {}
local selected = {}
-- selected._count = 0  -- This is safe since _ is not allowed in names
local selected_count = 0

-- for compatibility with release of EPGP Lootmaster; remove after new LM is pushed
function EPGP:UnitInRaid(name)
  return UnitInRaid(Ambiguate(name, "none"))
end

function EPGP:DecodeNote(note)
  if note then
    if note == "" then
      return 0, 0
    else
      local ep, gp = string.match(note, "^(%d+),(%d+)$")
      if ep then
        return tonumber(ep), tonumber(gp)
      end
    end
  end
end

local function EncodeNote(ep, gp)
  return string.format("%d,%d",
                       math.max(ep, 0),
                       math.max(gp - EPGP.db.profile.base_gp, 0))
end

local function AddEPGP(name, ep, gp)
  local total_ep = ep_data[name]
  local total_gp = gp_data[name]
  assert(total_ep ~= nil and total_gp ~=nil,
         string.format("%s is not a main!", tostring(name)))

  -- Compute the actual amounts we can add/subtract.
  if (total_ep + ep) < 0 then
    ep = -total_ep
  end
  if (total_gp + gp) < 0 then
    gp = -total_gp
  end

  GS:SetNote(name, EncodeNote(total_ep + ep,
                              total_gp + gp + EPGP.db.profile.base_gp))
  return ep, gp
end

-- A wrapper function to handle sort logic for selected
local function ComparatorWrapper(f)
  return function(a, b)
           local a_in_raid = not not UnitInRaid(Ambiguate(a, "none"))
           local b_in_raid = not not UnitInRaid(Ambiguate(b, "none"))
           if a_in_raid ~= b_in_raid then
             return not b_in_raid
           end

           local a_selected = selected[a]
           local b_selected = selected[b]

           if a_selected ~= b_selected then
             return not b_selected
           end

           return f(a, b)
         end
end

local comparators = {
  NAME = function(a, b)
           return a < b
         end,
  EP = function(a, b)
         local a_ep, a_gp = EPGP:GetEPGP(a)
         local b_ep, b_gp = EPGP:GetEPGP(b)

         return a_ep > b_ep
       end,
  GP = function(a, b)
         local a_ep, a_gp = EPGP:GetEPGP(a)
         local b_ep, b_gp = EPGP:GetEPGP(b)

         return a_gp > b_gp
       end,
  PR = function(a, b)
         local a_ep, a_gp = EPGP:GetEPGP(a)
         local b_ep, b_gp = EPGP:GetEPGP(b)

         local a_qualifies = a_ep >= EPGP.db.profile.min_ep
         local b_qualifies = b_ep >= EPGP.db.profile.min_ep

         if a_qualifies == b_qualifies then
           return a_ep/a_gp > b_ep/b_gp
         else
           return a_qualifies
         end
       end,
}
for k,f in pairs(comparators) do
  comparators[k] = ComparatorWrapper(f)
end

local function DestroyStandings()
  wipe(standings)
  callbacks:Fire("StandingsChanged")
end

local function OutsidersChanged()
  Debug("outsider changed")
  GS:SetOutsidersEnabled(EPGP.db.profile.outsiders == 1)
end

local function SelectClearExpire()
  local t = time()
  for n, s in pairs(selected) do
    if s.expire and s.expire <= t then
      EPGP:DeSelectMember(n)
    end
  end
end

local function RefreshStandings(order, showEveryone)
  -- Debug("Resorting standings")
  if UnitInRaid("player") then
    SelectClearExpire()
    -- If we are in raid:
    ---  showEveryone = true: show all in raid (including alts) and
    ---  all leftover mains
    ---  showEveryone = false: show all in raid (including alts) and
    ---  all selected members
    for n in pairs(ep_data) do
      if showEveryone or UnitInRaid(Ambiguate(n, "none")) or selected[n] then
        table.insert(standings, n)
      end
    end
    for n in pairs(main_data) do
      if UnitInRaid(Ambiguate(n, "none")) or selected[n] then
        table.insert(standings, n)
      end
    end
  else
    -- If we are not in raid, show all mains
    for n in pairs(ep_data) do
      table.insert(standings, n)
    end
  end

  -- Sort
  table.sort(standings, comparators[order])
end

local function DeleteState(name)
  ignored[name] = nil
  -- If this is was an alt we need to fix the alts state
  local main = main_data[name]
  if main then
    if alt_data[main] then
      for i,alt in ipairs(alt_data[main]) do
        if alt == name then
          table.remove(alt_data[main], i)
          break
        end
      end
    end
    main_data[name] = nil
  end
  -- Delete any existing cached values
  ep_data[name] = nil
  gp_data[name] = nil
end

local function HandleDeletedGuildNote(callback, name)
  DeleteState(name)
  DestroyStandings()
end

local ourRealmName = string.gsub(GetRealmName(), "%s+", "")     -- Realm name with no spaces
function EPGP:GetOurRealmName()
  return ourRealmName
end

-- Convert name into Nickname-Realm format (add current realm if none specified)
function EPGP:GetFullCharacterName(name)
	if string.find(name, "%-") then
		return name;
	else
		return name .. "-" .. ourRealmName;
	end
end

-- Short name if on our server, full name if from different server
function EPGP:GetDisplayCharacterName(name)
	local dashIndex = string.find(name, "%-")
	if not dashIndex then
		return name			-- Already short, we assume it's on our server
	end

	if ourRealmName == string.sub(name, dashIndex + 1) then
		return string.sub(name, 1, dashIndex - 1)
	else
		return name
	end
end

local function ParseGuildNote(callback, name, note)
  -- Debug("Parsing Guild Note for %s [%s]", name, note)
  -- Delete current state about this toon.
  DeleteState(name)

  local ep, gp = EPGP:DecodeNote(note)
  if ep then
    ep_data[name] = ep
    gp_data[name] = gp
  else
    local mainName = note

    -- Allow specifying 'short' names in the officer notes, add the server by default
	mainName = EPGP:GetFullCharacterName(mainName)

    local main_ep = EPGP:DecodeNote(GS:GetNote(mainName))
    if not main_ep then
      -- This member does not point to a valid main, ignore it.
      ignored[name] = mainName
    else
      -- Debug("Alt %s of %s", name, mainName)

      -- Otherwise setup the alts state
      main_data[name] = mainName
      if not alt_data[mainName] then
        alt_data[mainName] = {}
      end
      table.insert(alt_data[mainName], name)
      ep_data[name] = nil
      gp_data[name] = nil
    end
  end
  DestroyStandings()
  GS:SetOutsidersEnabled(EPGP.db.profile.outsiders == 1)
end

function EPGP:IsRLorML()
  if UnitInRaid("player") then
    local loot_method, ml_party_id, ml_raid_id = GetLootMethod()
    if loot_method == "master" and ml_party_id == 0 then return true end
    if loot_method ~= "master" and IsInRaid() and UnitIsGroupLeader("player") then return true end
  end
  return false
end

function EPGP:ExportRoster()
  local base_gp = self.db.profile.base_gp
  local t = {}
  for name,_ in pairs(ep_data) do
    local ep, gp, main = self:GetEPGP(name)
    if ep ~= 0 or gp ~= base_gp then
      table.insert(t, {name, ep, gp})
    end
  end
  return t
end

function EPGP:ImportRoster(t, new_base_gp)
  -- This ugly hack is because EncodeNote reads base_gp to encode the
  -- GP properly. So we reset it to what we get passed, and then we
  -- restore it so that the BaseGPChanged event is fired properly when
  -- we parse the guild info text after this function returns.
  local old_base_gp = self.db.profile.base_gp
  self.db.profile.base_gp = new_base_gp

  local notes = {}
  for _, entry in pairs(t) do
    local name, ep, gp = unpack(entry)
	name = EPGP:GetFullCharacterName(name)
    notes[name] = EncodeNote(ep, gp)
  end

  local zero_note = EncodeNote(0, 0)
  for name,_ in pairs(ep_data) do
    local note = notes[name] or zero_note
    GS:SetNote(name, note)
  end

  self.db.profile.base_gp = old_base_gp
end

function EPGP:StandingsSort(order)
  if not order then
    return self.db.profile.sort_order
  end

  assert(comparators[order], "Unknown sort order")

  self.db.profile.sort_order = order
  DestroyStandings()
end

function EPGP:StandingsShowEveryone(val)
  if val == nil then
    return self.db.profile.show_everyone
  end

  self.db.profile.show_everyone = not not val
  DestroyStandings()
end

function EPGP:GetNumMembers()
  if #standings == 0 then
    RefreshStandings(self.db.profile.sort_order, self.db.profile.show_everyone)
  end

  return #standings
end

function EPGP:GetMember(i)
  if #standings == 0 then
    RefreshStandings(self.db.profile.sort_order, self.db.profile.show_everyone)
  end

  return standings[i]
end

function EPGP:GetNumAlts(name)
  local alts = alt_data[name]
  if not alts then
    return 0
  else
    return #alts
  end
end

function EPGP:GetAlt(name, i)
  return alt_data[name][i]
end

function EPGP:SelectMember(name)
  if UnitInRaid("player") then
    -- Only allow selecting members that are not in raid when in raid.
    if UnitInRaid(Ambiguate(name, "none")) then
      return false
    end
  end
  selected[name] = { expire = nil }
  selected_count = selected_count + 1
  EPGP.db.profile.selected[name] = { expire = nil }
  EPGP.db.profile.selected_count = EPGP.db.profile.selected_count + 1
  DestroyStandings()
  return true
end

function EPGP:DeSelectMember(name)
  if UnitInRaid("player") then
    -- Only allow deselecting members that are not in raid when in raid.
    if UnitInRaid(Ambiguate(name, "none")) then
      return false
    end
  end
  if not selected[name] then
    return false
  end
  selected[name] = nil
  selected_count = selected_count - 1
  EPGP.db.profile.selected[name] = nil
  EPGP.db.profile.selected_count = EPGP.db.profile.selected_count - 1
  DestroyStandings()
  return true
end

function EPGP:SelectMemberExpire(name, time_expire)
  selected[name].expire = time_expire
  EPGP.db.profile.selected[name].expire = time_expire
end

function EPGP:GetNumMembersInAwardList()
  if UnitInRaid("player") then
    return GetNumGroupMembers() + selected_count
  else
    if selected_count == 0 then
      return self:GetNumMembers()
    else
      return selected_count
    end
  end
end

function EPGP:IsMemberInAwardList(name)
  if UnitInRaid("player") then
    -- If we are in raid the member is in the award list if it is in
    -- the raid or the selected list.
    return UnitInRaid(Ambiguate(name, "none")) or selected[name]
  else
    -- If we are not in raid and there is noone selected everyone will
    -- get an award.
    if selected_count == 0 then
      return true
    end
    return selected[name]
  end
end

function EPGP:IsMemberInExtrasList(name)
  return UnitInRaid("player") and selected[name]
end

function EPGP:IsAnyMemberInExtrasList()
  return selected_count ~= 0
end

function EPGP:CanResetEPGP()
  return CanEditOfficerNote() and GS:IsCurrentState()
end

function EPGP:ResetEPGP()
  assert(EPGP:CanResetEPGP())

  local zero_note = EncodeNote(0, 0)
  for name,_ in pairs(ep_data) do
    GS:SetNote(name, zero_note)
    local ep, gp, main = self:GetEPGP(name)
    assert(main == nil, "Corrupt alt data!")
    if ep > 0 then
      callbacks:Fire("EPAward", name, "Reset", -ep, true)
    end
    if gp > 0 then
      callbacks:Fire("GPAward", name, "Reset", -gp, true)
    end
  end
  callbacks:Fire("EPGPReset")
end

function EPGP:ResetGP()
  assert(EPGP:CanResetEPGP())

  for i = 1, EPGP:GetNumMembers() do
    m = EPGP:GetMember(i)
    local ep, gp, main = EPGP:GetEPGP(m)
    actual_gp = gp - EPGP:GetBaseGP()
    if main == nil and actual_gp > 0 then
      local delta = -actual_gp
      EPGP:IncGPBy(m, "GP Reset", delta, true, false)
      if delta > 0 then
	callbacks:Fire("GPAward", name, "GP Reset", delta, true)
      end
    end
  end
  callbacks:Fire("GPReset")
end

function EPGP:RescaleGP()
  assert(EPGP:CanResetEPGP())

  for i = 1, EPGP:GetNumMembers() do
    m = EPGP:GetMember(i)
    local ep, gp, main = EPGP:GetEPGP(m)
    actual_gp = gp - EPGP:GetBaseGP()
    if main == nil and actual_gp > 0 then
      local decay_ilvl
      local ilvl_denominator = 26
      local version = select(4, GetBuildInfo())
      local level_cap = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
      if version < 60000 or level_cap == 90 then
        decay_ilvl = 26
      elseif version < 60200 then
        decay_ilvl = 10
        ilvl_denominator = 30
      else
        decay_ilvl = 30
        ilvl_denominator = 30
      end

      local delta = -(actual_gp - actual_gp / 2 ^ (decay_ilvl/ilvl_denominator))
      EPGP:IncGPBy(m, "GP Rescale", delta, true, false)
      if delta > 0 then
	callbacks:Fire("GPAward", name, "GP Decay", delta, true)
      end
    end
  end
  callbacks:Fire("GPRescale")
end

function EPGP:CanDecayEPGP()
  if not CanEditOfficerNote() or self.db.profile.decay_p == 0 or not GS:IsCurrentState() then
    return false
  end
  return true
end

function EPGP:DecayEPGP()
  assert(EPGP:CanDecayEPGP())

  local decay = self.db.profile.decay_p  * 0.01
  local reason = string.format("Decay %d%%", self.db.profile.decay_p)
  for name,_ in pairs(ep_data) do
    local ep, gp, main = self:GetEPGP(name)
    assert(main == nil, "Corrupt alt data!")
    local decay_ep = math.ceil(ep * decay)
    local decay_gp = math.ceil(gp * decay)
    decay_ep, decay_gp = AddEPGP(name, -decay_ep, -decay_gp)
    if decay_ep ~= 0 then
      callbacks:Fire("EPAward", name, reason, decay_ep, true)
    end
    if decay_gp ~= 0 then
      callbacks:Fire("GPAward", name, reason, decay_gp, true)
    end
  end
  callbacks:Fire("Decay", self.db.profile.decay_p)
end

function EPGP:GetEPGP(name)
  local main = main_data[name]
  if main then
    name = main
  end
  if ep_data[name] then
    return ep_data[name], gp_data[name] + self.db.profile.base_gp, main
  end
end

function EPGP:GetClass(name)
  return GS:GetClass(name)
end

function EPGP:CanIncEPBy(reason, amount)
  if not CanEditOfficerNote() or not GS:IsCurrentState() then
    return false
  end
  if type(reason) ~= "string" or type(amount) ~= "number" or #reason == 0 then
    return false
  end
  if amount ~= math.floor(amount + 0.5) then
    return false
  end
  if amount < -99999 or amount > 99999 or amount == 0 then
    return false
  end
  return true
end

function EPGP:IncEPBy(name, reason, amount, mass, undo)
  -- When we do mass EP or decay we know what we are doing even though
  -- CanIncEPBy returns false
  assert(EPGP:CanIncEPBy(reason, amount) or mass or undo)
  assert(type(name) == "string")

  local ep, gp, main = self:GetEPGP(name)
  if not ep then
    self:Print(L["Ignoring EP change for unknown member %s"]:format(name))
    return
  end
  amount = AddEPGP(main or name, amount, 0)
  if amount then
    callbacks:Fire("EPAward", name, reason, amount, mass, undo)
  end
  self.db.profile.last_awards[reason] = amount
  return main or name
end

function EPGP:CanIncGPBy(reason, amount)
  if not CanEditOfficerNote() or not GS:IsCurrentState() then
    return false
  end
  if type(reason) ~= "string" or type(amount) ~= "number" or #reason == 0 then
    return false
  end
  if amount ~= math.floor(amount + 0.5) then
    return false
  end
  if amount < -99999 or amount > 99999 then -- or amount == 0
    return false
  end
  return true
end

function EPGP:IncGPBy(name, reason, amount, mass, undo)
  -- When we do mass GP or decay we know what we are doing even though
  -- CanIncGPBy returns false
  assert(EPGP:CanIncGPBy(reason, amount) or mass or undo)
  assert(type(name) == "string")

  local ep, gp, main = self:GetEPGP(name)
  if not ep then
    self:Print(L["Ignoring GP change for unknown member %s"]:format(name))
    return
  end
  local _
  _, amount = AddEPGP(main or name, 0, amount)
  if amount then
    callbacks:Fire("GPAward", name, reason, amount, mass, undo)
  end

  return main or name
end

function EPGP:BankItem(reason, undo)
  callbacks:Fire("BankedItem", GUILD_BANK, reason, 0, false, undo)
end

function EPGP:GetDecayPercent()
  return self.db.profile.decay_p
end

function EPGP:GetExtrasPercent()
  return self.db.profile.extras_p
end

function EPGP:GetBaseGP()
  return self.db.profile.base_gp
end

function EPGP:GetMinEP()
  return self.db.profile.min_ep
end

function EPGP:SetGlobalConfiguration(decay_p, extras_p, base_gp, min_ep, outsiders)
  local guild_info = GS:GetGuildInfo()
  epgp_stanza = string.format(
    "-EPGP-\n@DECAY_P:%d\n@EXTRAS_P:%s\n@MIN_EP:%d\n@BASE_GP:%d\n@OUTSIDERS:%d\n-EPGP-",
    decay_p or DEFAULT_DECAY_P,
    extras_p or DEFAULT_EXTRAS_P,
    min_ep or DEFAULT_MIN_EP,
    base_gp or DEFAULT_BASE_GP,
    outsiders or DEFAULT_OUTSIDERS)

  -- If we have a global configuration stanza we need to replace it
  Debug("epgp_stanza:\n%s", epgp_stanza)
  if guild_info:match("%-EPGP%-.*%-EPGP%-") then
    guild_info = guild_info:gsub("%-EPGP%-.*%-EPGP%-", epgp_stanza)
  else
    guild_info = epgp_stanza.."\n"..guild_info
  end
  Debug("guild_info:\n%s", guild_info)
  SetGuildInfoText(guild_info)
  GuildRoster()
end

function EPGP:GetMain(name)
  return main_data[name] or name
end

function EPGP:IncMassEPBy(reason, amount)
  local awarded = {}
  local awarded_mains = {}
  local extras_awarded = {}
  local extras_amount = math.floor(self.db.profile.extras_p * 0.01 * amount)
  local extras_reason = reason .. " - " .. L["Standby"]

  SelectClearExpire()
  for i=1,EPGP:GetNumMembers() do
    local name = EPGP:GetMember(i)
    if EPGP:IsMemberInAwardList(name) then
      -- EPGP:GetMain() will return the input name if it doesn't find a main,
      -- so we can't use it to validate that this actually is a character who
      -- can recieve EP.
      --
      -- EPGP:GetEPGP() returns nil for ep and gp, if it can't find a
      -- valid member based on the name however.
      local ep, gp, main = EPGP:GetEPGP(name)
      local main = main or name
      if ep and not awarded_mains[main] then
        if EPGP:IsMemberInExtrasList(name) then
          EPGP:IncEPBy(name, extras_reason, extras_amount, true)
          extras_awarded[name] = true
        else
          EPGP:IncEPBy(name, reason, amount, true)
          awarded[name] = true
        end
        awarded_mains[main] = true
      end
    end
  end
  if next(awarded) then
    if next(extras_awarded) then
      callbacks:Fire("MassEPAward", awarded, reason, amount,
                     extras_awarded, extras_reason, extras_amount)
    else
      callbacks:Fire("MassEPAward", awarded, reason, amount)
    end
  end
end

function EPGP:ReportErrors(outputFunc)
  for name, note in pairs(ignored) do
    outputFunc(L["Invalid officer note [%s] for %s (ignored)"]:format(
                 note, name))
  end
end

function EPGP:OnInitialize()
  -- Setup the DB. The DB will NOT be ready until after OnEnable is
  -- called on EPGP. We do not call OnEnable on modules until after
  -- the DB is ready to use.
  self.db = LibStub("AceDB-3.0"):New("EPGP_DB")

  local defaults = {
    profile = {
      last_awards = {},
      show_everyone = false,
      sort_order = "PR",
      recurring_ep_period_mins = 15,
      decay_p = 0,
      extras_p = 100,
      min_ep = 0,
      base_gp = 1,
      bonus_loot_log = {},
    }
  }

  self.db:RegisterDefaults(defaults)

  -- After the database objects are created, we setup the
  -- options. Each module can inject its own options by defining:
  --
  -- * module.optionsName: The name of the options group for this module
  -- * module.optionsDesc: The description for this options group [short]
  -- * module.optionsArgs: The definition of this option group
  --
  -- In addition to the above EPGP will add an Enable checkbox for
  -- this module. It is also guaranteed that the name of the node this
  -- group will be in, is the same as the name of the module. This
  -- means you can get the name of the module from the info table
  -- passed to the callback functions by doing info[#info-1].
  --
  self:SetupOptions()

  -- New version note.
  if self.db.global.last_version ~= EPGP.version then
    self.db.global.last_version = EPGP.version
    DLG:Spawn("EPGP_NEW_VERSION")
  end
end

function EPGP:PLAYER_ENTERING_WORLD()
  -- We use this event because, apparently, CanEditOfficerNote can
  -- return nil in 4.3 if you aren't fully logged in yet (!)
  if self.db.global.last_tier ~= EPGP.current_tier then
    self.db.global.last_tier = EPGP.current_tier
    if CanEditOfficerNote() then
      DLG:Spawn("EPGP_NEW_TIER")
    end
  end
end

function EPGP:GROUP_ROSTER_UPDATE()
  if UnitInRaid("player") then
    -- If we are in a raid, make sure no member of the raid is
    -- selected
    for name,_ in pairs(selected) do
      if UnitInRaid(Ambiguate(name, "none")) then
        selected[name] = nil
        selected_count = selected_count - 1
        EPGP.db.profile.selected[name] = nil
        EPGP.db.profile.selected_count = EPGP.db.profile.selected_count - 1
      end
    end
  else
    -- If we are not in a raid, this means we just left so remove
    -- everyone from the selected list.
    wipe(selected)
    selected_count = 0
    wipe(EPGP.db.profile.selected)
    EPGP.db.profile.selected_count = 0
    -- We also need to stop any recurring EP since they should stop
    -- once a raid stops.
    if self:RunningRecurringEP() then
      self:StopRecurringEP()
    end
  end
  DestroyStandings()
end

function EPGP:ResumeSelected()
  local vars = EPGP.db.profile
  if not vars.selected or not vars.selected_count then
    vars.selected = {}
    vars.selected_count = 0
    return false
  end

  for name, value in pairs(vars.selected) do
    selected[name] = value
  end
  selected_count = vars.selected_count

  return true
end

local initialized = false
function EPGP:GUILD_ROSTER_UPDATE()
  if not IsInGuild() then
    Debug("Not in guild, disabling modules")
    for name, module in EPGP:IterateModules() do
      module:Disable()
    end
  else
    local guild = GetGuildInfo("player") or ""
    if #guild == 0 then
      GuildRoster()
    else
      if self.db:GetCurrentProfile() ~= guild then
        Debug("Setting DB profile to: %s", guild)
        self.db:SetProfile(guild)
      end
      if not initialized then
        initialized = true

        EPGP:ResumeSelected()

        -- Enable all modules that are supposed to be enabled
        for name, module in EPGP:IterateModules() do
          if not module.db or module.db.profile.enabled or not module.dbDefaults then
            Debug("Enabling module (startup): %s", name)
            module:Enable()
          end
        end

        -- Check if we have a recurring award we can resume
        if EPGP:CanResumeRecurringEP() then
          EPGP:ResumeRecurringEP()
        else
          EPGP:CancelRecurringEP()
        end
      end
    end
  end
end

function EPGP:LogBonusLootRoll(player, coinsLeft, reward, currencyID)
  -- local weekday, month, day, year = C_Calendar.GetDate()
  local month = tonumber(date("%m"))
  local day = tonumber(date("%d"))
  local year = tonumber(date("%Y"))

  local hour, minute = GetGameTime()
  local timestamp = string.format("%04d-%02d-%02d %02d:%02d:00", year, month, day, hour, minute)
  local entry = {
    timestamp = timestamp,
    player = player,
    coinsLeft = coinsLeft,
    reward = reward,
    currencyID = currencyID
  }

  table.insert(self.db.profile.bonus_loot_log, entry)
end

function EPGP:PrintCoinLog(num, show_gold)
  DEFAULT_CHAT_FRAME:AddMessage("Recent coin rewards:")
  local to_show = {}
  for i = #self.db.profile.bonus_loot_log, 1, -1 do
    local e = self.db.profile.bonus_loot_log[i]
    if show_gold or e.reward then
      table.insert(to_show, 1, e)
      if #to_show == num then
	break
      end
    end
  end
  for _, e in pairs(to_show) do
    local currency_info = ""
    if e.currencyID ~= nil and tonumber(e.currencyID) > 0 then
      local currency_name = GetCurrencyInfo(e.currencyID)
      currency_info = string.format(" (%d %s remaining)", e.coinsLeft, currency_name)
    end
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: %s got %s%s", e.timestamp, e.player, e.reward or "gold", currency_info))
  end
end

local UpdateFrame = nil
function EPGP:OnEnable()
  GS.RegisterCallback(self, "GuildNoteChanged", ParseGuildNote)
  GS.RegisterCallback(self, "GuildNoteDeleted", HandleDeletedGuildNote)

  EPGP.RegisterCallback(self, "BaseGPChanged", DestroyStandings)
  EPGP.RegisterCallback(self, "OutsidersChanged", OutsidersChanged)

  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  UpdateFrame = UpdateFrame or CreateFrame("Frame")
  UpdateFrame:SetScript("OnUpdate", nil)

  local function UpdateFrameOnUpdate(self, elapsed)
    self:SetScript("OnUpdate", nil)
    if self.GroupRosterUpdated then EPGP:GROUP_ROSTER_UPDATE() end
    self.GroupRosterUpdated = nil
    if self.GuildRosterUpdated then EPGP:GUILD_ROSTER_UPDATE() end
    self.GuildRosterUpdated = nil
  end

  self:RegisterEvent("GROUP_ROSTER_UPDATE",
    function()
      UpdateFrame.GroupRosterUpdated = true
      UpdateFrame:SetScript("OnUpdate", UpdateFrameOnUpdate)
    end)
  self:RegisterEvent("GUILD_ROSTER_UPDATE",
    function()
      UpdateFrame.GuildRosterUpdated = true
      UpdateFrame:SetScript("OnUpdate", UpdateFrameOnUpdate)
    end)

  GuildRoster()
end
