local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local GP = LibStub("LibGearPoints-1.3")
local Debug = LibStub("LibDebug-1.0")
local DLG = LibStub("LibDialog-1.0")
local LLN = LibStub("LibLootNotify-1.0")

function EPGP:SetupOptions()
  self.firstOpen = true
  local options = {
    name = "EPGP",
    type = "group",
    childGroups = "tab",
    handler = self,
    args = {
      help = {
        order = 1,
        type = "description",
        name = L["EPGP is an in game, relational loot distribution system"],
        fontSize = "medium",
      },
      hint = {
        order = 2,
        type = "description",
        name = L["Hint: You can open these options by typing /epgp config"],
        fontSize = "medium",
      },
      list_errors = {
        order = 1000,
        type = "execute",
        name = L["List errors"],
        desc = L["Lists errors during officer note parsing to the default chat frame. Examples are members with an invalid officer note."],
        func = function()
                 outputFunc = function(s) DEFAULT_CHAT_FRAME:AddMessage(s) end
                 EPGP:ReportErrors(outputFunc)
               end,
      },
      reset = {
        order = 1001,
        type = "execute",
        name = L["Reset EPGP"],
        desc = L["Resets EP and GP of all members of the guild. This will set all main toons' EP and GP to 0. Use with care!"],
        func = function() DLG:Spawn("EPGP_RESET_EPGP") end,
      },
      reset_gp = {
        order = 1002,
        type = "execute",
        name = L["Reset only GP"],
        desc = L["Resets GP (not EP!) of all members of the guild. This will set all main toons' GP to 0. Use with care!"],
        func = function() DLG:Spawn("EPGP_RESET_GP") end,
      },
      allow_negative_ep = {
        order = 2000,
        type = "toggle",
        name = L["ALLOW_NEGATIVE_EP_NAME"],
        desc = L["ALLOW_NEGATIVE_EP_DESC"],
        width = 30,
        get = function() return self.db.profile.allow_negative_ep end,
        set = function(info, v) self.db.profile.allow_negative_ep = v end,
      },
      remind_enable_combatlog = {
        order = 2001,
        type = "toggle",
        name = L["COMBATLOG_REMIND_ENABLE_NAME"],
        desc = L["COMBATLOG_REMIND_ENABLE_DESC"],
        width = 30,
        get = function() return self.db.profile.remind_enable_combatlog end,
        set = function(info, v) self.db.profile.remind_enable_combatlog = v end,
      },
    },
  }

  local registry = LibStub("AceConfigRegistry-3.0")
  registry:RegisterOptionsTable("EPGP Options", options)

  local dialog = LibStub("AceConfigDialog-3.0")
  dialog:AddToBlizOptions("EPGP Options", "EPGP")

  -- Setup options for each module that defines them.
  for name, m in self:IterateModules() do
    if m.optionsArgs then
      -- Set all options under this module as disabled when the module
      -- is disabled.
      for n, o in pairs(m.optionsArgs) do
        if o.disabled then
          local old_disabled = o.disabled
          o.disabled = function(i)
                         return old_disabled(i) or m:IsDisabled()
                       end
        else
          o.disabled = "IsDisabled"
        end
      end
      -- Add the enable/disable option.
      m.optionsArgs.enabled = {
        order = 0,
        type = "toggle",
        width = "full",
        name = ENABLE,
        get = "IsEnabled",
        set = "SetEnabled",
      }
    end
    if m.optionsName then
      registry:RegisterOptionsTable("EPGP " .. name, {
                                      handler = m,
                                      order = 100,
                                      type = "group",
                                      name = m.optionsName,
                                      desc = m.optionsDesc,
                                      args = m.optionsArgs,
                                      get = "GetDBVar",
                                      set = "SetDBVar",
                                    })
      dialog:AddToBlizOptions("EPGP " .. name, m.optionsName, "EPGP")
    end
  end

  EPGP:RegisterChatCommand("epgp", "ProcessCommand")
end

function EPGP:ProcessCommand(str)
  str = str:gsub("%%t", UnitName("target") or "notarget")
  local command, nextpos = self:GetArgs(str, 1)
  if command == "config" then
    if self.firstOpen then
      -- long standing WOW interface bug where the config does not open the first time you execute it
      self.firstOpen = false
      InterfaceOptionsFrame_OpenToCategory("EPGP")
    end
    InterfaceOptionsFrame_OpenToCategory("EPGP")
  elseif command == "debug" then
    Debug:Toggle()
  elseif command == "massep" then
    local reason, amount = self:GetArgs(str, 2, nextpos)
    amount = tonumber(amount)
    if self:CanIncEPBy(reason, amount) then
      self:IncMassEPBy(reason, amount)
    end
  elseif command == "ep" then
    local member, reason, amount = self:GetArgs(str, 3, nextpos)
    amount = tonumber(amount)
    if self:CanIncEPBy(reason, amount) then
      self:IncEPBy(self:GetFullCharacterName(member), reason, amount)
    end
  elseif command == "gp" then
    local member, itemlink, amount = self:GetArgs(str, 3, nextpos)
    self:Print(member, itemlink, amount)
    if amount then
      amount = tonumber(amount)
    else
      local gp1, _, gp2 = GP:GetValue(itemlink)
      self:Print(gp1, gp2)
      -- Only automatically fill amount if we have a single GP value.
      if gp1 and not gp2 then
        amount = gp1
      end
    end

    if self:CanIncGPBy(itemlink, amount) then
      self:IncGPBy(self:GetFullCharacterName(member), itemlink, amount)
    end
  elseif command == "decay" then
    if EPGP:CanDecayEPGP() then
      DLG:Spawn("EPGP_DECAY_EPGP", EPGP:GetDecayPercent())
    end
  elseif command == "coins" or command == "coin" then
    local num, show_gold = self:GetArgs(str, 2, nextpos)
    if num then
      num = tonumber(num)
    else
      num = 10
    end

    EPGP:PrintCoinLog(num, show_gold)
  elseif command == "fakecoin" then
    local item = self:GetArgs(str, 1, nextpos)
    EPGP:FakeCoinEvent(item)
  elseif command == "help" then
    local help = {
      self.version,
      "   config - "..L["Open the configuration options"],
      "   debug - "..L["Open the debug window"],
      "   massep <reason> <amount> - "..L["Mass EP Award"],
      "   ep <name> <reason> <amount> - "..L["Award EP"],
      "   gp <name> <itemlink> [<amount>] - "..L["Credit GP"],
      "   decay - "..L["Decay of EP/GP by %d%%"]:format(EPGP:GetDecayPercent()),
    }
    EPGP:Print(table.concat(help, "\n"))
  else
    EPGP:ToggleUI()
  end
end

function EPGP:FakeCoinEvent(item)
  LLN.BonusMessageReceiver(nil, string.format("BONUS_LOOT_RESULT^%s^%s^%s^%s", "item", item, 32, 776),
                           nil, UnitName("player"))
end

function EPGP:ToggleUI()
  if EPGPFrame and IsInGuild() then
    if EPGPFrame:IsShown() then
      HideUIPanel(EPGPFrame)
    else
      ShowUIPanel(EPGPFrame)
    end
  end
end
