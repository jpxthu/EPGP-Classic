local mod = EPGP:NewModule("options")

local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

local headers = {}
local frames = {}

local function TableHeaderOnClickFunc(self)
  for i, h in pairs(headers) do
    local index = h.index
    local f = frames[index]
    if index == self.index then
      h:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
      if f then
        f:Show()
        if f.OnShowFunc then f:OnShowFunc() end
      end
    else
      h:SetNormalTexture(nil)
      if f then
        f:Hide()
      end
    end
  end
end

local function CreateTableHeader(parent, text, index)
  local h = CreateFrame("Button", nil, parent)
  h.index = index
  h:SetHeight(24)

  local tl = h:CreateTexture(nil, "BACKGROUND")
  tl:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tl:SetWidth(5)
  tl:SetHeight(24)
  tl:SetPoint("TOPLEFT")
  tl:SetTexCoord(0, 0.07815, 0, 0.75)

  local tr = h:CreateTexture(nil, "BACKGROUND")
  tr:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tr:SetWidth(5)
  tr:SetHeight(24)
  tr:SetPoint("TOPRIGHT")
  tr:SetTexCoord(0.90625, 0.96875, 0, 0.75)

  local tm = h:CreateTexture(nil, "BACKGROUND")
  tm:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
  tm:SetHeight(24)
  tm:SetPoint("LEFT", tl, "RIGHT")
  tm:SetPoint("RIGHT", tr, "LEFT")
  tm:SetTexCoord(0.07815, 0.90625, 0, 0.75)

  h:SetNormalFontObject("GameFontHighlightSmall")
  h:SetText(text)
  -- h:GetFontString():SetJustifyH(justifyH)
  h:SetWidth(h:GetTextWidth() + 20)
  h:SetHighlightTexture(
    "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
  h:SetScript("OnClick", TableHeaderOnClickFunc)

  if #headers == 0 then
    h:SetPoint("TOPLEFT", 15, -15)
  else
    h:SetPoint("LEFT", headers[#headers], "RIGHT")
  end
  table.insert(headers, h)
end

function mod:FillFrame(f)
  CreateTableHeader(f, L["%s %s"]:format(_G.CUSTOM, _G.ITEMS), "customItems")
  CreateTableHeader(f, "Sync", "sync")

  frames.customItems = CreateFrame("FRAME", "CustomItemsFrame", f, BackdropTemplateMixin and "BackdropTemplate");
  frames.customItems:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT", 0, -5)
  EPGP:GetModule("optionsCustomItems"):FillFrame(frames.customItems, f)

  frames.sync = CreateFrame("FRAME", "CustomItemsFrame", f, BackdropTemplateMixin and "BackdropTemplate");
  frames.sync:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT", 0, -5)
  EPGP:GetModule("sync"):FillFrame(frames.sync, f)

  f.UpdateSize = function(width, height)
    f:SetWidth(width + 30)
    f:SetHeight(height + headers[1]:GetHeight() + 35)
  end

  f.OnShowFunc = function()
    TableHeaderOnClickFunc(headers[1])
  end
end

function mod:OnEnable()
end

function mod:OnDisable()
end
