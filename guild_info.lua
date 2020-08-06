local Debug = LibStub("LibDebug-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local AE = LibStub("AceEvent-3.0")

-- Parse options. Options are inside GuildInfo and are inside a -EPGP-
-- block. Possible options are:
--
-- @DECAY_P:<number>
-- @EXTRAS_P:<number>
-- @MIN_EP:<number>
-- @BASE_GP:<number>
-- @OUTSIDERS:[0 or 1]
local global_config_defs = {
  decay_p = {
    pattern = "@DECAY_P:%s*(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 and v <= 100 end,
    error = L["Decay Percent should be a number between 0 and 100"],
    warned = false,
    default = 0,
    change_message = "DecayPercentChanged",
  },
  extras_p = {
    pattern = "@EXTRAS_P:%s*(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 and v <= 100 end,
    error = L["Extras Percent should be a number between 0 and 100"],
    warned = false,
    default = 100,
    change_message = "ExtrasPercentChanged",
  },
  min_ep = {
    pattern = "@MIN_EP:%s*(-?%d+)",
    parser = tonumber,
    validator = function(v) return true end,
    error = "",
    -- validator = function(v) return v >= 0 end,
    -- error = L["Min EP should be a positive number (>= 0)"],
    warned = false,
    default = 0,
    change_message = "MinEPChanged",
  },
  base_gp = {
    pattern = "@BASE_GP:%s*(%d+)",
    parser = tonumber,
    validator = function(v) return v >= 0 end,
    error = L["Base GP should be a positive number (>= 0)"],
    warned = false,
    default = 1,
    change_message = "BaseGPChanged",
  },
  outsiders = {
    pattern = "@OUTSIDERS:%s*(%d+)",
    parser = tonumber,
    validator = function(v) return v == 0 or v == 1  end,
    error = L["Outsiders should be 0 or 1"],
    warned = false,
    default = 0,
    change_message = "OutsidersChanged",
  },
  decay_base_gp = {
    pattern = "@DECAY_BASE_GP:%s*(%d+)",
    parser = tonumber,
    validator = function(v) return v == 0 or v == 1  end,
    error = L["Decay BASE_GP should be 0 or 1"],
    warned = false,
    default = 1,
    change_message = "DecayBaseGpChanged",
  },
}

local function ParseGuildInfo(loc)
  if not EPGP.db then
    Debug("EPGP db not loaded")
    return
  end
  local info = GetGuildInfoText()
  if not info then
    Debug("GuildInfoText empty or nil, ignoring")
    return
  end
  Debug("Parsing GuildInfoText")

  local lines = {string.split("\n", info)}
  local in_block = false

  local new_config = {}

  for _,line in pairs(lines) do
    if line == "-EPGP-" then
      in_block = not in_block
    elseif in_block then
      for var, def in pairs(global_config_defs) do
        local v = line:match(def.pattern)
        if v then
          -- Debug("Matched [%s]", line)
          v = def.parser(v)
          if v == nil or not def.validator(v) then
            Debug(def.error)
            if not def.warned then
              def.warned = true
              EPGP:Print(def.error)
            end
          else
            new_config[var] = v
          end
        end
      end
    end
  end
  for var, def in pairs(global_config_defs) do
    local new_value = new_config[var] or def.default
    EPGP.db.profile[var .. "_guild_info"] = new_value
    if not EPGP.db.profile.useCustomGuildOptions then
      local old_value = EPGP.db.profile[var]
      EPGP.db.profile[var] = new_value
      if old_value ~= new_value then
        Debug("%s changed from %s to %s", var, old_value or 0, new_value or 0)
        EPGP.callbacks:Fire(def.change_message, new_value)
      end
    end
  end
end

function EPGP:SetOutdisers(v)
  if not v then return end
  self.db.profile.outsiders = v
  self.callbacks:Fire(global_config_defs.outsiders.change_message, v)
end

function EPGP:SetDecayPercent(v)
  if not v then return end
  self.db.profile.decay_p = v
  self.callbacks:Fire(global_config_defs.decay_p.change_message, v)
end

function EPGP:SetExtrasPercent(v)
  if not v then return end
  self.db.profile.extras_p = v
  self.callbacks:Fire(global_config_defs.extras_p.change_message, v)
end

function EPGP:SetBaseGP(v)
  if not v then return end
  self.db.profile.base_gp = v
  self.callbacks:Fire(global_config_defs.base_gp.change_message, v)
end

function EPGP:SetMinEP(v)
  if not v then return end
  self.db.profile.min_ep = v
  self.callbacks:Fire(global_config_defs.min_ep.change_message, v)
end

function EPGP:SetDecayBaseGp(v)
  if not v then return end
  self.db.profile.decay_base_gp = v
  self.callbacks:Fire(global_config_defs.decay_base_gp.change_message, v)
end

function EPGP:ValidOutdisers(v)
  if not v then return false end
  return global_config_defs.outsiders.validator(v)
end

function EPGP:ValidDecayPercent(v)
  if not v then return false end
  return global_config_defs.decay_p.validator(v)
end

function EPGP:ValidExtrasPercent(v)
  if not v then return false end
  return global_config_defs.extras_p.validator(v)
end

function EPGP:ValidBaseGP(v)
  if not v then return false end
  return global_config_defs.base_gp.validator(v)
end

function EPGP:ValidMinEP(v)
  if not v then return false end
  return global_config_defs.min_ep.validator(v)
end

AE:RegisterEvent("GUILD_ROSTER_UPDATE", ParseGuildInfo)
