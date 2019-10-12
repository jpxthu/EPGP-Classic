local mod = EPGP:NewModule("warnings", "AceHook-3.0")
local DLG = LibStub("LibDialog-1.0")

local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

DLG:Register("EPGP_OFFICER_NOTE_WARNING", {
  text = L["EPGP is using Officer Notes for data storage. Do you really want to edit the Officer Note by hand?"],
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.YES,
      on_click = function(self)
        self:Hide()
        mod.hooks[GuildMemberOfficerNoteBackground]["OnMouseUp"]()
      end,
    },
    {
      text = _G.NO,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
})

DLG:Register("EPGP_MULTIPLE_MASTERS_WARNING", {
  text = L["Make sure you are the only person changing EP and GP. If you have multiple people changing EP and GP at the same time, for example one awarding EP and another crediting GP, you *are* going to have data loss."],
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.OKAY,
    },
  },
  hide_on_escape = true,
  show_while_dead = true,
  time_remaining = 15,
})

mod.dbDefaults = {
  profile = {
    enabled = true,
  }
}

function mod:OnInitialize()
  self.db = EPGP.db:RegisterNamespace("warnings", mod.dbDefaults)
end

function mod:OnEnable()
  local function officer_note_warning()
    DLG:Spawn("EPGP_OFFICER_NOTE_WARNING")
  end

  if GuildMemberOfficerNoteBackground and
     GuildMemberOfficerNoteBackground:HasScript("OnMouseUp") then
    self:RawHookScript(GuildMemberOfficerNoteBackground, "OnMouseUp",
                       officer_note_warning)
  end

  local events_for_multiple_masters_warning = {
    "StartRecurringAward",
    "EPAward",
    "GPAward",
  }

  -- We want to show this warning just once.
  local function multiple_masters_warning()
    if not UnitAffectingCombat("player") then
      DLG:Spawn("EPGP_MULTIPLE_MASTERS_WARNING")
    end
    for _, event in pairs(events_for_multiple_masters_warning) do
      EPGP.UnregisterCallback(self, event)
    end
  end

  for _, event in pairs(events_for_multiple_masters_warning) do
    EPGP.RegisterCallback(self, event, multiple_masters_warning)
  end
end
