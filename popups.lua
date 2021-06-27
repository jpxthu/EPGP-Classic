local DLG = LibStub("LibDialog-1.0")
local GP = LibStub("LibGearPoints-1.3")
local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local LE = LibStub("AceLocale-3.0"):GetLocale("LibEncounters")

DLG:Register("EPGP_CONFIRM_GP_CREDIT", {
  text = "Unknown Item",
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        local gp = tonumber(self.editboxes[1]:GetText())
        EPGP:IncGPBy(data.name, data.item, gp)
      end,
    },
    {
      text = _G.CANCEL,
    },
    {
      text = _G.GUILD_BANK,
      on_click = function(self, data, reason)
        EPGP:BankItem(data.item)
      end,
    },
  },
  editboxes = {
    {
      auto_focus = true,
    },
  },
  on_show = function(self, data)
    local text = ("\n"..L["Credit GP to %s"].."\n"):format(data.item)
    local edit = ""
    self.icon:SetTexture(data.icon)
    local gp1, c1, gp2, c2, gp3, c3 = GP:GetValue(data.item)
    if gp1 then
      text = text .. ("\nGP1: %d (%s)"):format(gp1, c1)
      edit = tostring(gp1)
    end
    if gp2 then
      text = text .. ("\nGP2: %d (%s)"):format(gp2, c2)
      edit = edit .. (" or %d"):format(gp2)
    end
    if gp3 then
      text = text .. ("\nGP3: %d (%s)"):format(gp3, c3)
      edit = edit .. (" or %d"):format(gp3)
    end
    self.text:SetFormattedText(text)
    self.editboxes[1]:SetText(edit)
    self.editboxes[1]:HighlightText()
    if not self.icon_frame then
      local icon_frame = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate");
      icon_frame:ClearAllPoints()
      icon_frame:SetAllPoints(self.icon)
      icon_frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", - 3, icon_frame:GetHeight() + 6)
        GameTooltip:SetHyperlink(self:GetParent().data.item)
      end)
      icon_frame:SetScript("OnLeave", function(self)
        GameTooltip:FadeOut()
      end)
      self.icon_frame = icon_frame
    end
    if self.icon_frame then
      self.icon_frame:EnableMouse(true)
      self.icon_frame:Show()
    end
  end,
  on_hide = function(self, data)
    if ChatEdit_GetActiveWindow() then
      ChatEdit_FocusActiveWindow()
    end
    if self.icon_frame then
      self.icon_frame:EnableMouse(false)
      self.icon_frame:Hide()
    end
  end,
  on_update = function(self, elapsed)
    local gp = tonumber(self.editboxes[1]:GetText())
    if EPGP:CanIncGPBy(self.data.item, gp) then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_DECAY_EPGP", {
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        EPGP:DecayEPGP()
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  on_show = function(self, data)
    local t = L["Decay EP and GP by %d%%?"]
    local vars = EPGP.db.profile
    if not vars.manageRankAll then
      for i = 1, GuildControlGetNumRanks() do
        if vars.manageRank[i] then
          t = t .. "\n" .. GuildControlGetRankName(i)
        end
      end
    end
    self.text:SetFormattedText(t, data)
  end,
  on_update = function(self, elapsed)
    if EPGP:CanDecayEPGP() then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_RESET_EPGP", {
  text = L["Reset all main toons' EP and GP to 0?"],
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        EPGP:ResetEPGP()
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  on_update = function(self, elapsed)
    if EPGP:CanResetEPGP() then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_RESET_GP", {
  text = L["Reset all main toons' GP to 0?"],
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        EPGP:ResetGP()
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  on_update = function(self, elapsed)
    if EPGP:CanResetEPGP() then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_RESCALE_GP", {
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        EPGP:RescaleGP(data)
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  on_show = function(self, data)
    self.text:SetFormattedText(L["Re-scale all main toons' GP to current tier?"] .. " (+%d)", data)
  end,
  on_update = function(self, elapsed)
    if EPGP:CanResetEPGP() then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_MASS_ADJUST_GP", {
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        EPGP:AdjustGP(data)
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  on_show = function(self, data)
    self.text:SetFormattedText(L["Adjust all main toons' GP?"] .. " (%d)", data)
  end,
  on_update = function(self, elapsed)
    if EPGP:CanResetEPGP() then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_BOSS_DEAD", {
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        local ep = tonumber(self.editboxes[1]:GetText())
        EPGP:IncMassEPBy(data, ep)
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  editboxes = {
    {
      auto_focus = true,
    },
  },
  on_show = function(self, data)
    self.text:SetFormattedText(L["%s is dead. Award EP?"], data)
    self.editboxes[1]:SetText("")
  end,
  on_hide = function(self, data)
    if ChatEdit_GetActiveWindow() then
      ChatEdit_FocusActiveWindow()
    end
  end,
  on_update = function(self, elapsed)
    local ep = tonumber(self.editboxes[1]:GetText())
    if EPGP:CanIncEPBy(self.data, ep) then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  show_while_dead = true,
})

DLG:Register("EPGP_BOSS_ATTEMPT", {
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        local ep = tonumber(self.editboxes[1]:GetText())
        EPGP:IncMassEPBy(data .. " (attempt)", ep)
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  editboxes = {
    {
    --  on_escape_pressed = function(editbox, data)
    --  end,
    --  on_text_changed = function(editbox, data)
    --  end,
    --  on_enter_pressed = function(editbox, data)
    --  end,
      auto_focus = true,
    },
  },
  on_show = function(self, data)
    self.text:SetFormattedText(L["Wiped on %s. Award EP?"], data)
    self.editboxes[1]:SetText("")
  end,
  on_hide = function(self, data)
    if ChatEdit_GetActiveWindow() then
      ChatEdit_FocusActiveWindow()
    end
  end,
  on_update = function(self, elapsed)
    local ep = tonumber(self.editboxes[1]:GetText())
    if EPGP:CanIncEPBy(self.data, ep) then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  show_while_dead = true,
})

DLG:Register("EPGP_BOSS_AUTO_REWARD_ENABLE", {
  text = L["WHETHER_TO_START_BOSS_AUTO_REWARD"],
  buttons = {
    {
      text = _G.YES,
      on_click = function(self)
        EPGP:GetModule("boss"):EnableAutoReward()
      end,
    },
    {
      text = _G.NO,
      on_click = function(self)
        EPGP:GetModule("boss"):DisableAutoReward()
      end,
    },
  },
  show_while_dead = true,
})

DLG:Register("EPGP_LOOTMASTER_ASK_TRACKING", {
  text = "You are the Loot Master, would you like to use EPGP Lootmaster to distribute loot?\r\n\r\n(You will be asked again next time. Use the configuration panel to change this behaviour)",
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.YES,
      on_click = function(self)
        EPGP:GetModule("lootmaster"):EnableTracking()
        EPGP:Print('You have enabled loot tracking for this raid')
      end,
    },
    {
      text = _G.NO,
      on_click = function(self)
        EPGP:GetModule("lootmaster"):DisableTracking()
        EPGP:Print('You have disabled loot tracking for this raid')
      end,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_NEW_VERSION", {
  text = "|cFFFFFF00EPGP " .. EPGP.version .. "|r\n" ..
    L["You can now check your epgp standings and loot on the web: http://www.epgpweb.com"] .. "\n\n" ..
    -- L["NEW_VERSION_INTRO_1_5_0"]:format(_G.UIOPTIONS_MENU, _G.ADDONS, _G.BOSS, _G.UIOPTIONS_MENU, _G.ADDONS, L["Logs"]),
    -- L["Some 3rd-party EPGP system were launched. Details in: EPGP -> %s -> %s"]:format(L["Logs"], L["Export Detail"]),
    L["%s %s"]:format(L["[%s] is comming!"]:format("TBC"), L["You should probably: increase standard_ilvl, reset or rescale GP."]) .. "\n" ..
    string.format("(%s -> %s -> EPGP -> %s / %s)", _G.UIOPTIONS_MENU, _G.ADDONS, L["Gear Points"], L["Rescale GP"]), -- /script EPGP.db.profile.last_version = nil
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.OKAY,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_NEW_TIER", {
  text = "|cFFFFFF00EPGP " .. EPGP.version .. "|r\n" ..
    L["%s %s"]:format(L["A new tier is here!"], L["You should probably: increase standard_ilvl, reset or rescale GP."]) .. "\n" ..
    string.format("(%s -> %s -> EPGP -> %s / %s)", _G.UIOPTIONS_MENU, _G.ADDONS, L["Gear Points"], L["Rescale GP"]), -- /script EPGP.db.profile.last_tier = nil
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.OKAY,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_SETTINGS_RECEIVED", {
  on_show = function(self, data)
    local t = L["SETTINGS_RECEIVED_POPUP_TEXT"]
    t = format(t, data, L["Trust"], data)
    self.text:SetText(t)
  end,
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data)
        local mod = EPGP:GetModule("sync")
        local name = data
        print(name)
        print(type(name))
        mod:AcceptSettings(name)
      end,
    },
    {
      text = L["Trust"],
      on_click = function(self, data)
        local mod = EPGP:GetModule("sync")
        mod:AcceptSettings(data)
        mod:AddTrustList(data)
      end,
    },
    {
      text = _G.CANCEL,
    },
  }
})

DLG:Register("EPGP_REMIND_ENABLE_COMBATLOG", {
  text = L["COMBATLOG_ENABLE_REMIND_MSG"],
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.YES,
      on_click = function(self)
        if LoggingCombat(true) then
          EPGP:Print(_G.COMBATLOGENABLED)
        else
          EPGP:Print(L["COMBATLOG_ENABLE_FAIL"])
        end
      end,
    },
    {
      text = _G.NO,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
})
