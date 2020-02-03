local mod = EPGP:NewModule("options")

local L = LibStub("AceLocale-3.0"):GetLocale("EPGP")

local function CreateTableHeader(parent, text, width, group)
  local function TableHeaderOnClickFunc(self)
    for i, h in pairs(group) do
      h:SetNormalTexture(nil)
    end
    self:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
  end

  local h = CreateFrame("Button", nil, parent)
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
  h:SetWidth(width or (h:GetTextWidth() + 20))
  h:SetHighlightTexture(
    "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
  h:SetScript("OnClick", TableHeaderOnClickFunc)

  return h
end

function mod:FillFrame(f)
  local h = {}
  h.customItems = CreateTableHeader(f, L["Custom Items"], nil, h)
  h.customItems:SetPoint("TOPLEFT", 15, -15)

  local cf = {}
  cf.customItems = CreateFrame("FRAME", "CustomItemsFrame", f)
  cf.customItems:SetPoint("TOPLEFT", h.customItems, "BOTTOMLEFT", 0, -5)
  -- cf.customItems:SetPoint("BOTTOM", f, "BOTTOM", -15-27, 15)
  -- cf.customItems:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15-27, 15)
  EPGP:GetModule("optionsCustomItems"):FillFrame(cf.customItems)

  f:SetWidth(cf.customItems:GetWidth() + 82)
  f:SetHeight(cf.customItems:GetHeight() + h.customItems:GetHeight() + 35)
end

function mod:OnEnable()
end

function mod:OnDisable()
end
